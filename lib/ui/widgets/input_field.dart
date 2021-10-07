import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nodex/ui/theme.dart';

class MyInputField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;
  const MyInputField({
    Key? key,
    required this.title,
    required this.hint,
    this.controller,
    this.widget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle,
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.only(left: 10),
            height: 50,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: widget == null ? false : true,
                    autofocus: false,
                    cursorColor:
                        Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
                    controller: controller,
                    style: subTitleStyle,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: subTitleStyle,
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: context.theme.backgroundColor,
                          width: 0,
                        ))),
                  ),
                ),
                widget == null
                    ? Container()
                    : Container(
                        child: widget,
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}
