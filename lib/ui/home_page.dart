import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/controllers/task_controller.dart';
import 'package:task_manager/services/notification_services.dart';
import 'package:task_manager/ui/add_task_bar.dart';
import 'package:task_manager/ui/theme.dart';
import 'package:task_manager/ui/widget/task_tile.dart';

import '../models/task.dart';
import '../services/theme_services.dart';
import 'button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());
  var notifyHelper;

  @override
  void initState(){
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
  }
  @override
  Widget build(BuildContext context) {
    _taskController.getTasks();
    return Scaffold(
      appBar: _appBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         _addTaskBar(),
          _addDateBar(),
          SizedBox(height: 10,),
          _showTasks(),

        ],
      ),
    );
  }
  _showTasks(){
    return Expanded(
        child: Obx(() => ListView.builder(
          itemCount: _taskController.taskList.length,
          itemBuilder: (_, index){
            print(_taskController.taskList.length);
            Task task = _taskController.taskList[index];
            if(task.repeat=='Daily') {
              DateTime date = DateFormat.jm().parse(task.startTime.toString());
              var myTime = DateFormat("HH:MM").format(date);
              notifyHelper.scheduleNotification(
                int.parse(myTime.toString().split(":")[0]),
                  int.parse(myTime.toString().split(":")[0]),
                task
              );

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
                                  child: TaskTile(task)
                              )
                            ],
                          )
                      )
                  ));
            }
            if(task.date==DateFormat.yMd().format(_selectedDate)){
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
                                  child: TaskTile(task)
                              )
                            ],
                          )
                      )
                  ));
            }else{
              return Container();
            }
          })
        )
    );
  }
  _showBottomSheet(BuildContext context, Task task){
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        height: task.isCompleted == 1?
         MediaQuery.of(context).size.height*0.24:
         MediaQuery.of(context).size.height*0.32 ,
        color: Get.isDarkMode? darkGreyClr: Colors.white,
        child: Column(
          children: [
            Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode?Colors.grey[600]: Colors.grey[300],
              ),
            ),
            Spacer(),
            task.isCompleted == 1
                ?Container()
                : _buttomSheetButton(
                label: "Task Completed", 
                onTap:(){
                  _taskController.markTaskCompleted(task.id!);
                  Get.back();
                }, 
                clr: primaryClr,
                context: context
            ),
            _buttomSheetButton(
                label: "Delete Task",
                onTap:(){
                  _taskController.delete(task);
                  Get.back();
                },
                clr: Colors.red[300]!,
                context: context
            ),
            SizedBox(height: 10,),
            _buttomSheetButton(
                label: "Close",
                onTap:(){
                  Get.back();
                },
                clr: Colors.white,
                context: context
            ),
            SizedBox(height: 2,),
          ],
        )
      ),
    );
  }
  
  _buttomSheetButton({
    required String label,
    required Function()? onTap,
    required Color clr,
    bool isClose = false,
    required BuildContext context,
    }){
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            height: 55,
            width: MediaQuery.of(context).size.width*0.9,

            decoration: BoxDecoration(
                color: isClose==true?Colors.transparent: clr,
              border: Border.all(
                width: 2,
                color: isClose==true?Get.isDarkMode?Colors.grey[600]!: Colors.grey[300]!: clr,
              ),
              borderRadius: BorderRadius.circular(20)
            ),
            child: Center(
              child: Text(
                label,
                style: isClose?titleStyle:titleStyle.copyWith(color:Colors.black),
              ),
            ),
          ),
        );
    }
  _addDateBar(){
    return Container(
      margin: const EdgeInsets.only(top:20, left: 20 ),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        dateTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey

            )
        ),
        dayTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey

            )
        ),
        monthTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey

            )
        ),
        onDateChange: (date){
          setState((){
            _selectedDate = date;
          });
        },
      ),
    );
  }
  _addTaskBar(){
      return  Container(
        margin: const EdgeInsets.only(left: 10, right: 20, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat.yMMMMd().format(DateTime.now()),
                    style: subHeadingStyle,),
                  Text("Today",
                      style: headingStyle )
                ],
              ),
            ),
            MyButton(  onTap: ()async{
              await Get.to(()=>AddTaskPage());
              _taskController.getTasks();}, label: '+ Add Task ',)
          ],
        ),
      );
  }
  _appBar() {
    return AppBar(
      backgroundColor: context.theme.backgroundColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: (){
            ThemeService().switchTheme();
            notifyHelper.displayNotification(
              title: "Theme Changed",
              body: Get.isDarkMode?"Actiated Dark Theme": "Activated Light Theme",
            );
            //notifyHelper.scheduledNotification();
        },
        child: Icon(Get.isDarkMode? Icons.wb_sunny_outlined:Icons.nightlight_round,
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
}
