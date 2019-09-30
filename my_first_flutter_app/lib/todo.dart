import 'package:flutter/material.dart';

import 'fabAnimator.dart';

class Item {
  String name;
  bool isDone;
}

class ToDoWidgetState extends State<ToDoWidget> {
  final _todoItemsId = <int>[];
  final _todoItemsMap = <int, String>{};
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _doneItemsId = Set<int>();
  int _id = 0;
  TextEditingController _textFieldController = TextEditingController();

  void _openDoneList(){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _doneItemsId.map(
                (int itemId) {
              return ListTile(
                title: Text(
                  _todoItemsMap[itemId],
                  style: _biggerFont,
                ),
              );
            },
          );
          final List<Widget> divided = ListTile
              .divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Done tasks'),
              backgroundColor: Colors.teal,
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  _onAddItem(){
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add a todo item'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Buy milk"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Save'),
                onPressed: () {
                  setState(() {
                    _todoItemsId.add(_id);
                    _todoItemsMap.putIfAbsent(_id, ()=> _textFieldController.text);
                    _id += 1;
                  });
                  Navigator.of(context).pop();
                },
              )
            ],

          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My To-Do List'),
        actions: <Widget>[      // Add 3 lines from here...
          IconButton(icon: Icon(Icons.check_circle), onPressed: _openDoneList),
        ],                      // ... to here.
      ),
      body: _buildSuggestions(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddItem,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonAnimator: FabAnimator(),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _todoItemsId.length * 2,
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(); /*2*/

          final index = i ~/ 2; /*3*/

          return _buildRow(_todoItemsId[index]);
        });
  }

  Widget _buildListTile(int itemId) {
    final bool alreadySaved = _doneItemsId.contains(itemId);
    return ListTile(
      title: Text(
        _todoItemsMap[itemId],
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.check_box : Icons.check_box_outline_blank,
        color: alreadySaved ? Colors.blue : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _doneItemsId.remove(itemId);
          } else {
            _doneItemsId.add(itemId);
          }
        });
      },
    );
  }
  Widget _buildRow(int itemId) {
    return Dismissible(
      key: Key(itemId.toString()),
      child: _buildListTile(itemId),
      background: Container(
        color: Colors.redAccent,
        child: Text('remove', textAlign: TextAlign.left,),
      ),
      onDismissed: (direction) {
        setState(() {
          _todoItemsId.remove(itemId);
          _todoItemsMap.remove(itemId);
          if (_doneItemsId.contains(itemId)){
            _doneItemsId.remove(itemId);
          }
        });
      },
    );
  }
}



class ToDoWidget extends StatefulWidget {
  @override
  ToDoWidgetState createState() => ToDoWidgetState();
}