// ============================================================
// EditTodoDialog — Presentation層（タスク編集ダイアログ）
// ============================================================
// 既存タスクのタイトルとメモを編集するダイアログです。
// AddTodoDialog と似た構造ですが、既存データの初期値設定が異なります。
//
// ■ AddTodoDialog との違い
//   ・initState() でコントローラーに既存データを初期値として設定する
//   ・送信時に「新規追加」ではなく「既存タスクの更新」を行う
//   ・`widget.todo` で親ウィジェット（ConsumerStatefulWidget）の
//     プロパティにアクセスする
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/todo_providers.dart';
import '../../domain/entities/todo.dart';

class EditTodoDialog extends ConsumerStatefulWidget {
  const EditTodoDialog({super.key, required this.todo});

  // 編集対象のタスクを受け取る（外から渡してもらう）
  final Todo todo;

  @override
  ConsumerState<EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends ConsumerState<EditTodoDialog> {
  // `late` = 後で必ず初期化されることを保証する宣言。
  // initState() で初期化するため、ここでは値を入れられない。
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;

  // initState() = ウィジェットが最初に作られたときに1回だけ呼ばれる。
  // コントローラーに編集対象タスクの既存データを初期値として設定します。
  @override
  void initState() {
    super.initState(); // 親クラスの initState を先に呼ぶ
    // `widget.プロパティ名` で ConsumerStatefulWidget のフィールドにアクセス
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController =
        TextEditingController(text: widget.todo.description ?? '');
    // `?? ''` = null なら空文字を使う（null 合体演算子）
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // フォームの送信処理（更新）
  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isLoading = true);

    // `widget.todo.copyWith(...)` で変更したフィールドだけを更新した
    // 新しい Todo オブジェクトを作成（freezed の copyWith を使用）。
    // 元のオブジェクトは変更せず、新しいオブジェクトを作ります（イミュータブル）。
    await ref.read(todoListProvider.notifier).updateTodo(
          widget.todo.copyWith(
            title: title,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
          ),
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('タスクを編集'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'タイトル *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'メモ（任意）',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('保存'),
        ),
      ],
    );
  }
}
