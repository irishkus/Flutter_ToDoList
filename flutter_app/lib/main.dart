import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/ClientModel.dart';
import 'package:flutter_app/Database.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: RandomWords(),
    );
  }
}

class MyStatelessWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hello!');
  }
}

class RandomWordsState extends State<RandomWords> {
  final TextEditingController addTask = new TextEditingController();
  final TextEditingController search = new TextEditingController();
  var searchBool = false;

  Icon actionIcon = Icon(
    Icons.search,
    color: Colors.grey,
  );
  Icon addIcon = Icon(
    Icons.add_circle,
    color: Colors.grey,
  );

  void _onPressed() async {
    if (addTask.text != "") {
      Client rnd = Client(toDo: addTask.text, done: 0);
      DBProvider.db.newToDo(rnd);
      addTask.clear();
      await DBProvider.db.getAll();
      setState(() {});
    }
  }

  Widget _appBarTitle = new Text('To Do List');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (this.actionIcon.icon == Icons.search) {
                  this.actionIcon = new Icon(
                    Icons.close,
                    color: Colors.grey,
                  );
                  this._appBarTitle = TextField(
                    controller: search,
                    autofocus: true,
                    onChanged: (text) async {
                      if (!(text.isEmpty)) {
                        searchBool = true;
                        await DBProvider.db.getSearch(
                            "%" + text.toLowerCase().trim() + "%");
                        setState(() {});
                      } else {
                        searchBool = false;
                        await DBProvider.db.getAll();
                        setState(() {});
                      }
                    },
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                    decoration: InputDecoration(
                        prefixIcon: new Icon(Icons.search, color: Colors.grey),
                        hintText: "Search...",
                        hintStyle: TextStyle(color: Colors.grey)),
                  );
                } else {
                  searchBool = false;

                  this.actionIcon = new Icon(
                    Icons.search,
                    color: Colors.grey,
                  );
                  //filtered = toDo;
                  this._appBarTitle = new Text(
                    "To Do List",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  );
                  search.clear();
                }
              });
            },
          ),
        ],
      ),
      body: new Column(
        children: <Widget>[
          Divider(height: 3.0, indent: 5.0, color: Colors.grey),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: new TextField(
                          controller: addTask,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0), width: 1.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0.0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0), width: 1.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0.0)),
                            ),
                            hintText: "Add a task",
                          ),
                          onChanged: (text) {
                            if (addTask.text.isEmpty) {
                              addIcon =
                                  Icon(Icons.add_circle, color: Colors.grey);
                            } else {
                              addIcon = Icon(Icons.add_circle,
                                  color: Color(0xFF177081));
                            }
                            setState(() {});
                          },
                          onSubmitted: (text) {
                            if (addTask.text != "") {
                              Client rnd = Client(toDo: addTask.text, done: 0);
                              DBProvider.db.newToDo(rnd);
                              addTask.clear();
                              DBProvider.db.getAll();
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                new OutlineButton.icon(
                    onPressed: _onPressed,
                    padding: EdgeInsets.fromLTRB(0, 17, 0, 17),
                    clipBehavior: Clip.none,
                    icon: addTask.text == ""
                        ? addIcon
                        : Icon(Icons.add_circle, color: Color(0xFF177081)),
                    label: new Text('ADD')),
              ],
            ),
          ),
          new Expanded(
              child: FutureBuilder<List<Client>>(
                  future: searchBool
                      ? DBProvider.db.getSearch(
                          "%" + search.text.toLowerCase().trim() + "%")
                      : DBProvider.db.getAll(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Client>> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.separated(
                          itemCount: snapshot.data.length,
                          separatorBuilder: (BuildContext context, int i) =>
                              Divider(),
                          itemBuilder: (BuildContext context, int i) {
                            if (i < snapshot.data.length) {
                              Client item = snapshot.data[i];
                              return Dismissible(
                                key: UniqueKey(),
                                background: Container(color: Colors.red),
                                onDismissed: (direction) {
                                  DBProvider.db.delete(item.id);
                                  setState(() {});
                                },
                                child: ListTile(
                                  title: Text(item.toDo,
                                      style: new TextStyle(
                                          decoration: item.done == 1
                                              ? TextDecoration.lineThrough
                                              : null)),
                                  trailing: Icon(
                                    item.done == 0
                                        ? Icons.trip_origin
                                        : Icons.check_circle,
                                    color: item.done == 0
                                        ? Color(0xFF177081)
                                        : null,
                                  ),
                                  onTap: () {
                                    if (item.done == 0) {
                                      item.done = 1;
                                      DBProvider.db.update(item);
                                    } else {
                                      item.done = 0;
                                      DBProvider.db.update(item);
                                    }
                                    setState(() {});
                                  },
                                ),
                              );
                            }
                          });
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  })
              )
        ],
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => new RandomWordsState();
}
