import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nodex/controllers/task_controller.dart';
import 'package:nodex/models/task.dart';
import 'package:nodex/ui/theme.dart';
import 'package:nodex/ui/widgets/button.dart';
import 'package:nodex/ui/widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  final String purpose;
  final Task? task;
  const AddTaskPage({Key? key, this.task, required this.purpose})
      : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _endTime = "9:30";
  String _startTime = DateFormat("HH:mm").format(DateTime.now()).toString();
  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];
  String _selectedRepeat = "None";
  List<String> repeatList = ["None", "Daily", "Weekly", "Monthly"];
  int _selectedColor = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.purpose == "update") {
      _titleController.text = widget.task!.title.toString();
      _noteController.text = widget.task!.note.toString();
      _selectedDate = DateFormat.yMd().parse(widget.task!.date.toString());
      _startTime = widget.task!.startTime.toString();
      _endTime = widget.task!.endTime.toString();
      _selectedRemind = widget.task!.remind!.toInt();
      _selectedRepeat = widget.task!.repeat.toString();
      _selectedColor = widget.task!.color!.toInt();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(),
      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyInputField(
                  title: "Title",
                  hint: widget.purpose == "add"
                      ? "Enter title here"
                      : widget.task!.title.toString(),
                  controller: _titleController,
                ),
                MyInputField(
                  title: "Note",
                  hint: widget.purpose == "add"
                      ? "Enter note here"
                      : widget.task!.note.toString(),
                  controller: _noteController,
                ),
                MyInputField(
                  title: "Date",
                  hint: DateFormat.yMd().format(_selectedDate),
                  widget: IconButton(
                    icon: Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () => _getDateFromUser(),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                        child: MyInputField(
                      title: "Start Time",
                      hint: _startTime,
                      widget: IconButton(
                        onPressed: () {
                          _getTimeFromUser(isStartTime: true);
                        },
                        icon: Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    )),
                    SizedBox(width: 10),
                    Expanded(
                        child: MyInputField(
                      title: "End Time",
                      hint: _endTime,
                      widget: IconButton(
                        onPressed: () {
                          _getTimeFromUser(isStartTime: false);
                        },
                        icon: Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    )),
                  ],
                ),
                MyInputField(
                  title: "Remind",
                  hint: "$_selectedRemind minutes early",
                  widget: DropdownButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                    underline: Container(height: 0),
                    iconSize: 33,
                    elevation: 4,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRemind = int.parse(newValue!);
                      });
                    },
                    style: subTitleStyle,
                    items:
                        remindList.map<DropdownMenuItem<String>>((int value) {
                      return DropdownMenuItem<String>(
                        value: value.toString(),
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                ),
                MyInputField(
                  title: "Repeat",
                  hint: "$_selectedRepeat",
                  widget: DropdownButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                    underline: Container(height: 0),
                    iconSize: 33,
                    elevation: 4,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRepeat = newValue!;
                      });
                    },
                    style: subTitleStyle,
                    items: repeatList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _colorPalette(),
                    MyButton(
                        label: widget.purpose == "add"
                            ? "Create Task"
                            : "Update Task",
                        onTap: () => _validateData())
                  ],
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _validateData() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      if (widget.purpose == "add") {
        //add to database
        _addTaskToDB();
      } else {
        _updateTaskToDB();
        _taskController.getTasks();
      }
      Get.back(closeOverlays: true);
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar(
        "Required",
        "All fields are required!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode ? Colors.white : darkHeaderClr,
        colorText: pinkClr,
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
        ),
      );
    }
  }

  _addTaskToDB() async {
    int value = await _taskController.addTask(
        task: Task(
      note: _noteController.text,
      title: _titleController.text,
      date: DateFormat.yMd().format(_selectedDate),
      startTime: _startTime,
      endTime: _endTime,
      remind: _selectedRemind,
      repeat: _selectedRepeat,
      color: _selectedColor,
      isCompleted: 0,
    ));
    print("Added note ID is $value");
  }

  _updateTaskToDB() async {
    int value = await _taskController.updateTask(
        task: Task(
          note: _noteController.text,
          title: _titleController.text,
          date: DateFormat.yMd().format(_selectedDate),
          startTime: _startTime,
          endTime: _endTime,
          remind: _selectedRemind,
          repeat: _selectedRepeat,
          color: _selectedColor,
          isCompleted: widget.task!.isCompleted,
        ),
        taskId: widget.task!.id);
    print("Updated note ID is $value");
  }

  _colorPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Color",
          style: titleStyle,
        ),
        SizedBox(height: 5),
        Wrap(
          children: List<Widget>.generate(4, (int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = index;
                  print("$index");
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: index == 0
                      ? primaryClr
                      : index == 1
                          ? pinkClr
                          : index == 2
                              ? yellowClr
                              : greenClr,
                  child: _selectedColor == index
                      ? Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 18,
                        )
                      : Container(),
                ),
              ),
            );
          }),
        )
      ],
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Icon(
          Icons.arrow_back,
          size: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
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

  _getDateFromUser() async {
    DateTime? _pickerDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2071),
      //Change showDatePicker UI
      // builder: (context, child) {
      //   return Theme(
      //     data: Theme.of(context).copyWith(
      //       colorScheme: Get.isDarkMode
      //           ? ColorScheme.dark(
      //               primary: Colors.grey, // header background color
      //               onPrimary: Colors.white, // header text color
      //               onSurface: Color(0xFF1D84B5), // body text color
      //             )
      //           : ColorScheme.light(
      //               //primary: primaryClr // header background color
      //               onPrimary: Colors.white, // header text color
      //               onSurface: Color(0xFF0A2239), // body text color
      //             ),
      //       textButtonTheme: TextButtonThemeData(
      //         style: TextButton.styleFrom(
      //           primary: Colors.red, // button text color
      //         ),
      //       ),
      //     ),
      //     child: child!,
      //   );
      // },
    );
    if (_pickerDate != null) {
      setState(() {
        _selectedDate = _pickerDate;
      });
    } else
      print("it's null or something is wrong");
  }

  _getTimeFromUser({required bool isStartTime}) async {
    var pickedTime = await _showTimePicker();
    String _formatedTime = pickedTime.format(context);
    if (pickedTime == null) {
      print("Time Cancelled");
    } else if (isStartTime == true) {
      setState(() {
        _startTime = _formatedTime;
      });
    } else if (isStartTime == false) {
      setState(() {
        _endTime = _formatedTime;
      });
    }
  }

  _showTimePicker() {
    return showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        context: context,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
        initialTime: TimeOfDay(
          hour: int.parse(_startTime.split(":")[0]),
          minute: int.parse(_startTime.split(":")[1].split(" ")[0]),
        ));
  }
}
