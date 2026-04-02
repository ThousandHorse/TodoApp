// ============================================================
// TodoList Notifier テスト
// ============================================================
// Application層の TodoList Notifier の動作を検証します。
//
// ■ テスト戦略: モック（Mock）を使った単体テスト
//   TodoList Notifier は TodoRepository に依存していますが、
//   テスト時は Firebase を使いたくありません。
//   そこで mocktail で「偽物のリポジトリ（MockTodoRepository）」を作り、
//   ProviderContainer で注入します。
//
// ■ mocktail の主なメソッド
//   when()   … 「このメソッドが呼ばれたら、この値を返す」と設定
//   verify() … 「このメソッドが呼ばれたか」を検証
//   any()    … 任意の引数にマッチするマッチャー
//   captureAny() … 渡された引数の値をキャプチャして後で検証できる
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/application/providers/todo_providers.dart';
import 'package:todo_app/domain/entities/todo.dart';
import 'package:todo_app/domain/repositories/todo_repository.dart';

// `extends Mock implements TodoRepository` で
// TodoRepository インターフェースを実装したモッククラスを作成。
// モックは実装を書かなくてよく、when() で動作を定義できます。
class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockTodoRepository mockRepo;
  late ProviderContainer container;

  // setUpAll() = テストファイル全体で1回だけ実行される初期化処理
  // `any()` / `captureAny()` で Todo 型を使うには事前に登録が必要
  setUpAll(() {
    registerFallbackValue(
      // any() のフォールバック値（実際には使われないダミー）
      Todo(
        id: 'fallback',
        title: '',
        isCompleted: false,
        createdAt: DateTime(2024),
      ),
    );
  });

  // 各テストの前に新しいモックとコンテナを作成する
  setUp(() {
    mockRepo = MockTodoRepository();
    // ProviderContainer = テスト用の Riverpod コンテナ。
    // overrides でモックリポジトリを注入します。
    container = ProviderContainer(
      overrides: [todoRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  // テスト後にコンテナをクリーンアップ（リソース解放）
  tearDown(() => container.dispose());

  // テスト共通のサンプルデータ
  final sampleTodo = Todo(
    id: 'test-id',
    title: 'テストタスク',
    isCompleted: false,
    createdAt: DateTime(2024),
  );

  group('TodoList Notifier', () {
    test('build() がリポジトリのStreamを監視する', () async {
      // when() で watchTodos() が呼ばれたときの戻り値を設定
      when(
        () => mockRepo.watchTodos(),
      ).thenAnswer((_) => Stream.value([sampleTodo]));

      // `.future` = AsyncNotifier が Stream から最初の値を解決するまで待つ
      final result = await container.read(todoListProvider.future);

      // リポジトリから返ってきた値がそのまま state になっているか確認
      expect(result, [sampleTodo]);
    });

    test('addTodo がリポジトリのaddTodoを呼び出す', () async {
      when(() => mockRepo.watchTodos()).thenAnswer((_) => Stream.value([]));
      when(
        () => mockRepo.addTodo(title: 'New Task', description: null),
      ).thenAnswer((_) async {}); // 非同期で何もしない

      // Notifier のメソッドを実行
      await container
          .read(todoListProvider.notifier)
          .addTodo(title: 'New Task');

      // verify() で「addTodo が1回呼ばれたこと」を検証
      verify(
        () => mockRepo.addTodo(title: 'New Task', description: null),
      ).called(1);
    });

    test('toggleCompleted が isCompleted を反転させて updateTodo を呼ぶ', () async {
      when(
        () => mockRepo.watchTodos(),
      ).thenAnswer((_) => Stream.value([sampleTodo]));
      // any() = どんな Todo 引数でもマッチする
      when(() => mockRepo.updateTodo(any())).thenAnswer((_) async {});

      await container
          .read(todoListProvider.notifier)
          .toggleCompleted(sampleTodo);

      // captureAny() = updateTodo に渡された引数をキャプチャする
      final captured = verify(() => mockRepo.updateTodo(captureAny())).captured;
      final updated = captured.first as Todo;

      // sampleTodo.isCompleted は false → toggleCompleted で true になるはず
      expect(updated.isCompleted, true);
    });

    test('deleteTodo がリポジトリのdeleteTodoを呼び出す', () async {
      when(() => mockRepo.watchTodos()).thenAnswer((_) => Stream.value([]));
      when(() => mockRepo.deleteTodo('test-id')).thenAnswer((_) async {});

      await container.read(todoListProvider.notifier).deleteTodo('test-id');

      verify(() => mockRepo.deleteTodo('test-id')).called(1);
    });
  });
}
