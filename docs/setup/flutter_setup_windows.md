# Flutter 環境構築手順
**対象：Windows 10 / 11 (64bit) / Android向け**

> ℹ️ Windows では iOS 向けビルドはできません（Xcode が macOS 専用のため）。
> iOS 対応が必要な場合は Mac をご利用ください。

---

## 全体の流れ

```
① システム要件の確認
② Flutter SDK インストール
③ PATH を通す
④ Android Studio セットアップ
⑤ flutter doctor で確認
```

---

## ① システム要件の確認

| 項目 | 要件 |
|---|---|
| OS | Windows 10 (64bit) 以降 |
| ディスク空き容量 | 10GB 以上（Android Studio 含む） |
| PowerShell | 5.0 以上（Windows 10 標準で含まれる） |
| Git for Windows | 必須 |

### Git for Windows のインストール

[https://git-scm.com/download/win](https://git-scm.com/download/win) からダウンロードしてインストール。

> ⚠️ インストール時に「Git from the command line and also from 3rd-party software」を選択すること。

---

## ② Flutter SDK のインストール

### 方法A：手動インストール（推奨・最も確実）

1. [Flutter 公式サイト](https://docs.flutter.dev/get-started/install/windows) から最新の ZIP をダウンロード
2. `C:\flutter` に展開

> ⚠️ `C:\Program Files` など**パスに空白や日本語が含まれる場所は避ける**こと。

### 方法B：Chocolatey でインストール

**Chocolatey**（Windows のパッケージマネージャー）を使う方法です。

まず Chocolatey をインストール（管理者権限の PowerShell で実行）：

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = `
  [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Flutter をインストール：

```powershell
choco install flutter
```

> ℹ️ **winget（`winget install Flutter.Flutter`）は使えません。**
> Flutter は winget のパッケージリポジトリに登録されていないため、
> 「入力条件に一致するパッケージが見つかりませんでした」というエラーになります。

---

## ③ PATH を通す

### Chocolatey でインストールした場合

PATH は自動で設定されます。新しい PowerShell を開いて確認：

```powershell
flutter --version
# Flutter 3.x.x ... と表示されればOK
```

### 手動インストールした場合

1. スタートメニューで「環境変数」と検索 →「システム環境変数の編集」を開く
2.「環境変数」ボタンをクリック
3.「ユーザー環境変数」の `Path` を選択 →「編集」
4.「新規」→ `C:\flutter\bin` を追加 →「OK」
5. PowerShell を再起動して確認：

```powershell
flutter --version
```

> ✅ パスに**日本語や空白が含まれると動作しないことがある**ため、`C:\flutter` のようなシンプルなパスを推奨。

---

## ④ Android Studio のセットアップ

### 4-1. Android Studio をインストール

[公式サイト](https://developer.android.com/studio) から Windows 版をダウンロードしてインストール。

### 4-2. cmdline-tools をインストール

Android Studio 起動 →「More Actions」→「SDK Manager」→「SDK Tools」タブ

以下にチェックを入れて「Apply」：

```
✅ Android SDK Command-line Tools (latest)
```

> ⚠️ これを入れないと `flutter doctor --android-licenses` がエラーになる。

### 4-3. Android ライセンスに同意

PowerShell で実行：

```powershell
flutter doctor --android-licenses
# 全部 y で同意
```

### 4-4. エミュレータの作成（任意）

Android Studio →「More Actions」→「Virtual Device Manager」→「Create Device」

> ⚠️ エミュレータを使うには BIOS で **Intel VT-x** または **AMD-V（SVM）** の仮想化を有効にする必要があります。
> 動作が重い場合は実機（USB接続）の利用を推奨。

### 4-5. 実機（Android端末）で動かす場合

1. Android 端末の「設定」→「デバイス情報」→「ビルド番号」を7回タップ
2.「設定」→「開発者オプション」→「USBデバッグ」をオン
3. USB で PC に接続

---

## ⑤ flutter doctor で最終確認

```powershell
flutter doctor
```

以下のようにすべて ✅ になればOK：

```
[✓] Flutter
[✓] Android toolchain
[✓] Android Studio
[✓] Network resources
• No issues found!
```

> ℹ️ Windows では `[✓] Xcode` は表示されません（macOS 専用）。

### よくある警告と対処

| 警告・エラー | 対処 |
|---|---|
| `Android sdkmanager not found` | Android Studio の SDK Tools から `cmdline-tools` をインストール |
| `Android license status unknown` | `flutter doctor --android-licenses` を実行 |
| `Unable to find git in your PATH` | Git for Windows をインストール後、PowerShell を再起動 |
| `Flutter requires the Visual Studio toolchain` | Windows デスクトップアプリ開発時のみ必要。モバイル開発には不要 |

---

## 最初のアプリ作成

PowerShell で実行：

```powershell
# プロジェクト作成
flutter create my_first_app

# フォルダに移動
cd my_first_app

# 起動（接続済みデバイスまたはエミュレーターが必要）
flutter run
```

---

## 推奨エディタ

**VS Code** に以下の拡張機能を追加：

- `Flutter`
- `Dart`

VS Code のダウンロード：[https://code.visualstudio.com/](https://code.visualstudio.com/)

---

## Mac との主な違い

| 項目 | Mac | Windows |
|---|---|---|
| iOS ビルド | ✅ 可能 | ❌ 不可（Xcode が必要） |
| Android ビルド | ✅ 可能 | ✅ 可能 |
| Web ビルド | ✅ 可能 | ✅ 可能 |
| Flutter インストール | Homebrew 推奨 | 手動 or Chocolatey 推奨 |
| シェル | zsh (.zshrc) | PowerShell |
| PATH 設定 | .zshrc に追記 | 環境変数の GUI で設定 |
