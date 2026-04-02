# CI/CD 解説（GitHub Actions）

## CI/CD とは？

| 用語 | 意味 |
|---|---|
| **CI**（継続的インテグレーション） | コードをプッシュするたびに自動でテスト・解析を実行する |
| **CD**（継続的デリバリー） | テストが通ったコードを自動でビルド・デプロイする |

CI/CD を導入すると：
- **バグの混入を防ぐ**（テストが失敗したらマージできない）
- **手作業ミスをなくす**（ビルドやテストを人手でやらなくて済む）
- **コードの品質を保つ**（静的解析が自動で走る）

---

## ワークフローファイルの場所

```
.github/
└── workflows/
    ├── ci.yml   ← PR 時に自動実行（テスト・解析）
    └── cd.yml   ← main ブランチへのマージ時に自動実行（ビルド検証）
```

---

## CI ワークフロー（ci.yml）

### いつ実行される？

```yaml
on:
  pull_request:        # PR を作成・更新したとき
    branches: [main, develop]
  push:
    branches: [develop] # develop ブランチにプッシュしたとき
```

### 実行されるステップ

```
1. actions/checkout      … リポジトリのコードをチェックアウト
2. subosito/flutter-action … Flutter をインストール
3. actions/cache         … pub パッケージのキャッシュを使う（高速化）
4. flutter pub get       … パッケージをインストール
5. build_runner build    … コード生成（*.freezed.dart, *.g.dart）
6. flutter analyze       … 静的解析（バグの可能性がある書き方を検出）
7. dart format           … コードフォーマットのチェック
8. flutter test          … テストを実行
9. codecov               … カバレッジをアップロード
```

### 静的解析（flutter analyze）

コードを実行せずに問題を検出します。

```bash
flutter analyze --fatal-infos
# --fatal-infos = info レベルの警告でも失敗扱いにする（厳格モード）
```

検出できる問題例：
- 使っていない変数
- null 安全に関する問題
- パフォーマンスに影響する書き方

### フォーマットチェック（dart format）

```bash
dart format --output=none --set-exit-if-changed .
# --output=none           = 実際には書き換えない（チェックのみ）
# --set-exit-if-changed   = 変更が必要なファイルがあれば失敗にする
```

フォーマットが崩れているコードをマージできないようにします。
ローカルで `dart format .` を実行すれば自動整形されます。

---

## CD ワークフロー（cd.yml）

### いつ実行される？

```yaml
on:
  push:
    branches: [main] # main ブランチにマージされたとき
```

### Android ビルド

```yaml
- uses: actions/setup-java@v4  # Android ビルドに Java が必要
  with:
    java-version: '17'

- run: flutter build apk --debug
```

### iOS ビルド

```yaml
runs-on: macos-latest  # iOS ビルドは macOS が必要

- run: flutter build ios --debug --no-codesign
# --no-codesign = 署名なし（証明書の設定が不要）
```

---

## GitHub Secrets

機密情報（APIキーなど）はコードに直接書かずに **Secrets** で管理します。

### 必要な Secrets

| Secret 名 | 内容 | 設定場所 |
|---|---|---|
| `FIREBASE_OPTIONS_DART` | `firebase_options.dart` の全内容 | ワークフロー実行環境に復元するため |
| `CODECOV_TOKEN` | Codecov のアップロードトークン | カバレッジレポートの送信 |

### Secrets の設定方法

```
GitHub リポジトリ
  → Settings
    → Secrets and variables
      → Actions
        → New repository secret
```

### CD ワークフローでの使い方

```yaml
# firebase_options.dart を Secrets から復元する
- name: Restore Firebase options
  run: echo "${{ secrets.FIREBASE_OPTIONS_DART }}" > lib/firebase_options.dart
```

`firebase_options.dart` は `.gitignore` に含まれているため、
CI/CD 環境では Secrets から復元しています。

---

## パイプラインのフロー

```
開発者がコードをプッシュ
  │
  ▼
PR を作成
  │
  ▼
CI ワークフローが自動実行
  ├── ✅ 成功 → PR をマージ可能
  └── ❌ 失敗 → マージ不可（修正が必要）
          │
          ▼
main にマージ
  │
  ▼
CD ワークフローが自動実行
  ├── Android APK ビルド
  └── iOS ビルド（no codesign）
```

---

## キャッシュによる高速化

毎回 Flutter SDK や pub パッケージをダウンロードすると遅いため、
キャッシュを使って2回目以降を高速化しています。

```yaml
# Flutter SDK のキャッシュ
- uses: subosito/flutter-action@v2
  with:
    cache: true  # Flutter SDK をキャッシュ

# pub パッケージのキャッシュ
- uses: actions/cache@v4
  with:
    path: |
      ~/.pub-cache   # パッケージのキャッシュ
      .dart_tool     # ビルドキャッシュ
    key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
    # pubspec.lock が変わったときだけキャッシュを更新
```
