import 'package:flutter/material.dart';
import 'package:dayos_book_app/tasks/TasksDBWorker.dart';
import 'package:dayos_book_app/tasks/TasksModel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

class TasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<TasksModel>(
      model: tasksModel,
      child: ScopedModelDescendant(
        builder: (BuildContext inContext, Widget inChild, TasksModel inTask) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                tasksModel.entityBeingEdited = Task();
                tasksModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              itemCount: tasksModel.entityList.length,
              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                Task task = tasksModel.entityList[inIndex];
                String sDueDate;
                if (task.dueDate != null) {
                  List dateParts = task.dueDate.split(",");
                  DateTime dueDate = DateTime(int.parse(dateParts[0]),
                      int.parse(dateParts[1]), int.parse(dateParts[2]));
                  sDueDate =
                      DateFormat.yMMMMd("en_US").format(dueDate.toLocal());
                }
                return Slidable(
                  delegate: SlidableDrawerDelegate(),
                  actionExtentRatio: .25,
                  child: ListTile(
                    leading: Checkbox(
                      value: task.completed == "true" ? true : false,
                      onChanged: (inValue) async {
                        task.completed = inValue.toString();
                        await TasksDBWorker.db.update(task);
                        tasksModel.loadData("tasks", TasksDBWorker.db);
                      },
                    ),
                    title: Text("${task.description}",
                        style: task.completed == "true"
                            ? TextStyle(
                                color: Theme.of(inContext).disabledColor,
                                decoration: TextDecoration.lineThrough)
                            : TextStyle(
                                color: Theme.of(inContext)
                                    .textTheme
                                    .headline6
                                    .color)),
                    subtitle: task.dueDate == null
                        ? null
                        : Text(
                            sDueDate,
                            style: task.completed == "true"
                                ? TextStyle(
                                    color: Theme.of(inContext).disabledColor,
                                    decoration: TextDecoration.lineThrough)
                                : TextStyle(
                                    color: Theme.of(inContext)
                                        .textTheme
                                        .headline6
                                        .color),
                          ),
                    onTap: () async {
                      if (task.completed == "true") return;
                      tasksModel.entityBeingEdited =
                          await TasksDBWorker.db.get(task.id);
                      if (tasksModel.entityBeingEdited.dueDate == null) {
                        tasksModel.setChosenDate(null);
                      } else {
                        tasksModel.setChosenDate(sDueDate);
                      }
                      tasksModel.setStackIndex(1);
                    },
                  ),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                        caption: "Delete",
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () => _deleteTask(inContext, task))
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future _deleteTask(BuildContext inContext, Task inTask) {
    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
            title: Text("Delete Task"),
            content: Text("Are you sure about deleting ${inTask.description}?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                color: Colors.red,
                onPressed: () {
                  Navigator.of(inAlertContext).pop();
                },
              ),
              FlatButton(
                child: Text("Confirm"),
                color: Colors.lightBlue,
                onPressed: () async {
                  await TasksDBWorker.db.delete((inTask.id));
                  Navigator.of(inAlertContext).pop();
                  Scaffold.of(inContext).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text("Task deleted"),
                  ));
                  tasksModel.loadData("tasks", TasksDBWorker.db);
                },
              )
            ],
          );
        });
  }
}