// ============================================================
// TodoListItem — Presentation層（1件のタスク表示ウィジェット）
// ============================================================
// リスト内の1件分のタスクを表示する再利用可能なウィジェットです。
//
// ■ 表示内容
//   [チェックボックス] タイトル（完了時は取り消し線）   [編集] [削除]
//                    メモ（あれば1行表示）
//
// ■ ConsumerWidget を使う理由
//   チェックボックスのタップや削除ボタンのタップ時に
//   todoListProvider.notifier のメソッドを呼ぶ必要があるため。
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/todo_providers.dart';
import '../../domain/entities/todo.dart';
import 'edit_todo_dialog.dart';

class TodoListItem extends ConsumerWidget {
  // `required this.todo` = コンストラクタで Todo を必ず受け取る
  const TodoListItem({super.key, required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ListTile = アイコン + テキスト + 末尾アクションを並べる標準ウィジェット
    return ListTile(
      // leading = 左端に表示するウィジェット（チェックボックス）
      leading: Checkbox(
        value: todo.isCompleted, // 現在の完了状態を反映
        onChanged: (_) =>
            // チェックが変わったら toggleCompleted を呼ぶ。
            // `.notifier` = プロバイダーのメソッドを呼ぶためのアクセサ。
            ref.read(todoListProvider.notifier).toggleCompleted(todo),
      ),

      // タイトルを表示。完了済みは取り消し線スタイルを適用。
      title: Text(
        todo.title,
        style: todo.isCompleted
            // 三項演算子: 条件 ? trueの値 : falseの値
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null, // null の場合はデフォルトスタイル
      ),

      // subtitle = タイトルの下に小さく表示するサブテキスト
      // description が null なら subtitle を表示しない（null を渡す）
      subtitle: todo.description != null
          ? Text(
              todo.description!,
              // `!` = null でないことを開発者が保証する（null チェック済み）
              maxLines: 1,                        // 最大1行まで
              overflow: TextOverflow.ellipsis,    // 溢れたら「...」で省略
            )
          : null,

      // trailing = 右端に表示するウィジェット（編集・削除ボタン）
      trailing: Row(
        // mainAxisSize.min = Row の幅をコンテンツの最小サイズに合わせる
        // （これがないと Row が横幅いっぱいに広がってしまう）
        mainAxisSize: MainAxisSize.min,
        children: [
          // 編集ボタン: タップで EditTodoDialog を開く
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => EditTodoDialog(todo: todo),
            ),
          ),
          // 削除ボタン: タップで deleteTodo を呼ぶ
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => ref
                .read(todoListProvider.notifier)
                .deleteTodo(todo.id),
          ),
        ],
      ),
    );
  }
}
