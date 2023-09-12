import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget{

  HomePage();

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight, _deviceWidth;

  String? _newTaskContent;

  Box? box;

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.15,
        title:  const Text("Taskly", 
        style: TextStyle(
          fontSize: 25,
        )),
      ),
      body: _tasksView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopup,
        child: const Icon(
          Icons.note_add_rounded,
        ),
    );
  }

  void _displayTaskPopup() {
    showDialog(context: context, 
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Add New Task!"),
        content: TextField(
          onSubmitted: (_) {
            if (_newTaskContent != null) {
              var task = Task(content: _newTaskContent!, timestamp: DateTime.now(), done: false);
              box!.add(task.toMap());
              setState(() {
                _newTaskContent = null;
                Navigator.pop(context);
              });
            }
          },
          onChanged: (value) {
            setState(() {
              _newTaskContent = value;
            });
          },
        ),
      );
    },);
  }

  Widget _tasksView() {
  return FutureBuilder(
    future: Hive.openBox('tasks'),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.hasData) {
        box = snapshot.data;
        // Return your widget when you have data
        return _taskList();
      } else {
        // Return a loading indicator while waiting for data
        return const Center(
          child: 
              CircularProgressIndicator()
        );
      }
    }
  );
}



  Widget _taskList() {
    // Task newTask = Task(content: "Go to Gymn!", timestamp: DateTime.now(), done: false)
    // box?.add(newTask.toMap());
    List tasks = box!.values.toList();
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        var task = Task.fromMap(tasks[index]);
        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
              decoration: task.done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(task.timestamp.toString()),
          trailing: Icon(
            task.done ? Icons.check_box_outlined : Icons.check_box_outline_blank,
            color: Colors.red,
            ),
            onTap: () {
              task.done = !task.done;
                box!.putAt(index, task.toMap());
              setState(() {});
            },
            onLongPress: () {
              box!.deleteAt(index);
              setState(() {});
            },
        );
      },
    );
    
  }

}