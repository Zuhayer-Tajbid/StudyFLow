import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const api = 'http://127.0.0.1:8000';
void main() => runApp(const StudyFlowApp());

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'StudyFlow', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), useMaterial3: true),
    home: const PlannerHome(),
  );
}

class PlannerHome extends StatefulWidget {
  const PlannerHome({super.key});
  @override
  State<PlannerHome> createState() => _PlannerHomeState();
}

class _PlannerHomeState extends State<PlannerHome> {
  int tab = 0;
  List tasks = [], courses = [], sessions = [];
  Map dashboard = {};
  bool busy = false;

  @override
  void initState() { super.initState(); refresh(); }
  Future<void> refresh() async {
    setState(() => busy = true);
    try {
      final results = await Future.wait([
        http.get(Uri.parse('$api/tasks')), http.get(Uri.parse('$api/courses')),
        http.get(Uri.parse('$api/dashboard')), http.get(Uri.parse('$api/sessions')),
      ]);
      if (results.every((r) => r.statusCode == 200)) {
        setState(() { tasks = jsonDecode(results[0].body); courses = jsonDecode(results[1].body);
          dashboard = jsonDecode(results[2].body); sessions = jsonDecode(results[3].body); });
      }
    } catch (_) { /* API may not be running; show a connection hint below. */ }
    if (mounted) setState(() => busy = false);
  }

  Future<void> post(String path, Map data) async {
    await http.post(Uri.parse('$api$path'), headers: {'Content-Type':'application/json'}, body: jsonEncode(data));
    await refresh();
  }
  Future<void> remove(String path) async { await http.delete(Uri.parse('$api$path')); await refresh(); }
  Future<void> toggle(int id) async { await http.put(Uri.parse('$api/tasks/$id/toggle')); await refresh(); }

  void addTask() async {
    final title = TextEditingController(); final course = TextEditingController(text: 'General'); final due = TextEditingController();
    String priority = 'Medium', kind = 'assignment';
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
      title: const Text('Add task'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Task title')),
        TextField(controller: course, decoration: const InputDecoration(labelText: 'Course')),
        TextField(controller: due, decoration: const InputDecoration(labelText: 'Due date (YYYY-MM-DD)')),
        DropdownButtonFormField<String>(value: priority, decoration: const InputDecoration(labelText: 'Priority'), items: ['Low','Medium','High'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(), onChanged:(x)=>update(()=>priority=x??'Medium'),),
        DropdownButtonFormField<String>(value: kind, decoration: const InputDecoration(labelText: 'Task type'), items: ['assignment','study','exam'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(), onChanged:(x)=>update(()=>kind=x??'assignment'),),
      ])), actions: [TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')), FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save'))],
    )));
    if (ok == true && title.text.trim().isNotEmpty) await post('/tasks', {'title':title.text.trim(),'course':course.text,'due_date':due.text,'priority':priority,'kind':kind});
  }

  void addCourse() async {
    final name = TextEditingController();
    final ok = await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Add course'),content:TextField(controller:name,decoration:const InputDecoration(labelText:'Course name')),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save'))]));
    if(ok==true && name.text.trim().isNotEmpty) await post('/courses', {'name':name.text.trim()});
  }
  void addSession() async {
    final topic = TextEditingController(), course = TextEditingController(text:'General'), minutes = TextEditingController(text:'30');
    final ok = await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('Add study session'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:topic,decoration:const InputDecoration(labelText:'Topic')),TextField(controller:course,decoration:const InputDecoration(labelText:'Course')),TextField(controller:minutes,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Minutes'))]),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save'))]));
    if(ok==true && topic.text.trim().isNotEmpty) await post('/sessions', {'topic':topic.text,'course':course.text,'minutes':int.tryParse(minutes.text)??30});
  }

  Widget taskList({bool remindersOnly=false}) {
    final shown = remindersOnly ? tasks.where((t)=>t['due_date']!='' && t['completed']==false).toList() : tasks;
    if (shown.isEmpty) return const Center(child:Text('Nothing here yet. Add a task!'));
    return ListView.builder(itemCount:shown.length,itemBuilder:(context,i){final t=shown[i];return Card(child:ListTile(
      leading:Checkbox(value:t['completed'],onChanged:(_)=>toggle(t['id'])),
      title:Text(t['title'],style:TextStyle(decoration:t['completed']?TextDecoration.lineThrough:null)),
      subtitle:Text('${t['course']} • ${t['priority']} • Due: ${t['due_date'].isEmpty?'Not set':t['due_date']}'),
      trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:()=>remove('/tasks/${t['id']}')),
    ));});
  }

  Widget page() {
    if(tab==0) return Column(children:[
      Padding(padding:const EdgeInsets.all(16),child:Row(children:[Expanded(child:_stat('Total',dashboard['total']??0)),Expanded(child:_stat('Pending',dashboard['pending']??0)),Expanded(child:_stat('Done',dashboard['completed']??0))])),
      Padding(padding:const EdgeInsets.symmetric(horizontal:20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Progress: ${dashboard['progress_percent']??0}%'),const SizedBox(height:8),LinearProgressIndicator(value:((dashboard['progress_percent']??0) as num)/100)])),
      const Padding(padding:EdgeInsets.all(16),child:Align(alignment:Alignment.centerLeft,child:Text('My Tasks',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)))),Expanded(child:taskList()),
    ]);
    if(tab==1) return Column(children:[Padding(padding:const EdgeInsets.all(16),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('Courses',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),FilledButton.icon(onPressed:addCourse,icon:const Icon(Icons.add),label:const Text('Add'))])),Expanded(child:ListView(children:courses.map((c)=>ListTile(leading:const Icon(Icons.book_outlined),title:Text(c['name']),trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:()=>remove('/courses/${c['id']}')))).toList()))]);
    if(tab==2) return Column(children:[Padding(padding:const EdgeInsets.all(16),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('Study Sessions',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),FilledButton.icon(onPressed:addSession,icon:const Icon(Icons.add),label:const Text('Add'))])),Expanded(child:ListView(children:sessions.map((s)=>ListTile(leading:const Icon(Icons.timer_outlined),title:Text(s['topic']),subtitle:Text('${s['course']} • ${s['minutes']} minutes'))).toList()))]);
    return taskList(remindersOnly:true);
  }
  Widget _stat(String label, dynamic value)=>Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(children:[Text('$value',style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold)),Text(label)])));
  @override
  Widget build(BuildContext context) => Scaffold(appBar:AppBar(title:const Text('StudyFlow'),actions:[IconButton(onPressed:refresh,icon:const Icon(Icons.refresh))]),
    floatingActionButton:tab==0?FloatingActionButton.extended(onPressed:addTask,icon:const Icon(Icons.add),label:const Text('Add Task')):null,
    body:busy?const Center(child:CircularProgressIndicator()):tasks.isEmpty&&courses.isEmpty&&sessions.isEmpty?Center(child:Column(mainAxisSize:MainAxisSize.min,children:[const Text('Could not load data. Is FastAPI running?'),TextButton(onPressed:refresh,child:const Text('Retry'))])):page(),
    bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:const[NavigationDestination(icon:Icon(Icons.dashboard_outlined),label:'Dashboard'),NavigationDestination(icon:Icon(Icons.book_outlined),label:'Courses'),NavigationDestination(icon:Icon(Icons.timer_outlined),label:'Sessions'),NavigationDestination(icon:Icon(Icons.notifications_outlined),label:'Reminders')]),
  );
}
