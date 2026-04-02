// ============================================================
// TodoRepository インターフェース — Domain層
// ============================================================
// 「インターフェース」とは、クラスが持つべきメソッドの一覧表です。
// 実際の処理内容はここに書かず、メソッドの名前と型だけを定義します。
//
// ■ なぜインターフェースを使うの？
//   実装（Firebase）と仕様（何ができるか）を分離するためです。
//
//   たとえば「テスト時は Firestore を使いたくない」場合、
//   このインターフェースを満たす「モック（偽物）」クラスに
//   差し替えるだけで済みます。
//
//   UI や Notifier はこのインターフェースだけを知っていれば良く、
//   「Firebase に繋がっているか？モックか？」を気にしません。
// ============================================================

import '../entities/todo.dart';

// `abstract interface class` = Dart の純粋インターフェース定義。
// このクラス自体はインスタンス化できません（設計図なので）。
abstract interface class TodoRepository {
  // Firestore をリアルタイム監視し、変化があるたびリストを流す Stream。
  // Stream = 「データの川」。データが変わると自動で新しい値が流れてきます。
  Stream<List<Todo>> watchTodos();

  // タスクを新規追加する。
  // `Future<void>` = 非同期処理で、完了するまで待つが返り値はない。
  // `required` = 呼び出し時に必ず指定しなければならない名前付き引数。
  Future<void> addTodo({required String title, String? description});

  // 既存タスクを更新する（完了フラグ変更・タイトル編集など）。
  Future<void> updateTodo(Todo todo);

  // 指定した id のタスクを削除する。
  Future<void> deleteTodo(String id);
}
