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

```bash
# 1. パッケージをインストール
flutter pub get

# 2. コードを生成
dart run build_runner build --delete-conflicting-outputs

# 3. Firebase を設定（firebase_options.dart を生成）
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID

# 4. アプリを起動
flutter run

# 5. テストを実行
flutter test
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
