import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String title = '';
  String desc = '';
  bool isChecked = false;
  List todos = [];

  createTodo() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('MyTodos').doc(title);

    Map<String, dynamic> todoList = {
      'todoTitle': title,
      'todoDesc': desc,
      'isChecked': isChecked,
    };

    documentReference
        .set(todoList)
        .whenComplete(() => print('data created successfully'));
  }

  deleteTodo(item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('MyTodos').doc(item);

    documentReference.delete().whenComplete(() => print('Item deleted'));
  }

  checkTodo(item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('MyTodos').doc(item);

    documentReference.update({'isChecked': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do App'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: const Text('Add a todo'),
                content: SizedBox(
                  height: 100,
                  width: 400,
                  child: Column(
                    children: [
                      TextField(
                        onChanged: ((value) {
                          title = value;
                        }),
                      ),
                      TextField(
                        onChanged: (value) {
                          desc = value;
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        // todos.add(title);
                        createTodo();
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('ADD'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('MyTodos').snapshots(),
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const Text('error');
          } else if (snapshot.hasData || snapshot.data != null) {
            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: ((context, index) {
                return Card(
                  elevation: 4,
                  child: Dismissible(
                    onDismissed: (direction) {
                      setState(() {
                        // todos.removeAt(index);
                        deleteTodo(snapshot.data?.docs[index]['todoTitle']);
                      });
                    },
                    key: UniqueKey(),
                    child: ListTile(
                      leading: Checkbox(
                          value: snapshot.data?.docs[index]['isChecked'],
                          onChanged: ((value) {
                            setState(() {
                              checkTodo(
                                  snapshot.data?.docs[index]['todoTitle']);
                            });
                          })),
                      title: Text(snapshot.data?.docs[index]['todoTitle']),
                      subtitle: Text(snapshot.data?.docs[index]['todoDesc']),
                      trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              // todos.removeAt(index);
                              deleteTodo(
                                  snapshot.data?.docs[index]['todoTitle']);
                            });
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          )),
                    ),
                  ),
                );
              }),
            );
          }
          return Container();
        }),
      ),
    );
  }
}
