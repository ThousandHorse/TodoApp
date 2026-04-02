// ============================================================
// TodoRepositoryImpl テスト
// ============================================================
// TodoRepositoryImpl（Data層のリポジトリ）の動作を検証します。
//
// ■ fake_cloud_firestore とは？
//   本物の Firestore の代わりに使えるインメモリ版の Firestore です。
//   ・実際の Firebase プロジェクトが不要
//   ・テストが高速（ネットワーク通信なし）
//   ・setUp() でリセットされるため、テスト間で干渉しない
// ============================================================

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/datasources/firestore_todo_datasource.dart';
import 'package:todo_app/data/repositories/todo_repository_impl.dart';

void main() {
  // `late` = テストごとに setUp() で初期化するため、ここでは宣言のみ
  late FakeFirebaseFirestore fakeFirestore;
  late TodoRepositoryImpl repository;

  // setUp() = 各テスト（test()）の前に必ず実行される準備処理
  // FakeFirestore は毎回新しく作ることでテスト間のデータ汚染を防ぐ
  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = TodoRepositoryImpl(
      FirestoreTodoDatasource(fakeFirestore), // 偽の Firestore を注入
    );
  });

  // group() = 関連するテストをまとめるグループ
  group('TodoRepositoryImpl', () {
    // test() の命名規則: 「何をしたら（操作）→ どうなるか（期待）」
    test('addTodo → watchTodos でタスクが取得できる', () async {
      // 【Arrange】準備: タスクを追加する
      await repository.addTodo(title: 'テストタスク');

      // 【Act + Assert】実行 & 検証
      // .first = Stream の最初の値を1つ取り出す（テスト用の書き方）
      final todos = await repository.watchTodos().first;

      // expect(実際の値, 期待値) で検証
      expect(todos.length, 1);
      expect(todos.first.title, 'テストタスク');
      expect(todos.first.isCompleted, false); // 新規タスクは未完了
    });

    test('addTodo で description も保存できる', () async {
      await repository.addTodo(title: 'タイトル', description: 'メモ内容');

      final todos = await repository.watchTodos().first;
      expect(todos.first.description, 'メモ内容');
    });

    test('updateTodo で isCompleted が更新される', () async {
      // 追加してから取得
      await repository.addTodo(title: '更新テスト');
      final before = (await repository.watchTodos().first).first;

      // copyWith で isCompleted だけ変えた新しい Todo を作って更新
      await repository.updateTodo(before.copyWith(isCompleted: true));

      // 更新後のデータを取得して検証
      final after = (await repository.watchTodos().first).first;
      expect(after.isCompleted, true);
    });

    test('deleteTodo でタスクが削除される', () async {
      await repository.addTodo(title: '削除テスト');
      final todo = (await repository.watchTodos().first).first;

      await repository.deleteTodo(todo.id);

      // isEmpty = リストが空であることを検証するマッチャー
      final todos = await repository.watchTodos().first;
      expect(todos, isEmpty);
    });

    test('複数タスク追加後に全件取得できる', () async {
      await repository.addTodo(title: 'タスク1');
      await repository.addTodo(title: 'タスク2');
      await repository.addTodo(title: 'タスク3');

      final todos = await repository.watchTodos().first;
      expect(todos.length, 3);
    });
  });
}
