// ============================================================
// AddTodoDialog — Presentation層（タスク追加ダイアログ）
// ============================================================
// 新しいタスクを入力して追加するダイアログです。
//
// ■ ConsumerStatefulWidget とは？
//   状態（_isLoading など）を持ちながら、Riverpod のプロバイダーにも
//   アクセスしたい場合に使います。
//
//   使い分けの目安：
//   ┌──────────────────────────────────────────────────────────┐
//   │ StatelessWidget       … 状態なし、Riverpod なし         │
//   │ ConsumerWidget        … 状態なし、Riverpod あり         │
//   │ StatefulWidget        … 状態あり、Riverpod なし         │
//   │ ConsumerStatefulWidget… 状態あり、Riverpod あり ← これ │
//   └──────────────────────────────────────────────────────────┘
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/todo_providers.dart';

// ConsumerStatefulWidget はウィジェット本体（不変）
class AddTodoDialog extends ConsumerStatefulWidget {
  const AddTodoDialog({super.key});

  // createState() で State クラスのインスタンスを生成する
  @override
  ConsumerState<AddTodoDialog> createState() => _AddTodoDialogState();
}

// _AddTodoDialogState が実際の状態と UI を管理する
// `ConsumerState` を使うことで `ref` が使えます
class _AddTodoDialogState extends ConsumerState<AddTodoDialog> {
  // TextEditingController = TextField の入力内容を管理するコントローラー
  // これを使うことで入力テキストの取得・クリアが簡単にできます
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // ローディング中かどうかを管理する状態変数
  bool _isLoading = false;

  // dispose() = ウィジェットがツリーから削除されたときに呼ばれる。
  // Controller などのリソースをここで解放しないとメモリリークになります。
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose(); // 親クラスの dispose も必ず呼ぶ
  }

  // フォームの送信処理
  Future<void> _submit() async {
    // trim() = 前後の空白を除去する
    final title = _titleController.text.trim();

    // タイトルが空なら何もしない（バリデーション）
    if (title.isEmpty) return;

    // setState() = この中で状態変数を変更すると build() が再実行されUIが更新される
    setState(() => _isLoading = true);

    // Riverpod のプロバイダー経由でタスクを追加する。
    // .notifier = Notifier（操作メソッドを持つ）へのアクセサ
    await ref.read(todoListProvider.notifier).addTodo(
          title: title,
          // 空文字の場合は null として保存（description は任意項目）
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );

    // `mounted` = ウィジェットがまだツリーに存在するかチェック。
    // await の後はウィジェットが破棄されている可能性があるため必ずチェックする。
    if (mounted) Navigator.of(context).pop(); // ダイアログを閉じる
  }

  @override
  Widget build(BuildContext context) {
    // AlertDialog = タイトル + コンテンツ + アクションボタンを持つ標準ダイアログ
    return AlertDialog(
      title: const Text('タスクを追加'),
      content: Column(
        mainAxisSize: MainAxisSize.min, // 内容の高さに合わせてコンパクトに
        children: [
          TextField(
            controller: _titleController, // コントローラーを紐付け
            autofocus: true,             // ダイアログを開いた直後にフォーカス
            decoration: const InputDecoration(
              labelText: 'タイトル *',
              border: OutlineInputBorder(), // 枠線スタイル
            ),
            // キーボードの「完了」ボタンでも送信できるようにする
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12), // ウィジェット間の余白
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'メモ（任意）',
              border: OutlineInputBorder(),
            ),
            maxLines: 3, // 複数行入力を許可
          ),
        ],
      ),
      actions: [
        // キャンセルボタン: ダイアログを閉じるだけ
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        // 追加ボタン:
        //   _isLoading が true のとき onPressed を null にすると
        //   ボタンが自動的に非活性（グレーアウト）になる
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              // ローディング中はスピナーをボタン内に表示
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('追加'),
        ),
      ],
    );
  }
}
