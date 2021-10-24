import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nodex/controllers/task_controller.dart';
import 'package:nodex/services/notification_services.dart';
import 'package:nodex/services/theme_services.dart';
import 'package:intl/intl.dart';
import 'package:nodex/ui/add_task_bar.dart';
import 'package:nodex/ui/theme.dart';
import 'package:nodex/ui/widgets/button.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());
  var notifyHelper;
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
      return ListView.builder(
          itemCount: _taskController.taskList.length,
          itemBuilder: (_, index) {
            print("Note count: ${_taskController.taskList.length}");
            return GestureDetector(
              onTap: () {},
              child: Container(
                width: 100,
                height: 50,
                color: Colors.grey,
                margin: EdgeInsets.only(bottom: 10),
                child: Text(_taskController.taskList[index].title.toString()),
              ),
            );
          });
    }));
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
        selectedTextColor: Colors.white,
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
          _selectedDate = date;
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
                await Get.to(() =>
                    AddTaskPage()); //adding await to wait to new added task to database
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

          notifyHelper.scheduledNotification();
        },
        child: Icon(
          Get.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
          size: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        CircleAvatar(
          child: ClipOval(
            child: Image.network(
              Get.isDarkMode
                  ? "https://cdn-icons-png.flaticon.com/512/747/747545.png"
                  : "https://cdn-icons-png.flaticon.com/512/747/747376.png",
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
        SizedBox(width: 20)
      ],
    );
  }
}
