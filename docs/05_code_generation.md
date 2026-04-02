# コード生成（freezed / json_serializable / riverpod_generator）解説

## コード生成とは？

**アノテーション（`@freezed` など）** を書くと、
`dart run build_runner build` コマンドで定型コードを **自動生成** してくれる仕組みです。

```
あなたが書くコード        自動生成されるコード
─────────────────        ─────────────────────────────
todo.dart        →       todo.freezed.dart  (copyWith, ==, toString)
todo_model.dart  →       todo_model.g.dart  (fromJson, toJson)
todo_providers.dart →    todo_providers.g.dart (Riverpod プロバイダー)
```

### なぜコード生成を使うの？

手書きすると以下のようなコードが毎回必要になります：

```dart
// コード生成なし（手書き）
class Todo {
  final String id;
  final String title;
  final bool isCompleted;

  Todo({required this.id, required this.title, required this.isCompleted});

  // copyWith を手書き（フィールドが増えるたびに修正が必要）
  Todo copyWith({String? id, String? title, bool? isCompleted}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // == を手書き
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Todo && id == other.id && title == other.title && ...;

  // hashCode を手書き
  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ ...;
}
```

コード生成を使えば、これらすべてが `@freezed` の一言で済みます。

---

## freezed

`Todo` エンティティに使っています。

### できること

| 機能 | 説明 |
|---|---|
| `copyWith()` | 指定したフィールドだけ変えた新しいインスタンスを作る |
| `==` / `hashCode` | 値の等値比較（`todo1 == todo2` が正しく動く） |
| `toString()` | デバッグ時に読みやすい文字列を返す |
| イミュータブル | インスタンス作成後に値を変えられない（安全） |

### 書き方

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart'; // ← 生成ファイルを取り込む宣言

@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    @Default(false) bool isCompleted, // ← デフォルト値も設定できる
  }) = _Todo;
}
```

### 生成後の使い方

```dart
final todo = Todo(id: '1', title: 'タスク');

// copyWith: id だけ変えた新しいインスタンスを作る
final updated = todo.copyWith(isCompleted: true);

// == 比較
final same = Todo(id: '1', title: 'タスク');
print(todo == same); // → true（値が同じなら equal）
```

---

## json_serializable

`TodoModel` に使っています。Map ↔ クラス の変換コードを自動生成します。

### 書き方

```dart
import 'package:json_annotation/json_annotation.dart';

part 'todo_model.g.dart'; // ← 生成ファイルを取り込む宣言

@JsonSerializable(explicitToJson: true)
class TodoModel {
  final String id;
  final String title;

  const TodoModel({required this.id, required this.title});

  // fromJson / toJson のコードが自動生成される
  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json); // ← 生成されたコードを呼ぶ

  Map<String, dynamic> toJson() => _$TodoModelToJson(this);
}
```

### 生成後の使い方

```dart
// Firestore から取得したデータ（Map）をクラスに変換
final model = TodoModel.fromJson({'id': '123', 'title': 'タスク'});

// クラスを Firestore に保存するデータ（Map）に変換
final data = model.toJson(); // → {'id': '123', 'title': 'タスク'}
```

---

## riverpod_generator

`todo_providers.dart` に使っています。Riverpod のプロバイダーを自動生成します。

### 書き方

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todo_providers.g.dart'; // ← 生成ファイルを取り込む宣言

@riverpod
String greeting(Ref ref) {
  return 'こんにちは';
}
// → greetingProvider が生成される

@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0; // 初期値

  void increment() => state++;
}
// → counterProvider と counterProvider.notifier が生成される
```

---

## コード生成コマンド

```bash
# 1回だけ生成（CI/CDやビルド前に実行）
dart run build_runner build --delete-conflicting-outputs

# ファイルの変更を監視して自動生成（開発中に便利）
dart run build_runner watch --delete-conflicting-outputs
```

### `--delete-conflicting-outputs` とは？

以前生成したファイルと新しく生成するファイルが競合した場合、
古いファイルを自動的に削除してから生成し直します。
これがないと競合エラーが出ることがあります。

---

## .gitignore での管理

生成ファイルは `.gitignore` に追加して git 管理外にしています：

```
# Generated files（build_runner で再生成可能なため管理不要）
*.freezed.dart
*.g.dart
```

**理由：**
- 生成ファイルはソースコードから常に再生成できる
- git の差分に含めると変更履歴が汚れる
- CI/CD パイプラインで毎回生成するため問題なし

**注意：** `pubspec.lock` は必ず git 管理に含めてください。
パッケージのバージョンを固定することでチーム間・CI での再現性を保てます。
