import 'package:get/get.dart';
import 'package:nodex/db/db_helper.dart';
import 'package:nodex/models/task.dart';

class TaskController extends GetxController {
  @override
  void onReady() {
    getTasks();
    super.onReady();
  }

  var taskList = <Task>[].obs;

  Future<int> addTask({Task? task}) async {
    return await DBHelper.insert(task);
  }

  //get all data from table
  void getTasks() async {
    List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => new Task.fromJSON(data)).toList());
  }

  void deleteTask(Task task) async {
    await DBHelper.delete(task);
    //after deleting task, we are updating the taskList list
    getTasks();
  }

  void markTaskCompleted(int id) async {
    await DBHelper.update(id);
    //after marking task as completed, we are updating the taskList list
    getTasks();
  }
}
