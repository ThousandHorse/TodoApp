// ============================================================
// TodoListPage — Presentation層（メイン画面）
// ============================================================
// タスク一覧を表示するメイン画面です。
//
// ■ ConsumerWidget とは？
//   Riverpod の `ConsumerWidget` は、通常の `StatelessWidget` に
//   `WidgetRef ref` が追加されたウィジェットです。
//   `ref` を使ってプロバイダーの値を読んだり監視したりできます。
//
// ■ この画面の責務
//   ・todoListProvider を監視してタスク一覧を表示
//   ・ローディング / エラー / データの3状態を UI で表現
//   ・FAB（＋ボタン）でタスク追加ダイアログを開く
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/todo_providers.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/todo_list_item.dart';

// `ConsumerWidget` を継承することで Riverpod のプロバイダーを監視できます。
class TodoListPage extends ConsumerWidget {
  const TodoListPage({super.key});

  // `WidgetRef ref` は Riverpod が提供するオブジェクト。
  // ref.watch / ref.read でプロバイダーにアクセスします。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // todoListProvider を「監視」する。
    // Firestore のデータが変わるたびに build() が再実行され、UI が更新されます。
    //
    // todoListAsync の型は `AsyncValue<List<Todo>>` で、以下の3状態を持ちます：
    //   AsyncLoading  … Firestore からの初回データ取得中
    //   AsyncData     … データ取得成功
    //   AsyncError    … エラー発生
    final todoListAsync = ref.watch(todoListProvider);

    return Scaffold(
      // AppBar = 画面上部のバー
      appBar: AppBar(title: const Text('Todo'), centerTitle: true),

      // .when() メソッドで AsyncValue の3状態それぞれのUIを定義する。
      // これが Riverpod の AsyncNotifier の最大の特徴のひとつです。
      body: todoListAsync.when(
        // ローディング中はクルクル（スピナー）を表示
        loading: () => const Center(child: CircularProgressIndicator()),

        // エラー時はエラーメッセージを表示
        // `err` にエラー内容、`stack` にスタックトレースが入ります
        error: (err, stack) => Center(child: Text('エラーが発生しました: $err')),

        // データ取得成功時
        data: (todos) => todos.isEmpty
            // タスクが0件の場合は空メッセージを表示
            ? const Center(
                child: Text(
                  'タスクはありません\n＋ボタンで追加しましょう',
                  textAlign: TextAlign.center,
                ),
              )
            // タスクがある場合はリストを表示
            // ListView.separated = 各アイテムの間に区切り線を挟むリスト
            : ListView.separated(
                itemCount: todos.length,
                // 区切り線（Divider）の設定
                separatorBuilder: (context, index) => const Divider(height: 1),
                // index 番目のアイテムを TodoListItem ウィジェットで表示
                itemBuilder: (context, index) =>
                    TodoListItem(todo: todos[index]),
              ),
      ),

      // FAB = Floating Action Button（右下の丸いボタン）
      // タップするとタスク追加ダイアログを開く
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          // `builder: (_)` = context を使わないため `_` で受け捨て
          builder: (_) => const AddTodoDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
