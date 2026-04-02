# Firebase / Firestore 解説

## Firebase とは？

Google が提供するモバイル・Web アプリ開発プラットフォームです。
バックエンド（サーバー）を自分で構築しなくても、
データベース・認証・ストレージなどが使えます。

このアプリでは **Cloud Firestore**（リアルタイムデータベース）を使っています。

---

## Cloud Firestore のデータ構造

Firestore は「コレクション → ドキュメント」というツリー構造でデータを管理します。

```
Firestore
└── todos（コレクション = テーブルのようなもの）
    ├── abc123（ドキュメント = 1件のタスク）
    │   ├── title: "買い物に行く"
    │   ├── description: "牛乳・卵・パン"
    │   ├── isCompleted: false
    │   ├── createdAt: Timestamp(2024-01-01 10:00:00)
    │   └── updatedAt: null
    ├── def456（ドキュメント）
    │   ├── title: "Flutter を学ぶ"
    │   └── ...
    └── ...
```

- **コレクション** = RDB のテーブルに相当（`todos` など）
- **ドキュメント** = RDB の1行に相当（1件のタスク）
- **フィールド** = RDB のカラムに相当（`title`, `isCompleted` など）

---

## リアルタイム監視（Stream）

Firestore の最大の特徴は **リアルタイム同期** です。

```dart
// snapshots() = データの変化を Stream として監視する
firestore.collection('todos').snapshots().listen((snapshot) {
  // Firestore のデータが変わるたびここが呼ばれる
  print('データ更新: ${snapshot.docs.length} 件');
});
```

このアプリでは `watchTodos()` でこれを活用しています：

```
あなたのデバイス              別のデバイス / Firebase Console
     │                              │
     │                   Firestoreのデータを変更
     │                              │
     ◀─── Firestore が自動で通知 ────┤
     │
     ▼
watchTodos() の Stream に新しい値が流れる
     │
     ▼
UI が自動更新される ✅
```

---

## オフライン対応のしくみ

`main.dart` で以下の設定を有効にしています：

```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,        // オフラインキャッシュを有効化
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // キャッシュ容量制限なし
);
```

### オフライン時の動作

```
オンライン時：
  Firestore サーバー → データ取得 → ローカルキャッシュに保存

オフライン時：
  ローカルキャッシュ → データ返却（Stream も流れ続ける）
  書き込み → ローカルで保留（Pending write）

再接続時：
  保留中の書き込みを Firestore サーバーに自動送信
  サーバーのデータとローカルを同期
```

### 技術検証の確認方法

1. アプリを起動してタスクを追加（オンライン状態）
2. デバイスを機内モードにする
3. タスクを追加・編集・削除してみる → キャッシュから動く
4. 機内モードを解除する → 操作内容が Firestore に自動同期される

---

## Timestamp（日時型）の変換

Firestore の日時型は `Timestamp` ですが、Dart では `DateTime` を使います。
`TodoModel` でこの変換を行っています。

```dart
// Firestore Timestamp → Dart DateTime
Timestamp.toDate()    // Timestamp → DateTime
Timestamp.fromDate(d) // DateTime → Timestamp

// コード例（TodoModel より）
static DateTime _timestampFromJson(dynamic value) {
  if (value is Timestamp) return value.toDate();
  ...
}
```

---

## Firebase の初期設定手順

実際に Firebase と接続するには以下の手順が必要です：

### 1. Firebase プロジェクトを作成

[Firebase Console](https://console.firebase.google.com/) で新規プロジェクトを作成します。

### 2. FlutterFire CLI をインストール

```bash
dart pub global activate flutterfire_cli
```

### 3. Firebase プロジェクトと Flutter プロジェクトを接続

```bash
flutterfire configure --project=your-firebase-project-id
```

実行すると `lib/firebase_options.dart` が自動生成されます。
このファイルに API キーなどの接続情報が含まれます。

### 4. Firestore のセキュリティルール

Firebase Console → Firestore Database → ルール で設定します。

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /todos/{todoId} {
      // 現在は全員読み書き可能（開発用）
      // 本番では認証ユーザーのみに制限する
      allow read, write: if true;
    }
  }
}
```

---

## FieldValue.serverTimestamp()

`updateTodo` 時に `updatedAt` フィールドにサーバー側の時刻を設定しています。

```dart
data['updatedAt'] = FieldValue.serverTimestamp();
```

クライアント（デバイス）の時刻は時刻がズレている可能性があります。
`serverTimestamp()` を使うと Firestore サーバーの正確な時刻が記録されるため信頼性が高くなります。
