// ============================================================
// TodoRepositoryImpl — Data層（リポジトリの具体的な実装）
// ============================================================
// Domain層の `TodoRepository` インターフェースを実装したクラスです。
//
// ■ リポジトリパターンの役割
//   UI（Notifier）はこのクラスの存在を直接知りません。
//   UI は `TodoRepository` インターフェースに対してコードを書き、
//   このクラスは「本番用の実装」として ProviderScope で注入されます。
//
//   テスト時 → モック（偽物）の実装に差し替え
//   本番時   → このクラス（Firebase 実装）を使う
//
// ■ Datasource との違い
//   Datasource … Firestore の生データ（TodoModel）を扱う
//   Repository … TodoModel を Todo（ドメインエンティティ）に変換して返す
// ============================================================

import 'package:uuid/uuid.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/firestore_todo_datasource.dart';
import '../models/todo_model.dart';

// `implements TodoRepository` = インターフェースに定義された全メソッドを
// このクラスが実装することを Dart コンパイラに宣言します。
// 実装漏れがあるとコンパイルエラーになるため安全です。
class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl(this._datasource);

  final FirestoreTodoDatasource _datasource;

  // UUID v4 = ランダムな一意ID生成器。
  // タスク追加時に新しい id を生成するために使います。
  // 例: "550e8400-e29b-41d4-a716-446655440000"
  final _uuid = const Uuid();

  // ── watchTodos ──────────────────────────────────────────────
  // Datasource の Stream<List<TodoModel>> を
  // Stream<List<Todo>>（ドメイン型）に変換して返す。
  //
  // .map() で Stream の各イベント（List<TodoModel>）を
  // List<Todo> に変換しています。
  @override
  Stream<List<Todo>> watchTodos() {
    return _datasource.watchTodos().map(
          (models) => models.map((m) => m.toDomain()).toList(),
        );
  }

  // ── addTodo ─────────────────────────────────────────────────
  // 新しいタスクを追加する。
  //
  // ・_uuid.v4() でユニークな id を生成
  // ・TodoModel を作成して Datasource に渡す
  // ・Repository は「ドメインの言葉（title, description）」で受け取り、
  //   内部で TodoModel（データ層の言葉）に変換する
  @override
  Future<void> addTodo({required String title, String? description}) async {
    final model = TodoModel(
      id: _uuid.v4(),         // ランダムな一意 ID を生成
      title: title,
      description: description,
      isCompleted: false,      // 新規タスクは未完了から始まる
      createdAt: DateTime.now(),
    );
    await _datasource.addTodo(model);
  }

  // ── updateTodo ──────────────────────────────────────────────
  // ドメインエンティティ（Todo）を受け取り、TodoModel に変換して更新。
  @override
  Future<void> updateTodo(Todo todo) async {
    final model = TodoModel.fromDomain(todo); // エンティティ → モデルに変換
    await _datasource.updateTodo(model);
  }

  // ── deleteTodo ──────────────────────────────────────────────
  // id だけを Datasource に渡して削除。
  // Repository は TodoModel の存在を意識せず、id だけで済む。
  @override
  Future<void> deleteTodo(String id) async {
    await _datasource.deleteTodo(id);
  }
}
