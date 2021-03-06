import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nodex/controllers/task_controller.dart';
import 'package:nodex/models/task.dart';
import 'package:nodex/services/notification_services.dart';
import 'package:nodex/services/theme_services.dart';
import 'package:intl/intl.dart';
import 'package:nodex/ui/add_task_bar.dart';
import 'package:nodex/ui/theme.dart';
import 'package:nodex/ui/widgets/button.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:nodex/ui/widgets/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());
  var notifyHelper;
  int noDataCounter = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: context.theme.backgroundColor,
      body: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            _addTaskBar(),
            _addDateBar(),
            SizedBox(height: 10),
            _showTasks(),
          ],
        ),
      ),
    );
  }

  _showTasks() {
    return Expanded(child: Obx(() {
      if (_taskController.taskList.length > 0) {
        return ListView.builder(
            itemCount: _taskController.taskList.length,
            itemBuilder: (_, index) {
              Task task = _taskController.taskList[index];
              print(task.toJson());
              var selectedDate = DateFormat.yMd().format(_selectedDate);
              var todaysDate =
                  DateFormat.yMd().format(DateTime.now()).toString();
              var taskDate = DateFormat.yMd().parse(task.date.toString());
              if (task.date!.compareTo(todaysDate) < 0)
                return Container();
              else {
                int taym = (int.parse(task.startTime!.split(":")[0]) * 60) +
                    (int.parse(task.startTime!.split(":")[1])) -
                    (int.parse(task.remind.toString()));
                int newhour = taym ~/ 60;
                int newMin = taym % 60;
                if (task.repeat == 'Daily') {
                  if (task.date!.compareTo(selectedDate) < 0) {
                    //DateTime date = DateFormat.jm().parse(task.startTime.toString());
                    //var myTime = DateFormat("HH:mm").format(date);
                    notifyHelper.scheduledNotification(newhour, newMin, task);
                    return _showTask(index, task);
                  }
                }
                if (task.repeat == 'Weekly') {
                  if (DateFormat('EEEE').format(taskDate) ==
                      DateFormat('EEEE').format(_selectedDate)) {
                    notifyHelper.scheduledNotification(newhour, newMin, task);
                    return _showTask(index, task);
                  }
                }
                if (task.repeat == 'Monthly') {
                  if (taskDate.day == _selectedDate.day) {
                    notifyHelper.scheduledNotification(newhour, newMin, task);
                    return _showTask(index, task);
                  }
                }
                if (task.repeat == 'None' &&
                    task.date == DateFormat.yMd().format(_selectedDate)) {
                  notifyHelper.scheduledNotification(newhour, newMin, task);
                  return _showTask(index, task);
                } else {
                  noDataCounter++;
                  return noDataCounter < 2 ? noData() : Container();
                }
              }
            });
      } else
        return noData();
    }));
  }

  Widget noData() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        child: Center(
          child: Column(
            children: [
              Image.asset(
                "images/no-data.png",
                width: 100,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                padding: EdgeInsets.all(5),
                child: Text(
                  "No Data Found",
                  style: GoogleFonts.lato(
                      textStyle: TextStyle(color: pinkClr, fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AnimationConfiguration _showTask(int index, Task task) {
    return AnimationConfiguration.staggeredList(
        position: index,
        child: SlideAnimation(
            child: FadeInAnimation(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  _showBottomSheet(context, task);
                },
                child: TaskTile(task),
              )
            ],
          ),
        )));
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(Container(
      padding: EdgeInsets.only(top: 5),
      height: MediaQuery.of(context).size.height * 0.32,
      color: Get.isDarkMode ? darkGreyClr : white,
      child: Column(
        children: [
          Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
              )),
          Spacer(),
          task.isCompleted == 1
              ? _bottomSheetButton(
                  label: "Task Incomplete",
                  onTap: () {
                    _taskController.markTaskIncompleted(task.id!);
                    Get.back();
                  },
                  clr: primaryClr,
                  context: context)
              : _bottomSheetButton(
                  label: "Task Completed",
                  onTap: () {
                    _taskController.markTaskCompleted(task.id!);
                    Get.back();
                  },
                  clr: primaryClr,
                  context: context),
          SizedBox(height: 4),
          _bottomSheetButton(
              label: "Update Task",
              onTap: () {
                Get.to(() => AddTaskPage(purpose: "update", task: task));
                //_taskController.getTasks();
                //_taskController.updateTask(task);
                //Get.back();
              },
              clr: yellowClr,
              context: context),
          SizedBox(height: 4),
          _bottomSheetButton(
              label: "Delete Task",
              onTap: () {
                _taskController.deleteTask(task);
                Get.back();
              },
              clr: pinkClr,
              context: context),
          SizedBox(height: 12),
          _bottomSheetButton(
              label: "Close",
              onTap: () {
                Get.back();
              },
              clr: white,
              isClose: true,
              context: context),
          Spacer(),
        ],
      ),
    ));
  }

  _bottomSheetButton(
      {required String label,
      required Function()? onTap,
      required Color clr,
      bool isClose = false,
      required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        height: 45,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: isClose ? Colors.grey : clr),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Center(
            child: Text(label,
                style:
                    isClose ? titleStyle : titleStyle.copyWith(color: white))),
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: DatePicker(
        DateTime.now(),
        height: 80,
        width: 60,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        selectedTextColor: white,
        monthTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        )),
        dateTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.grey,
        )),
        dayTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        )),
        onDateChange: (date) {
          setState(() {
            _selectedDate = date;
            noDataCounter = 0;
          });
        },
      ),
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              Text(
                "Today",
                style: headingStyle,
              )
            ],
          ),
          MyButton(
              label: "+ Add Task",
              onTap: () async {
                await Get.to(() => AddTaskPage(
                      purpose: "add",
                    )); //adding await to wait to new added task to database
                _taskController
                    .getTasks(); //after adding new task to database, we are updating the taskList list
              })
        ],
      ),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          ThemeService().switchTheme();
          notifyHelper.displayNotification(
            title: "Theme Changed",
            body: Get.isDarkMode
                ? "Activated Light Theme"
                : "Activated Dark Theme",
          );

          //notifyHelper.scheduledNotification();
        },
        child: Icon(
          Get.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
          size: 20,
          color: Get.isDarkMode ? white : Colors.black,
        ),
      ),
      // actions: [
      //   CircleAvatar(
      //     child: ClipOval(
      //       child: Image.network(
      //         Get.isDarkMode
      //             ? "https://cdn-icons-png.flaticon.com/512/747/747545.png"
      //             : "https://cdn-icons-png.flaticon.com/512/747/747376.png",
      //         width: 30,
      //         height: 30,
      //         fit: BoxFit.cover,
      //       ),
      //     ),
      //     backgroundColor: Colors.transparent,
      //   ),
      //   SizedBox(width: 20)
      // ],
    );
  }
}
