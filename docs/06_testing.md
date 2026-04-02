# テスト解説

## なぜテストを書くの？

- **バグを早期発見**：「動くと思ったら動かない」を防ぐ
- **安心してリファクタリング**できる（テストが通れば壊れていない）
- **仕様のドキュメント**になる（テスト名がそのまま仕様説明になる）

---

## テストの種類

このアプリでは3種類のテストを書いています。

```
test/
├── data/repositories/
│   └── todo_repository_impl_test.dart  ← ①リポジトリテスト（FakeFirestore使用）
├── application/providers/
│   └── todo_providers_test.dart        ← ②Notifierテスト（Mock使用）
└── widget_test.dart                    ← ③Widgetテスト（UI表示の検証）
```

### テストピラミッド

```
         ／\
        /    \    ③ Widget テスト（少数・遅め）
       /──────\
      /        \  ② Unit テスト: Notifier（中程度）
     /──────────\
    /            \ ① Unit テスト: Repository（多数・高速）
   ／──────────────\
```

---

## ① リポジトリテスト（fake_cloud_firestore）

`TodoRepositoryImpl` が Firestore を正しく操作するかを検証します。

### fake_cloud_firestore とは？

本物の Firestore と同じ API を持つ「インメモリ版 Firestore」です。
実際の Firebase プロジェクトが不要で、テストが高速に実行できます。

```dart
// テストの基本構造
setUp(() {
  fakeFirestore = FakeFirebaseFirestore(); // 偽の Firestore
  repository = TodoRepositoryImpl(
    FirestoreTodoDatasource(fakeFirestore), // 偽の Firestore を注入
  );
});

test('addTodo → watchTodos でタスクが取得できる', () async {
  // Arrange（準備）
  await repository.addTodo(title: 'テストタスク');

  // Act + Assert（実行・検証）
  final todos = await repository.watchTodos().first;
  expect(todos.length, 1);
  expect(todos.first.title, 'テストタスク');
});
```

### expect の書き方

```dart
expect(実際の値, 期待値);

expect(todos.length, 1);         // 値の比較
expect(todos, isEmpty);          // リストが空
expect(todos, isNotEmpty);       // リストが空でない
expect(todo.title, 'テスト');    // 文字列の一致
expect(todo.isCompleted, true);  // bool の一致
```

---

## ② Notifier テスト（mocktail）

`TodoList AsyncNotifier` が `TodoRepository` を正しく呼ぶかを検証します。

### mocktail（モック）とは？

インターフェースを実装した「偽物クラス」を簡単に作れるライブラリです。
Firestore を使わずに Notifier だけを単体でテストできます。

```dart
// モッククラスの作成（1行で OK）
class MockTodoRepository extends Mock implements TodoRepository {}
```

### when() — モックの動作を設定

```dart
final mockRepo = MockTodoRepository();

// 「watchTodos() が呼ばれたら、空リストを流す Stream を返す」と設定
when(() => mockRepo.watchTodos())
    .thenAnswer((_) => Stream.value([]));

// 「addTodo() が呼ばれたら、何もしない（正常完了）」と設定
when(() => mockRepo.addTodo(title: 'タスク', description: null))
    .thenAnswer((_) async {});
```

### verify() — メソッドが呼ばれたか検証

```dart
// addTodo が1回だけ呼ばれたことを検証
verify(() => mockRepo.addTodo(title: 'タスク', description: null))
    .called(1);
```

### ProviderContainer — テスト用の Riverpod コンテナ

```dart
final container = ProviderContainer(
  overrides: [
    // テスト用にモックを注入
    todoRepositoryProvider.overrideWithValue(mockRepo),
  ],
);

// プロバイダーの値を読む
final result = await container.read(todoListProvider.future);

// Notifier のメソッドを呼ぶ
await container.read(todoListProvider.notifier).addTodo(title: 'タスク');

// 使い終わったら dispose する
container.dispose();
```

---

## ③ Widget テスト

UI（ウィジェット）の表示内容を検証します。
実機やシミュレーターは不要で、テスト環境内で UI を描画して検証します。

```dart
testWidgets('タスクなし時に空メッセージを表示する', (tester) async {
  // ウィジェットを描画
  await tester.pumpWidget(
    ProviderScope(
      overrides: [todoRepositoryProvider.overrideWithValue(mockRepo)],
      child: MaterialApp(home: TodoListPage()),
    ),
  );

  // フレームを進めて非同期処理（Streamの値）を反映
  await tester.pump();

  // テキストが表示されているか検証
  expect(find.text('タスクはありません\n＋ボタンで追加しましょう'), findsOneWidget);
});
```

### find の種類

```dart
find.text('テキスト')       // テキストで検索
find.byType(FloatingActionButton) // ウィジェットの型で検索
find.byIcon(Icons.add)     // アイコンで検索
find.byKey(Key('myKey'))   // Key で検索
```

### マッチャーの種類

```dart
findsOneWidget   // 1つだけ見つかる
findsNothing     // 見つからない
findsWidgets     // 1つ以上見つかる
findsNWidgets(3) // ちょうど3つ見つかる
```

---

## テストの実行方法

```bash
# 全テストを実行
flutter test

# 特定のファイルだけ実行
flutter test test/data/repositories/todo_repository_impl_test.dart

# カバレッジレポートも生成（どのコードがテストされているか）
flutter test --coverage
```

---

## setUp と tearDown

```dart
late MockTodoRepository mockRepo;
late ProviderContainer container;

// 各テストの「前」に実行
setUp(() {
  mockRepo = MockTodoRepository();
  container = ProviderContainer(...);
});

// 各テストの「後」に実行（リソース解放）
tearDown(() => container.dispose());

// テストファイル全体で1回だけ実行（setUpAll / tearDownAll も使える）
setUpAll(() {
  registerFallbackValue(Todo(...)); // mocktail の事前登録
});
```
