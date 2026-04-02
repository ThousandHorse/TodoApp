# Riverpod 解説

## Riverpod とは？

Flutter の **状態管理ライブラリ** です。
「状態」= アプリが今持っているデータ（Todoリスト、ローディング中かどうか、など）

Riverpod を使うと：
- **どこからでもデータにアクセス**できる（ウィジェット間でのデータ受け渡し不要）
- **データが変わったら UI が自動更新**される
- **テストがしやすい**（モックへの差し替えが簡単）

---

## プロバイダーの基本

**プロバイダー** = データを提供・管理するオブジェクト

```dart
// @riverpod アノテーションでプロバイダーを定義
@riverpod
String greeting(Ref ref) {
  return 'こんにちは！';
}
// → greetingProvider という変数が自動生成される
```

ウィジェットから使うには：

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch でプロバイダーの値を監視（変わったら再描画）
    final message = ref.watch(greetingProvider);
    return Text(message);
  }
}
```

---

## ref.watch と ref.read の違い

| メソッド | 用途 | 再描画 |
|---|---|---|
| `ref.watch` | 値を監視する（UI の `build()` 内） | 値が変わると再描画 |
| `ref.read` | 一度だけ値を読む（ボタンのコールバック等） | しない |

```dart
// ✅ build() 内では watch を使う
final todos = ref.watch(todoListProvider);

// ✅ ボタンのコールバック内では read を使う
onPressed: () => ref.read(todoListProvider.notifier).addTodo(...)
```

---

## AsyncNotifier

このアプリの核心部分です。非同期データ（FirebaseなどのStream/Future）を
状態として管理するクラスです。

```dart
@riverpod
class TodoList extends _$TodoList {
  // build() = 初回・依存変化時に呼ばれる
  // Stream を返すと Firestore の変化が自動で state に反映される
  @override
  Stream<List<Todo>> build() {
    return ref.watch(todoRepositoryProvider).watchTodos();
  }

  // 操作メソッド（UIから呼ばれる）
  Future<void> addTodo({required String title}) async {
    await ref.read(todoRepositoryProvider).addTodo(title: title);
  }
}
```

### AsyncValue — 3つの状態

`AsyncNotifier` の `state` は `AsyncValue<T>` 型です。

```
AsyncValue<List<Todo>>
  ├── AsyncLoading  … Firestore からのデータ取得中
  ├── AsyncData     … データ取得成功（List<Todo> を持つ）
  └── AsyncError    … エラー発生（エラー情報を持つ）
```

### .when() で3状態をUIに分岐

```dart
todoListAsync.when(
  loading: () => CircularProgressIndicator(),  // ロード中
  error: (err, stack) => Text('エラー: $err'),  // エラー
  data: (todos) => ListView(...),              // 成功
)
```

---

## 依存性注入（DI）のしくみ

このアプリでは `ProviderScope.overrides` を使って「本番用実装」を注入します。

```
main.dart
└── ProviderScope(
      overrides: [
        todoRepositoryProvider ← TodoRepositoryImpl（Firebase実装）を注入
      ]
    )
        │
        ▼
TodoList.build() が ref.watch(todoRepositoryProvider) を呼ぶ
        │
        ▼
TodoRepositoryImpl.watchTodos() が Firestore から Stream を返す
```

**テスト時は差し替えるだけ：**

```dart
ProviderContainer(
  overrides: [
    todoRepositoryProvider ← MockTodoRepository（偽物）を注入
  ]
)
```

---

## このアプリの状態の流れ

```
Firestore（クラウドDB）
  │ snapshots() で変化を検知
  ▼
FirestoreTodoDatasource.watchTodos()
  │ Stream<List<TodoModel>>
  ▼
TodoRepositoryImpl.watchTodos()
  │ Stream<List<Todo>> に変換
  ▼
TodoList.build() の Stream
  │ AsyncValue<List<Todo>> として state に保存
  ▼
ref.watch(todoListProvider) が変化を検知
  │
  ▼
TodoListPage.build() が再実行 → UIが更新 ✅
```

---

## コード生成について

`@riverpod` アノテーションは **コード生成** を使います。
実際に使えるプロバイダー（`todoListProvider` など）は、
以下のコマンドで自動生成されます：

```bash
dart run build_runner build --delete-conflicting-outputs
```

生成されるファイル：
- `todo_providers.g.dart` ← `@riverpod` から生成

このファイルは `.gitignore` で管理対象外にしています（CI で毎回生成するため）。
