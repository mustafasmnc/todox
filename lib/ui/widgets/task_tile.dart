import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nodex/models/task.dart';
import 'package:nodex/ui/theme.dart';

class TaskTile extends StatelessWidget {
  final Task? task;
  TaskTile(this.task);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      width: MediaQuery.of(context).size.width * 0.94,
      margin: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(16),
        //  width: SizeConfig.screenWidth * 0.78,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _getBGClr(task?.color ?? 0),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task?.title ?? "",
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: Colors.grey[200],
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "${task!.startTime} - ${task!.endTime}",
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  fontSize: 13, color: Colors.grey[100]),
                            ),
                          ),
                        ],
                      ),
                      task!.repeat != 'None'
                          ? Row(
                              children: [
                                Icon(
                                  Icons.repeat,
                                  color: Colors.grey[200],
                                  size: 18,
                                ),
                                Text(task!.repeat.toString(),
                                    style: titleStyle.copyWith(
                                        color: Colors.white, fontSize: 13)),
                                SizedBox(width: 10),
                              ],
                            )
                          : Container(),
                      task!.remind != 0
                          ? Row(
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  color: Colors.grey[200],
                                  size: 18,
                                ),
                                Text(
                                  "${task!.remind.toString()}  min",
                                  style: titleStyle.copyWith(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  task?.note ?? "",
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(fontSize: 15, color: Colors.grey[100]),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            width: 0.5,
            color: Colors.grey[200]!.withOpacity(0.7),
          ),
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              task!.isCompleted == 1 ? "COMPLETED" : "TODO",
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  _getBGClr(int no) {
    switch (no) {
      case 0:
        return task!.isCompleted == 1 ? bluishClr.withOpacity(0.5) : bluishClr;
      case 1:
        return task!.isCompleted == 1 ? pinkClr.withOpacity(0.5) : pinkClr;
      case 2:
        return task!.isCompleted == 1 ? yellowClr.withOpacity(0.5) : yellowClr;
      case 3:
        return task!.isCompleted == 1 ? greenClr.withOpacity(0.5) : greenClr;
      default:
        return bluishClr;
    }
  }
}
