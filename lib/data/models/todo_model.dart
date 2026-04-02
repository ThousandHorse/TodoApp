// ============================================================
// TodoModel — Data層（Firestore との橋渡し役）
// ============================================================
// 「モデル」とは、データベース（Firestore）のデータ形式に
// 合わせた変換クラスです。
//
// ■ TodoModel と Todo エンティティの違い
//   ┌─────────────────┬───────────────────────────────────────┐
//   │ Todo (entity)   │ アプリ内で使う純粋なデータ              │
//   │ TodoModel       │ Firestore と通信するためのデータ        │
//   └─────────────────┴───────────────────────────────────────┘
//   Firestore の日時型（Timestamp）と Dart の DateTime は
//   そのままでは互換性がないため、このクラスで変換します。
//
// ■ @JsonSerializable とは？
//   json_serializable パッケージの機能で、
//   Map<String, dynamic> ↔ クラスの相互変換コードを自動生成します。
//   `dart run build_runner build` で `todo_model.g.dart` が生成されます。
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/todo.dart';

// build_runner が生成する変換コードを取り込む宣言
part 'todo_model.g.dart';

// `explicitToJson: true` により、ネストしたオブジェクトも
// 正しく JSON に変換されます。
@JsonSerializable(explicitToJson: true)
class TodoModel {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;

  // @JsonKey で「このフィールドは独自の変換関数を使う」と指定。
  // Firestore の Timestamp 型は DateTime に手動変換が必要。
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  // nullable（null を許容）な日時フィールドも同様に変換関数を指定。
  @JsonKey(
    fromJson: _nullableTimestampFromJson,
    toJson: _nullableTimestampToJson,
  )
  final DateTime? updatedAt;

  const TodoModel({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.createdAt,
    this.updatedAt,
  });

  // Firestore の Map → TodoModel に変換（自動生成コードに委譲）
  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);

  // TodoModel → Firestore に送る Map に変換（自動生成コードに委譲）
  Map<String, dynamic> toJson() => _$TodoModelToJson(this);

  // ── Timestamp ↔ DateTime 変換ヘルパー ──────────────────────
  // テスト用 FakeFirestore は文字列を返す場合があるため String も対応。
  static DateTime _timestampFromJson(dynamic value) {
    if (value is Timestamp) return value.toDate(); // Firestore の本番用
    if (value is String) return DateTime.parse(value); // テスト用フォールバック
    return DateTime.now(); // 万が一のフォールバック
  }

  // DateTime → Timestamp に変換して Firestore に保存
  static dynamic _timestampToJson(DateTime d) => Timestamp.fromDate(d);

  // null の可能性がある日時フィールド用の変換（updatedAt など）
  static DateTime? _nullableTimestampFromJson(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return null;
  }

  static dynamic _nullableTimestampToJson(DateTime? d) =>
      d != null ? Timestamp.fromDate(d) : null;

  // ── ドメインエンティティ ↔ TodoModel 変換 ──────────────────
  // Firestore から取得した TodoModel をアプリ内で使う Todo に変換
  Todo toDomain() => Todo(
    id: id,
    title: title,
    description: description,
    isCompleted: isCompleted,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  // アプリ内の Todo を Firestore に保存するための TodoModel に変換
  factory TodoModel.fromDomain(Todo todo) => TodoModel(
    id: todo.id,
    title: todo.title,
    description: todo.description,
    isCompleted: todo.isCompleted,
    createdAt: todo.createdAt,
    updatedAt: todo.updatedAt,
  );
}
