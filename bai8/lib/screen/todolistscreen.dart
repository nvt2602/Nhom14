import 'package:bai8/screen/completedtask.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';
import 'completedtask.dart';

class TodoListScreen extends StatefulWidget {
  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  //truy cap de dang hon
  static List<Task> completedTasks = [];
  List<Task> _tasks = [];
  DateTime selectedDate = DateTime.now();

  _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000, 01, 01),
      lastDate: DateTime(2030, 01, 01),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });
  }

  void completeTask(Task task) {
    setState(() {
      _tasks.remove(task);
      completedTasks.add(task);
    });
  }

  @override
  void initState() {
    super.initState();

    // công việc mẫu
    _tasks.add(Task(
      title: 'Học Flutter',
      content: '1 ngày học flutter 1 tiếng',
      deadline: DateTime.now().add(Duration(days: 7)),
    ));
    _tasks.add(Task(
      title: 'Mua sữa',
      content: 'Mua sữa vào thứ 2',
      deadline: DateTime.now().subtract(Duration(days: 1)),
    ));
    _tasks.add(Task(
      title: 'Đi bơi',
      content: 'Bơi vào 17h cuối tuần',
      deadline: DateTime.now().add(Duration(days: 2)),
    ));
  }

  void _addTask() async {
    // nhập cv
    TextEditingController titleController = TextEditingController();
    TextEditingController deadlineController = TextEditingController();
    TextEditingController contentController = TextEditingController();
    // luu tru gia tri dau vao
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm công việc mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Tên công việc',
                  ),
                ),
                TextField(
                  controller: contentController,
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: 'Nội dung công việc',
                  ),
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context, deadlineController),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: deadlineController,
                      decoration: InputDecoration(
                        labelText: 'Thời hạn chót (VD: 2023-03-31)',
                      ),
                    ),
                    // onTap: () => _selectDate(context),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text;
                final content = contentController.text;
                final deadline = DateTime.tryParse(deadlineController.text);
                if (title.isNotEmpty && deadline != null) {
                  setState(() {
                    _tasks.add(Task(
                      title: title,
                      content: content,
                      deadline: deadline,
                    ));
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Vui lòng nhập đầy đủ thông tin.'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Công việc của tôi',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompletedScreen(completedTasks),
                ),
              );
            },
          ),
        ],
        backgroundColor: Color.fromARGB(255, 73, 168, 245),
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          final deadlineFormatted =
              DateFormat('dd/MM/yyyy').format(task.deadline);

          return ExpansionTile(
            title: Text(
              task.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Hạn chót: $deadlineFormatted'),
            leading:
                task.isOverdue() ? Icon(Icons.error, color: Colors.red) : null,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    task.content,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ],
            // hien thi 1 nut de xoa hoac hoan thanh
            trailing: PopupMenuButton<int>(
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                  value: 0,
                  child: Text("Xóa"),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Text("Hoàn thành"),
                ),
              ],
              onSelected: (value) {
                if (value == 0) {
                  _deleteTask(task);
                }

                if (value == 1) {
                  completeTask(task);
                }
              },
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: Color.fromARGB(255, 96, 177, 244),
        child: Icon(Icons.add),
      ),
      // backgroundColor: Color.fromARGB(255, 220, 227, 234),
    );
  }
}
