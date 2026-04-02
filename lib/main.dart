// ============================================================
// main.dart — アプリのエントリーポイント
// ============================================================
// Flutter アプリは必ずここから始まります。
// このファイルでは以下の3つを行います：
//   1. Firebase の初期化
//   2. Firestore のオフラインキャッシュ設定
//   3. Riverpod の ProviderScope で依存性注入のセットアップ
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/providers/todo_providers.dart';
import 'data/datasources/firestore_todo_datasource.dart';
import 'data/repositories/todo_repository_impl.dart';
import 'firebase_options.dart';
import 'presentation/pages/todo_list_page.dart';

// `async` を付けることで、main 関数内で `await` が使えます。
// Flutter の非同期処理は `async/await` で書くのが基本です。
void main() async {
  // Flutter エンジンの初期化を確実に完了させる。
  // main() 内で `await` を使う場合は必ず最初に呼ぶ必要があります。
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase を初期化する。
  // `firebase_options.dart` は `flutterfire configure` で自動生成される
  // プラットフォーム（iOS/Android/Web）ごとの設定ファイルです。
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 【技術検証: オフライン対応】
  // Firestore のローカルキャッシュを有効化する。
  // ・persistenceEnabled: true  … オフライン時もキャッシュからデータを読む
  // ・CACHE_SIZE_UNLIMITED       … キャッシュサイズの上限なし
  //
  // この設定により：
  //   オンライン  → Firestore サーバーからデータ取得 + ローカルに保存
  //   オフライン  → ローカルキャッシュからデータを返す（Stream も流れ続ける）
  //   再接続時    → 未送信の書き込みをサーバーに自動同期
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(
    // ProviderScope = Riverpod を使うために必須のウィジェット。
    // アプリ全体をこれで囲むことで、どこからでもプロバイダーにアクセスできます。
    ProviderScope(
      overrides: [
        // 【依存性注入（DI）】
        // todoRepositoryProvider の「本番実装」をここで登録します。
        //
        // todo_providers.dart では UnimplementedError を throw するだけの
        // プロバイダーを定義しましたが、ここで実際のクラスに差し替えます。
        //
        // 依存の流れ:
        //   ProviderScope
        //     → todoRepositoryProvider = TodoRepositoryImpl
        //         → FirestoreTodoDatasource
        //             → FirebaseFirestore.instance（本物の Firestore）
        todoRepositoryProvider.overrideWithValue(
          TodoRepositoryImpl(
            FirestoreTodoDatasource(FirebaseFirestore.instance),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// アプリのルートウィジェット。
// `StatelessWidget` = 状態を持たない（変化しない）ウィジェット。
// アプリ全体のテーマとホーム画面を設定するだけなので StatelessWidget で十分。
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // `build` メソッドが UI を組み立てます。
  // Flutter の UI はウィジェットのツリー（入れ子）で構成されます。
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        // Material 3 のカラーシステム。seedColor からパレット全体を自動生成。
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true, // Material Design 3 を有効化
      ),
      home: const TodoListPage(), // 最初に表示する画面
    );
  }
}
