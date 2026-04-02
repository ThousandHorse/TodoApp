# アーキテクチャ解説

## 全体像

このアプリは **クリーンアーキテクチャ** をベースに4つの層で構成されています。

```
┌─────────────────────────────────────────┐
│  Presentation層（UI）                    │
│  lib/presentation/                       │
│  ウィジェット・画面の描画だけを担当        │
├─────────────────────────────────────────┤
│  Application層（状態管理）               │
│  lib/application/                        │
│  Riverpod プロバイダー・Notifier         │
├─────────────────────────────────────────┤
│  Domain層（ビジネスロジック）             │
│  lib/domain/                             │
│  エンティティ・リポジトリのインターフェース │
├─────────────────────────────────────────┤
│  Data層（データアクセス）                 │
│  lib/data/                               │
│  Firebase/Firestore との通信             │
└─────────────────────────────────────────┘
```

### 重要なルール：依存の方向

**上の層は下の層を知らない** がこのアーキテクチャの核心です。

```
Presentation → Application → Domain ← Data
```

- `Domain` 層は最も独立しており、Firebase も Flutter も import しません
- `Data` 層は `Domain` のインターフェースを実装します
- `Presentation` 層は `Domain` のエンティティ（`Todo`）は知っていますが、`Firebase` は知りません

---

## ファイル構成

```
lib/
├── main.dart                          ← アプリの起点。Firebase初期化・DI設定
├── firebase_options.dart              ← Firebase接続設定（flutterfire configure で生成）
│
├── domain/                            ← ビジネスロジックの核心
│   ├── entities/
│   │   └── todo.dart                  ← Todoデータの設計図（freezed）
│   └── repositories/
│       └── todo_repository.dart       ← 「何ができるか」の仕様書（interface）
│
├── data/                              ← Firebaseとの通信
│   ├── datasources/
│   │   └── firestore_todo_datasource.dart  ← Firestore API を直接呼ぶ
│   ├── models/
│   │   └── todo_model.dart            ← Firestore ↔ アプリ のデータ変換
│   └── repositories/
│       └── todo_repository_impl.dart  ← todo_repository.dart の実装
│
├── application/                       ← 状態管理（Riverpod）
│   └── providers/
│       └── todo_providers.dart        ← プロバイダー・AsyncNotifier
│
└── presentation/                      ← 画面とウィジェット
    ├── pages/
    │   └── todo_list_page.dart        ← メイン画面
    └── widgets/
        ├── todo_list_item.dart        ← リスト1行分のウィジェット
        ├── add_todo_dialog.dart       ← 追加ダイアログ
        └── edit_todo_dialog.dart      ← 編集ダイアログ
```

---

## データの流れ

### タスクを追加するときの流れ

```
ユーザーが「追加」をタップ
  │
  ▼
AddTodoDialog._submit()
  │  ref.read(todoListProvider.notifier).addTodo(title: ...)
  ▼
TodoList.addTodo()  [Application層: AsyncNotifier]
  │  ref.read(todoRepositoryProvider).addTodo(...)
  ▼
TodoRepositoryImpl.addTodo()  [Data層: Repository]
  │  TodoModel を作成して datasource に渡す
  ▼
FirestoreTodoDatasource.addTodo()  [Data層: Datasource]
  │  Firestore の collection('todos').doc(id).set(data)
  ▼
Firebase Firestore（クラウドDB）
  │  データ変更を検知して snapshots() Stream に流す
  ▼
FirestoreTodoDatasource.watchTodos()  [Stream が自動で更新]
  │  TodoModel のリストを流す
  ▼
TodoRepositoryImpl.watchTodos()  [TodoModel → Todo に変換]
  │  Todo のリストを流す
  ▼
TodoList.build()  [AsyncNotifier の state が自動更新]
  │
  ▼
TodoListPage の ref.watch(todoListProvider) が反応
  │
  ▼
UI が自動的に再描画される ✅
```

---

## なぜこの設計なのか

### 1. テストしやすい

`TodoRepository` がインターフェースなので、テスト時は Firebase を使わずに
偽物（モック）に差し替えられます。

```dart
// 本番
todoRepositoryProvider.overrideWithValue(TodoRepositoryImpl(firestore))

// テスト
todoRepositoryProvider.overrideWithValue(MockTodoRepository())
```

### 2. 変更に強い

たとえば「Firebase から Supabase に乗り換える」となっても、
`data/` 層だけを書き換えれば OK です。
`domain/` も `presentation/` も変更不要です。

### 3. 責務が明確

各ファイルが「何をする場所か」が一目でわかります。
- 「UI の見た目を変えたい」→ `presentation/`
- 「Firestore のクエリを変えたい」→ `data/datasources/`
- 「状態の持ち方を変えたい」→ `application/providers/`
