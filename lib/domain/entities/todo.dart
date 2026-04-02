// ============================================================
// Todo エンティティ — Domain層
// ============================================================
// 「エンティティ」とは、アプリが扱うデータの「設計図」です。
// この Todo クラスが 1 件のタスクを表します。
//
// ■ Domain（ドメイン）層とは？
//   Firebase や Flutter の Widget など「外の世界」に依存しない、
//   純粋なビジネスロジックの置き場所です。
//   このファイルは import が freezed_annotation だけで、
//   Firebase も Flutter も使っていません。
// ============================================================

import 'package:freezed_annotation/freezed_annotation.dart';

// build_runner が自動生成するファイルを取り込む宣言。
// `todo.freezed.dart` は dart run build_runner build で生成されます。
part 'todo.freezed.dart';

// @freezed アノテーションを付けると、以下が自動生成されます：
//   ・copyWith()    — 一部フィールドだけ変えた新しいインスタンスを返す
//   ・== / hashCode — 値の比較ができるようになる
//   ・toString()    — デバッグ時に読みやすい文字列になる
@freezed
class Todo with _$Todo {
  // `const factory` コンストラクタが freezed のお作法です。
  // freezed はこれを見て自動生成コードを作ります。
  const factory Todo({
    required String id, // タスクを一意に識別するID (UUID)
    required String title, // タスクのタイトル（必須）
    String? description, // メモ（任意。? は null を許容する型）
    @Default(false) bool isCompleted, // 完了フラグ。省略時は false
    required DateTime createdAt, // 作成日時（必須）
    DateTime? updatedAt, // 更新日時（任意。初回は null）
  }) = _Todo;
  // `= _Todo` は freezed が生成するプライベートクラスの名前です。
}
