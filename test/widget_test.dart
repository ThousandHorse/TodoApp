// ============================================================
// Widget テスト — TodoListPage
// ============================================================
// UI（ウィジェット）の表示内容を検証するテストです。
//
// ■ Widget テストとは？
//   実機やシミュレーターを使わずに、ウィジェットの描画結果を
//   テスト環境内で検証できます。
//   ・高速（ネットワーク・デバイス不要）
//   ・UI の回帰テスト（意図しない表示変化を検知）に有効
//
// ■ testWidgets の流れ
//   1. tester.pumpWidget() … テスト用のウィジェットツリーを構築
//   2. tester.pump()       … フレームを進めてアニメーション・非同期を処理
//   3. expect(find.xxx, findsOneWidget) … UIに表示されているか検証
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/application/providers/todo_providers.dart';
import 'package:todo_app/domain/entities/todo.dart';
import 'package:todo_app/domain/repositories/todo_repository.dart';
import 'package:todo_app/presentation/pages/todo_list_page.dart';

// テスト用のモックリポジトリ
class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockTodoRepository mockRepo;

  setUp(() {
    mockRepo = MockTodoRepository();
  });

  testWidgets('タスクなし時に空メッセージを表示する', (tester) async {
    // watchTodos() が空リストを流す Stream を返すように設定
    when(() => mockRepo.watchTodos()).thenAnswer((_) => Stream.value([]));

    // ProviderScope でモックを注入してウィジェットを構築
    // テスト環境では MaterialApp で囲む必要があります
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todoRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(home: TodoListPage()),
      ),
    );

    // pump() で Stream の値が UI に反映されるまで1フレーム進める
    await tester.pump();

    // find.text() = 指定したテキストを持つウィジェットを探す
    // findsOneWidget = 1つだけ見つかることを期待
    expect(find.text('タスクはありません\n＋ボタンで追加しましょう'), findsOneWidget);
  });

  testWidgets('タスクがある場合にリストを表示する', (tester) async {
    final todo = Todo(
      id: '1',
      title: 'サンプルタスク',
      isCompleted: false,
      createdAt: DateTime(2024),
    );
    // 1件のタスクを流す Stream を返すように設定
    when(() => mockRepo.watchTodos()).thenAnswer((_) => Stream.value([todo]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todoRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(home: TodoListPage()),
      ),
    );
    await tester.pump();

    // タスクのタイトルが画面に表示されているか検証
    expect(find.text('サンプルタスク'), findsOneWidget);
  });
}
