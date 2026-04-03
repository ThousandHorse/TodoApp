# Figma による画面設計と開発連携

このアプリでは **Figma** を画面設計書・UI デザインツールとして使用します。
デザイナーと開発者が共通の画面仕様を参照しながら実装できる環境を整えます。

---

## Figma とは

Figma はブラウザ上で動くデザインツールで、以下のことができます：

| 機能 | 説明 |
|---|---|
| ワイヤーフレーム | 画面の大まかなレイアウト設計 |
| UI デザイン | 色・フォント・アイコンを使った実際の見た目の設計 |
| プロトタイプ | 画面遷移のインタラクションを再現したデモ |
| コメント | デザイン上に直接コメントを残してフィードバック |
| 開発者向け仕様確認 | CSS 値・サイズ・カラーコードをコピー可能 |

> ✅ アカウントさえあれば **ブラウザだけで使用可能**（無料プランあり）。

---

## このプロジェクトでの使い方

```
① Figma で画面設計（ワイヤーフレーム / デザイン）
         ↓
② レビュー・コメントでフィードバック
         ↓
③ 開発者が Figma を参照しながら Flutter で実装
         ↓
④ 実装後、Figma と見た目を照合してレビュー
```

---

## Figma のセットアップ

### アカウント作成

1. [https://www.figma.com](https://www.figma.com) にアクセス
2.「Get started for free」→ Google アカウントでサインアップ推奨

### デスクトップアプリ（任意）

ブラウザでも使えますが、デスクトップアプリの方が動作が安定します。

- Mac: App Store で「Figma」を検索してインストール
- Windows: [https://www.figma.com/downloads/](https://www.figma.com/downloads/) からダウンロード

---

## プロジェクトへの参加方法

Figma ファイルの共有 URL を受け取ったら：

1. URL をブラウザで開く
2. Figma にログインした状態でアクセスすると自動的に閲覧可能
3. 編集権限が必要な場合はオーナーに「Edit アクセス」を依頼

### 権限の種類

| 権限 | できること |
|---|---|
| **Can view** | 閲覧・コメント・仕様確認（開発者向け） |
| **Can edit** | デザイン編集（デザイナー向け） |

---

## 開発者向け：Figma から仕様を読み取る

### Dev Mode（開発者モード）の使い方

Figma の右上「Dev Mode」トグルをオンにすると、選択した要素の仕様が表示されます：

```
選択した要素 → 右パネルに表示される情報
├── サイズ（width / height）
├── 余白（padding / margin）
├── カラーコード（HEX / RGB）
├── フォントサイズ・ウェイト
└── CSS スニペット（参考値として使用）
```

> ℹ️ Flutter は CSS ではなく `Widget` で実装しますが、値の参照に役立ちます。

### Figma の値を Flutter に変換する例

| Figma | Flutter |
|---|---|
| `color: #FF5722` | `Color(0xFFFF5722)` |
| `font-size: 16px` | `fontSize: 16` |
| `padding: 16px` | `padding: EdgeInsets.all(16)` |
| `border-radius: 8px` | `borderRadius: BorderRadius.circular(8)` |
| `gap: 8px`（縦並び） | `SizedBox(height: 8)` または `mainAxisSpacing: 8` |

---

## デザインフロー（画面追加・変更時）

新しい画面や UI 変更が発生した場合の進め方：

### 1. Figma で画面設計

- 新しいフレーム（= 画面）を作成
- ワイヤーフレーム → デザイン の順に進める
- 画面名は Flutter のページ名に合わせる（例：`TodoListPage`、`TodoDetailPage`）

### 2. レビュー

- Figma のコメント機能（`C` キー）でフィードバック
- 修正が完了したらコメントを「Resolve」

### 3. Flutter 実装

- Figma を参照しながら `lib/presentation/pages/` または `lib/presentation/widgets/` に実装
- 色・サイズは定数化を推奨（`lib/presentation/theme/` などにまとめる）

### 4. 実装レビュー

- Figma と実装画面をスクリーンショットで比較
- 差分があればコメントで指摘 → 修正

---

## 画面一覧（現在の設計対象）

| 画面名 | Flutter ファイル | 説明 |
|---|---|---|
| Todo リスト画面 | `todo_list_page.dart` | Todo の一覧表示・追加ボタン |
| Todo 追加ダイアログ | `add_todo_dialog.dart` | タイトル・説明を入力して追加 |
| Todo 編集ダイアログ | `edit_todo_dialog.dart` | 既存 Todo を編集 |

---

## 推奨学習順序

Figma を初めて使う場合：

1. [Figma 公式チュートリアル](https://help.figma.com/hc/en-us/articles/360040514373) でフレーム・テキスト・図形の基本操作を習得
2. このプロジェクトの Figma ファイルを「Can view」で開いて構成を確認
3. 開発者モードで各要素の仕様値を確認する練習をする
