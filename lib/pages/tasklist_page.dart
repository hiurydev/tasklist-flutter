import 'package:flutter/material.dart';
import 'package:tasklist/models/task.dart';
import 'package:tasklist/repositories/task.repository.dart';
import 'package:tasklist/widget/task_list_item.dart';

class TaskListPage extends StatefulWidget {
  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> tasks = [];

  final TextEditingController taskController = TextEditingController();
  final TaskRepository taskRepository = TaskRepository();

  @override
  void initState() {
    super.initState();
    taskRepository.getTasks().then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(//garante que o conteúdo ficará dentro da área safe do mobile
      child: Scaffold(
          body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: taskController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Adicione uma task",
                          hintText: "Ex.: Tarefa teste"),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                      onPressed: adicionar,
                      style: ElevatedButton.styleFrom(
                          primary: Colors.deepPurple,
                          padding: const EdgeInsets.all(14)),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                      ))
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (Task task in tasks)
                      TaskListItem(
                        task: task,
                        onDelete: onDelete
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text("Você possui ${tasks.length} tarefas pendentes"),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: limparTudo,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.deepPurple,
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Text("Limpar tudo"),
                  )
                ],
              )
            ],
          ), 
        ),
      )),
    );
  }

  void adicionar() {
    String text = taskController.text;
    setState(() {
      Task task = new Task(title: text, dataTask: DateTime.now());
      tasks.add(task);
    });
    taskController.clear();
    taskRepository.saveTaskList(tasks);
  } 

  void limparTudo() {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('Limpar tudo?'),
        content: const Text('Você tem certeza que quer apagar todas as tasks?'),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            }, 
            child: const Text('Cancelar')
          ),
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
              deleteAllTasks();
            }, 
            child: const Text('Limpar tudo!')
          ),
        ],
      ));
  }

  void deleteAllTasks() {
    setState(() {
      tasks.clear();
    });
  }

  void onDelete(task) {
    Task taskRemovida = task;
    int taskPos = tasks.indexOf(task);

    setState(() { 
      tasks.remove(task);
    }); 
   
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.lightBlue,
        content: Text(
          'Tarefa ${task.title} foi excluída com sucesso!'
        ),
        action: SnackBarAction(
          label: "Desfazer",
          textColor: Colors.grey[600],
          onPressed: () {
            setState(() {
              tasks.insert(taskPos, taskRemovida);
            });
          },
        ),
      )
    );
  }
}
