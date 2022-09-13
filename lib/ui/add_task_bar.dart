import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/controllers/task_controller.dart';
import 'package:task_manager/ui/button.dart';
import 'package:task_manager/ui/theme.dart';
import 'package:task_manager/ui/widget/input_field.dart';

import '../models/task.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _endTime = "9:30 PM";
  String _startTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  int _selectedRemind = 5;
  List<int> remindList=[
    5,
    10,
    15,
    20,
  ];
  String _selectedRepeat = "None";
  List<String> repeatList=[
    "None",
    "Daily",
    "Weekly",
    "Monthly"
  ];
  int _selectedColor = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(context),
      body: Container(
        padding: const EdgeInsets.only(left:20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add Task",
              style: headingStyle,),
              MyInputField(title: 'Title',hint: "Enter your title ", controller: _titleController,),
              MyInputField(title: 'Note',hint: "Enter your note ", controller: _noteController,),
              MyInputField(title: 'Date',hint: DateFormat.yMd().format(_selectedDate),
              widget: IconButton(
                icon: Icon(Icons.calendar_today_outlined),
                color: Colors.grey,
                onPressed: (){
                    _getDateFromUser();
                },
              ),),
              Row(
                children: [
                  Expanded(
                      child: MyInputField(
                        title: "Start Date",
                        hint: _startTime,
                        widget: IconButton(
                          onPressed: (){
                              _getTimeFromUser(isStartTime: true);
                          },
                          icon: Icon(
                            Icons.access_time_rounded,
                            color: Colors.grey,
                          ),
                        ),
                      )),
                  SizedBox(width: 12,),
                  Expanded(
                      child: MyInputField(
                        title: "End Date",
                        hint: _endTime,
                        widget: IconButton(
                          onPressed: (){
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
              MyInputField(title: "Remind", hint: "$_selectedRemind minutes early",
              widget: DropdownButton(
                icon: Icon(Icons.keyboard_arrow_down,
                color: Colors.grey),
                onChanged: (String? value) {
                  setState((){
                    _selectedRemind = int.parse(value!);
                  });
                },
                iconSize: 32,
                elevation: 4,
                style: subTitleStyle,
                underline: Container(height: 0,),
                items: remindList.map<DropdownMenuItem<String>>((int value){
                  return DropdownMenuItem<String>(
                    value: value.toString(),
                    child: Text(value.toString()),
                  );
                }
                ).toList(),
              ),),
              MyInputField(title: "Repeat", hint: "$_selectedRepeat",
                widget: DropdownButton(
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: Colors.grey),
                  onChanged: (String? value) {
                    setState((){
                      _selectedRepeat = value!;
                    });
                  },
                  iconSize: 32,
                  elevation: 4,
                  style: subTitleStyle,
                  underline: Container(height: 0,),
                  items: repeatList.map<DropdownMenuItem<String>>((String? value){
                    return DropdownMenuItem<String>(
                      value: value.toString(),
                      child: Text(value!, style: TextStyle(color: Colors.grey),)
                    );
                  }
                  ).toList(),
                ),),
              SizedBox(height: 18,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                      _colorPallete(),
                      MyButton(label: "Create Task",
                          onTap: ()=> _validateDate())
                    ],
                  )
                ],
              )
          ),
        ),
      );
  }

_validateDate(){
    if(_titleController.text.isNotEmpty && _noteController.text.isNotEmpty){
      _addTaskToDb();
      Get.back();
    }else if(_titleController.text.isEmpty || _noteController.text.isEmpty){
      Get.snackbar("Required", "All fields are required !",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: pinkClr,
      icon: Icon(Icons.warning_amber_rounded),);
    }
}
_addTaskToDb() async{
   int value = await  _taskController.addTask(
      task: Task(
        note: _noteController.text,
        title: _titleController.text,
        date: DateFormat.yMd().format(_selectedDate),
        startTime: _startTime,
        endTime: _endTime,
        remind: _selectedRemind,
        color: _selectedColor,
        isCompleted: 0,
      )
    );
   print("my ID is "+"$value");
}
_colorPallete(){
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

      Text("Color",style: titleStyle,),
      SizedBox(height: 8.0,),
      Wrap(
          children: List<Widget>.generate(3,
                  (int index) => GestureDetector(
                onTap: (){
                  setState((){
                    _selectedColor = index;
                  });

                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: index==0? primaryClr:index==1?pinkClr:yellowClr,
                    child: _selectedColor ==  index? Icon(Icons.done,
                        color: Colors.white,
                        size: 16): Container(),
                  ),
                ),
              )),
        ),]);
}
_appBar(BuildContext context) {
  return AppBar(
    backgroundColor: context.theme.backgroundColor,
    elevation: 0,
    leading: GestureDetector(
      onTap: (){
        Get.back();
      },
      child: Icon(Icons.arrow_back_ios,
          size: 20,
          color: Get.isDarkMode? Colors.white: Colors.black),
    ),
    actions: [
      CircleAvatar(
        backgroundImage: AssetImage(
            "images/profile.png"
        ),
      ),
      SizedBox(
        width: 20,
      )
    ],
  );
}
_getDateFromUser() async{
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015),
        lastDate: DateTime(2023)
    ) ;
    if(_pickerDate !=null){
      setState((){
        _selectedDate = _pickerDate;
      });
    }
    else{
      print("Its null or nothing was returned");
    }
}
_getTimeFromUser({ required bool isStartTime}) async{
 var pickedTime =  await _showTimePiker();
 String _formattedTime = pickedTime.format(context);
 if(pickedTime == null){
   print("Time Cancelled");
 }else if(isStartTime == true){
   setState((){
     _startTime = _formattedTime;
   });
 }else if(isStartTime == false){
    setState((){
      _endTime = _formattedTime;
    });
 }
}
_showTimePiker(){
    return showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: int.parse(_startTime.split(":")[0]),
          minute: int.parse(_startTime.split(":")[1].split(" ")[0])
        ));
}
}