# Flutter 環境構築手順
**対象：Mac (Apple Silicon / M1〜) / iOS・Android向け**

---

## 全体の流れ

```
① Rosetta 2 インストール
② Flutter SDK インストール
③ PATH を通す
④ Xcode セットアップ（iOS用）
⑤ Android Studio セットアップ（Android用）
⑥ flutter doctor で確認
```

---

## ① Rosetta 2 のインストール

Flutter の一部ツールが x86_64 向けのため、ARMとの互換レイヤーとして必要。

```bash
sudo softwareupdate --install-rosetta --agree-to-license
```

---

## ② Flutter SDK のインストール

### Homebrew でインストール

Homebrew が未インストールの場合：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Flutter 本体：

```bash
brew install --cask flutter
```

---

## ③ PATH を通す

### .zshrc が存在しない場合はまず作成

```bash
touch ~/.zshrc
```

### .zshrc を開いて PATH を追記

```bash
open ~/.zshrc
```

以下を末尾に貼り付けて保存（⌘+S）：

```bash
export PATH="$PATH:$HOME/flutter/bin"
```

### 設定を反映

```bash
source ~/.zshrc
```

### 動作確認

```bash
flutter --version
# Flutter 3.x.x ... と表示されればOK
```

> ✅ Homebrew でインストールした場合は PATH が自動で通るため、この手順はスキップできることが多い。先に `flutter --version` を試すこと。

---

## ④ Xcode のセットアップ（iOS用）

### 4-1. Xcode をインストール

App Store から **Xcode** をインストール（約15GB）。

### 4-2. コマンドラインツールを設定

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### 4-3. iOS シミュレータの確認

```bash
open -a Simulator
```

### 4-4. CocoaPods のインストール

```bash
brew install cocoapods
```

---

## ⑤ Android Studio のセットアップ（Android用）

### 5-1. Android Studio をインストール

[公式サイト](https://developer.android.com/studio) から **Mac (Apple Silicon)** 版をダウンロード。

### 5-2. cmdline-tools をインストール

Android Studio 起動 →「More Actions」→「SDK Manager」→「SDK Tools」タブ

以下にチェックを入れて「Apply」：

```
✅ Android SDK Command-line Tools (latest)
```

> ⚠️ これを入れないと `flutter doctor --android-licenses` がエラーになる。

### 5-3. Android ライセンスに同意

```bash
flutter doctor --android-licenses
# 全部 y で同意
```

### 5-4. エミュレータの作成（任意）

Android Studio →「More Actions」→「Virtual Device Manager」→「Create Device」

---

## ⑥ flutter doctor で最終確認

```bash
flutter doctor
```

以下のようにすべて ✅ になればOK：

```
[✓] Flutter
[✓] Android toolchain
[✓] Xcode
[✓] Network resources
• No issues found!
```

### よくある警告と対処

| 警告・エラー | 対処 |
|---|---|
| `Android sdkmanager not found` | Android Studio の SDK Tools から `cmdline-tools` をインストール |
| `Android license status unknown` | `flutter doctor --android-licenses` を実行 |
| `CocoaPods not installed` | `brew install cocoapods` |
| iPhoneのワイヤレス接続エラー (code -27) | iPhoneの「設定 → プライバシーとセキュリティ → デベロッパーモード」をオン（任意） |

---

## 最初のアプリ作成

```bash
# プロジェクト作成
flutter create my_first_app

# フォルダに移動
cd my_first_app

# 起動
flutter run
```

---

## 推奨エディタ

**VS Code** に以下の拡張機能を追加：

- `Flutter`
- `Dart`
