# TodoApp ドキュメント

Flutter 初心者向けに、このアプリで使っている技術と実装内容を解説したドキュメントです。

## 目次

| ファイル | 内容 |
|---|---|
| [01_architecture.md](01_architecture.md) | アーキテクチャ全体像・ファイル構成・データの流れ |
| [02_flutter_basics.md](02_flutter_basics.md) | Flutter/Dart の基礎知識・ウィジェットの種類 |
| [03_riverpod.md](03_riverpod.md) | 状態管理ライブラリ Riverpod の使い方 |
| [04_firebase.md](04_firebase.md) | Firebase / Firestore の概念・オフライン対応 |
| [05_code_generation.md](05_code_generation.md) | freezed / json_serializable / riverpod_generator |
| [06_testing.md](06_testing.md) | テストの書き方（Repository / Notifier / Widget） |
| [07_cicd.md](07_cicd.md) | GitHub Actions による CI/CD パイプライン |

---

## 技術スタック

| 技術 | 用途 |
|---|---|
| Flutter 3.41.6 | クロスプラットフォーム UI フレームワーク |
| Dart 3.11.4 | プログラミング言語 |
| Firebase Firestore | リアルタイムクラウドデータベース |
| flutter_riverpod | 状態管理ライブラリ |
| freezed | イミュータブルクラスのコード生成 |
| json_serializable | JSON 変換コードの生成 |
| riverpod_generator | Riverpod プロバイダーのコード生成 |
| fake_cloud_firestore | テスト用インメモリ Firestore |
| mocktail | モッキングライブラリ |

---

## クイックスタート

このアプリを手元で動かすまでの手順です。

### 前提条件

Flutter と Firebase の環境が整っていない場合は、先にセットアップドキュメントを参照してください：

| OS | セットアップ手順 |
|---|---|
| Mac | [setup/flutter_setup_mac.md](setup/flutter_setup_mac.md) |
| Windows | [setup/flutter_setup_windows.md](setup/flutter_setup_windows.md) |

> ⚠️ **FlutterFire CLI（`flutterfire` コマンド）** が必要です。未導入の場合は各セットアップドキュメントの「FlutterFire CLI のインストール」セクションを参照してください。

---

### 手順

#### ① パッケージをインストール

```bash
flutter pub get
```

`pubspec.yaml` に記載された依存ライブラリをすべてダウンロードします。

---

#### ② コードを自動生成

```bash
dart run build_runner build --delete-conflicting-outputs
```

`freezed`・`json_serializable`・`riverpod_generator` が使うコード（`*.freezed.dart`、`*.g.dart`）を生成します。
これを実行しないとアプリがビルドできません。

> ℹ️ コードを変更するたびに再実行が必要です。継続的に変更する場合は `watch` オプションが便利です：
> ```bash
> dart run build_runner watch --delete-conflicting-outputs
> ```

---

#### ③ Firebase を設定する

Firebase との接続設定ファイル `lib/firebase_options.dart` を生成します。

```bash
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

**YOUR_FIREBASE_PROJECT_ID の確認方法：**
[Firebase Console](https://console.firebase.google.com/) →「プロジェクトの設定（歯車アイコン）」→「プロジェクト ID」

> ⚠️ `firebase_options.dart` はセキュリティ情報を含むため `.gitignore` に含まれています。
> リポジトリをクローンした場合は**毎回この手順が必要**です。

---

#### ④ アプリを起動

```bash
flutter run
```

接続済みのデバイス（実機 or エミュレータ）でアプリが起動します。

```bash
# 複数デバイスが接続されている場合はデバイスを指定
flutter run -d <device_id>

# 接続デバイスの一覧確認
flutter devices
```

---

#### ⑤ テストを実行

```bash
flutter test
```

全テスト（11件）が通ることを確認します。

```bash
# カバレッジ付きで実行
flutter test --coverage
```

---

## 推奨学習順序

1. **[02_flutter_basics.md](02_flutter_basics.md)** — Flutter/Dart の基礎を確認
2. **[01_architecture.md](01_architecture.md)** — アプリ全体の構造を把握
3. **[03_riverpod.md](03_riverpod.md)** — 状態管理の仕組みを理解
4. **[04_firebase.md](04_firebase.md)** — Firebase との連携を理解
5. **[05_code_generation.md](05_code_generation.md)** — コード生成の仕組みを理解
6. **[06_testing.md](06_testing.md)** — テストの書き方を学ぶ
7. **[07_cicd.md](07_cicd.md)** — CI/CD の仕組みを理解
