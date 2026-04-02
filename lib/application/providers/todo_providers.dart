// ============================================================
// todo_providers.dart — Application層（Riverpod 状態管理）
// ============================================================
// Riverpod の「プロバイダー」と「AsyncNotifier」を定義するファイルです。
//
// ■ Riverpod とは？
//   Flutter の状態管理ライブラリです。
//   「状態」= アプリが今持っているデータ（Todoリストなど）
//   プロバイダーを通じてデータを管理・共有・監視できます。
//
// ■ このファイルの全体像
//   ┌──────────────────────────────────────────────────────────┐
//   │ todoRepositoryProvider … リポジトリを提供するプロバイダー   │
//   │ TodoList (AsyncNotifier) … Todoリストの状態と操作を管理    │
//   └──────────────────────────────────────────────────────────┘
//
// ■ @riverpod アノテーションとコード生成
//   `@riverpod` を付けると、`dart run build_runner build` 実行時に
//   `todo_providers.g.dart` が自動生成され、プロバイダーの定義が
//   完成します。
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';

// build_runner が生成するプロバイダー定義コードを取り込む
part 'todo_providers.g.dart';

// ── todoRepositoryProvider ─────────────────────────────────
// TodoRepository（インターフェース）を提供するプロバイダー。
//
// ■ なぜ UnimplementedError を throw するの？
//   このプロバイダー自体は「存在の宣言」だけで、実際の実装は
//   main.dart の ProviderScope.overrides で注入されます。
//
//   本番:  ProviderScope でリアルな TodoRepositoryImpl を注入
//   テスト: ProviderScope でモック（MockTodoRepository）を注入
//
//   こうすることで UI と Firebase の依存関係が切れ、
//   テストがしやすくなります。
@riverpod
TodoRepository todoRepository(Ref ref) {
  throw UnimplementedError('todoRepositoryProvider must be overridden in ProviderScope');
}

// ── TodoList (AsyncNotifier) ───────────────────────────────
// Todoリストの「状態」と「操作」をまとめたクラスです。
//
// ■ AsyncNotifier とは？
//   非同期データ（Future や Stream）を状態として持つ Notifier です。
//   状態は `AsyncValue<T>` という型で管理され、3つの状態を表現できます：
//     ・AsyncLoading  … ロード中
//     ・AsyncData     … データ取得成功
//     ・AsyncError    … エラー発生
//
// ■ build() が Stream を返す設計のメリット
//   build() で Firestore の Stream を返すと、
//   Firestore のデータが変わるたびに state が自動更新されます。
//   addTodo/deleteTodo 後に手動で state を更新する必要がありません！
//
// ■ ref.watch vs ref.read
//   ref.watch … 値が変わったら build() を再実行（監視）
//   ref.read  … 一度だけ値を読む（操作メソッド内で使う）
@riverpod
class TodoList extends _$TodoList {
  // build() は Notifier が初めて使われたとき（と依存が変わったとき）に呼ばれる。
  // Firestore の watchTodos() Stream をそのまま返すことで、
  // Firestore の変化が即座に UI に反映されます。
  @override
  Stream<List<Todo>> build() {
    return ref.watch(todoRepositoryProvider).watchTodos();
  }

  // ── addTodo ───────────────────────────────────────────────
  // タスクを追加する。
  // Firestore に書き込むと watchTodos の Stream に変化が流れ、
  // state が自動更新されます（手動で state を変える必要なし）。
  Future<void> addTodo({required String title, String? description}) async {
    await ref.read(todoRepositoryProvider).addTodo(
          title: title,
          description: description,
        );
  }

  // ── toggleCompleted ───────────────────────────────────────
  // 完了フラグを反転する（未完了 → 完了、完了 → 未完了）。
  // `todo.copyWith(isCompleted: !todo.isCompleted)` は
  // freezed が自動生成した `copyWith` メソッドを使っています。
  // 「元の todo の isCompleted だけを反転した新しいオブジェクト」を作ります。
  Future<void> toggleCompleted(Todo todo) async {
    await ref.read(todoRepositoryProvider).updateTodo(
          todo.copyWith(isCompleted: !todo.isCompleted),
        );
  }

  // ── updateTodo ────────────────────────────────────────────
  // タイトルやメモを更新する（編集ダイアログから呼ばれる）。
  Future<void> updateTodo(Todo todo) async {
    await ref.read(todoRepositoryProvider).updateTodo(todo);
  }

  // ── deleteTodo ────────────────────────────────────────────
  // 指定した id のタスクを削除する。
  Future<void> deleteTodo(String id) async {
    await ref.read(todoRepositoryProvider).deleteTodo(id);
  }
}
