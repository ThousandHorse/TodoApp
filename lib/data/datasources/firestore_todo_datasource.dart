// ============================================================
// FirestoreTodoDatasource — Data層（Firestore との直接通信）
// ============================================================
// 「データソース」は、データベースへの直接アクセスだけを担当します。
// Firestore の API を直接叩く唯一の場所であり、
// TodoModel の変換はここで行います。
//
// ■ 責務の分離
//   ┌────────────────────────────────────────────────────┐
//   │ Datasource  … Firestore API を直接呼ぶ             │
//   │ Repository  … Datasource を呼び、Domain に変換する │
//   │ Notifier    … Repository を呼ぶ（Firestore を知らない）│
//   └────────────────────────────────────────────────────┘
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart';

class FirestoreTodoDatasource {
  // コンストラクタで FirebaseFirestore を受け取る（依存性注入）。
  // テスト時は FakeFirebaseFirestore を渡すことで、
  // 本物の Firestore を使わずにテストできます。
  FirestoreTodoDatasource(this._firestore);

  final FirebaseFirestore _firestore;

  // Firestore の 'todos' コレクションへの参照を返すゲッター。
  // コレクション = RDB でいうテーブルに相当するデータのまとまり。
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('todos');

  // ── watchTodos ──────────────────────────────────────────────
  // Firestore をリアルタイム監視し、変化があるたびリストを流す。
  //
  // ・orderBy('createdAt', descending: true) = 作成日時の新しい順にソート
  // ・snapshots() = Firestore の変化を Stream として受け取る（リアルタイム）
  // ・.map() = Stream の各イベントを変換する
  // ・{...doc.data(), 'id': doc.id} = Firestore のドキュメントデータに
  //   ドキュメントID（'id'）を追加して TodoModel に変換
  Stream<List<TodoModel>> watchTodos() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TodoModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  // ── addTodo ─────────────────────────────────────────────────
  // 新しいタスクを Firestore に追加する。
  //
  // ・toJson()..remove('id') = id フィールドを除外（Firestore のドキュメントID
  //   として doc(model.id).set() で指定するため、フィールドとしては不要）
  // ・doc(model.id).set(data) = 指定した ID でドキュメントを作成
  Future<void> addTodo(TodoModel model) async {
    final data = model.toJson()..remove('id'); // id はドキュメントIDで管理
    await _collection.doc(model.id).set(data);
  }

  // ── updateTodo ──────────────────────────────────────────────
  // 既存タスクを更新する。
  //
  // ・FieldValue.serverTimestamp() = Firestore サーバー側の現在時刻を自動設定。
  //   クライアントの時刻よりも信頼性が高い。
  // ・update() = 指定したフィールドだけを上書き（set() は全フィールドを上書き）
  Future<void> updateTodo(TodoModel model) async {
    final data = model.toJson()
      ..remove('id') // ドキュメントIDはフィールドに含めない
      ..['updatedAt'] = FieldValue.serverTimestamp(); // サーバー側の時刻で上書き
    await _collection.doc(model.id).update(data);
  }

  // ── deleteTodo ──────────────────────────────────────────────
  // 指定した id のドキュメントを Firestore から削除する。
  Future<void> deleteTodo(String id) async {
    await _collection.doc(id).delete();
  }
}
