# Flutter 基礎知識

## ウィジェットとは？

Flutter の UI はすべて **ウィジェット** で構成されます。
ウィジェットは「UIの部品」で、入れ子（ツリー構造）にして画面を作ります。

```dart
// ウィジェットのツリー例
Scaffold(
  appBar: AppBar(title: Text('Todo')),
  body: ListView(
    children: [
      ListTile(title: Text('タスク1')),
      ListTile(title: Text('タスク2')),
    ],
  ),
)
```

---

## ウィジェットの種類

### StatelessWidget — 状態を持たないウィジェット

データが変わっても自分では再描画されません。
外から値を受け取って表示するだけのウィジェットに使います。

```dart
class MyLabel extends StatelessWidget {
  final String text;
  const MyLabel({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}
```

### StatefulWidget — 状態を持つウィジェット

`setState()` を呼ぶと `build()` が再実行されて UI が更新されます。
テキストフィールドのローディング状態など、内部で変化する値に使います。

```dart
class MyCounter extends StatefulWidget {
  @override
  State<MyCounter> createState() => _MyCounterState();
}

class _MyCounterState extends State<MyCounter> {
  int _count = 0; // 状態変数

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => setState(() => _count++), // setState で再描画
      child: Text('$_count'),
    );
  }
}
```

### ConsumerWidget — Riverpod 対応の StatelessWidget

`ref.watch()` でプロバイダーを監視できます。
プロバイダーの値が変わると自動で `build()` が再実行されます。

### ConsumerStatefulWidget — Riverpod 対応の StatefulWidget

`setState()` も `ref` も両方使いたい場合に使います（ダイアログなど）。

---

## このアプリで使った主要ウィジェット

### Scaffold
画面の骨格を作るウィジェット。`AppBar`・`body`・`FloatingActionButton` を配置できます。

```dart
Scaffold(
  appBar: AppBar(title: Text('タイトル')),
  body: Text('本文'),
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
)
```

### ListView.separated
リストを表示するウィジェット。`separatorBuilder` で区切り線を入れられます。

```dart
ListView.separated(
  itemCount: todos.length,
  separatorBuilder: (context, index) => Divider(),
  itemBuilder: (context, index) => Text(todos[index].title),
)
```

### AlertDialog
ダイアログを表示するウィジェット。`showDialog()` と組み合わせて使います。

```dart
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: Text('タイトル'),
    content: Text('内容'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
    ],
  ),
)
```

### ListTile
アイコン + テキスト + 末尾アクションを整列して表示する標準ウィジェット。

```dart
ListTile(
  leading: Icon(Icons.check),          // 左端
  title: Text('タスクのタイトル'),        // メインテキスト
  subtitle: Text('サブテキスト'),        // 小さいサブテキスト
  trailing: IconButton(icon: Icon(Icons.delete), onPressed: () {}), // 右端
)
```

---

## Dart 言語の基礎

### 型とnull安全
```dart
String name = 'Flutter';   // null を入れられない
String? name = null;       // ? を付けると null を入れられる
name ?? 'デフォルト';        // null なら右の値を使う（null 合体演算子）
name!.length;              // null でないことを保証する（null チェック済みを宣言）
```

### async / await
```dart
// Future = 「後で値が返ってくる」非同期処理
Future<void> saveData() async {
  await database.save(data); // save が終わるまで待つ
  print('保存完了');
}
```

### Stream
```dart
// Stream = 「データが流れてくる川」
Stream<List<Todo>> watchTodos() {
  // Firestore の変化があるたびにリストが流れてくる
  return firestore.collection('todos').snapshots().map(...);
}
```

### 三項演算子
```dart
// 条件 ? trueの値 : falseの値
bool isCompleted = true;
String label = isCompleted ? '完了' : '未完了';
```

### スプレッド演算子
```dart
// `...` でMapの内容を展開して新しいMapに追加する
Map<String, dynamic> base = {'title': 'タスク'};
Map<String, dynamic> withId = {...base, 'id': '123'};
// → {'title': 'タスク', 'id': '123'}
```

### カスケード記法（..）
```dart
// `..` = 同じオブジェクトに続けてメソッドを呼ぶ
final data = model.toJson()
  ..remove('id')       // id を除去して
  ..['key'] = 'value'; // さらにフィールドを追加
```
