import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

const api = 'https://studyflow-eeci.onrender.com';

// ───────────── Design tokens ─────────────
const kPrimary = Color(0xFF4F46E5);
const kViolet = Color(0xFF7C3AED);
const kBg = Color(0xFFF4F6FB);
const kInk = Color(0xFF111827);
const kMuted = Color(0xFF6B7280);
const kBorder = Color(0xFFE5E7EB);
const kGreen = Color(0xFF10B981);
const kAmber = Color(0xFFF59E0B);
const kRose = Color(0xFFEF4444);
const kTeal = Color(0xFF0EA5E9);

TextStyle heading(double size, {Color color = kInk}) =>
    GoogleFonts.poppins(fontSize: size, fontWeight: FontWeight.w600, color: color);

void main() => runApp(const StudyFlowApp());

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'StudyFlow', debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: kPrimary, primary: kPrimary),
      useMaterial3: true,
      scaffoldBackgroundColor: kBg,
      textTheme: GoogleFonts.interTextTheme(),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: kPrimary.withOpacity(0.12),
      ),
    ),
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
  Future<void> updateTask(int id, Map<String, dynamic> data) async {
  final response = await http.put(
    Uri.parse('$api/tasks/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );

  if (response.statusCode >= 200 && response.statusCode < 300) {
    await refresh();
  } else {
    throw Exception('Failed to update task: ${response.body}');
  }
}

  // ───────────── Dialogs ─────────────

  void addTask() async {
    final title = TextEditingController(); final course = TextEditingController(text: 'General'); final due = TextEditingController();
    String priority = 'Medium', kind = 'assignment';
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
      title: Text('Add task', style: heading(20)),
      content: SizedBox(width: 420, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 4),
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Task title', prefixIcon: Icon(Icons.edit_outlined))),
        const SizedBox(height: 12),
        TextField(controller: course, decoration: const InputDecoration(labelText: 'Course', prefixIcon: Icon(Icons.menu_book_outlined))),
        const SizedBox(height: 12),
        TextField(controller: due, decoration: const InputDecoration(labelText: 'Due date (YYYY-MM-DD)', prefixIcon: Icon(Icons.event_outlined))),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: priority, decoration: const InputDecoration(labelText: 'Priority', prefixIcon: Icon(Icons.flag_outlined)), items: ['Low','Medium','High'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(), onChanged:(x)=>update(()=>priority=x??'Medium'),),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: kind, decoration: const InputDecoration(labelText: 'Task type', prefixIcon: Icon(Icons.category_outlined)), items: ['assignment','study','exam'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(), onChanged:(x)=>update(()=>kind=x??'assignment'),),
      ]))), actions: [TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')), FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save'))],
    )));
    if (ok == true && title.text.trim().isNotEmpty) await post('/tasks', {'title':title.text.trim(),'course':course.text,'due_date':due.text,'priority':priority,'kind':kind});
  }

  void editTask(Map task) async {
    final title = TextEditingController(text: '${task['title'] ?? ''}');
    final course = TextEditingController(text: '${task['course'] ?? ''}');
    final due = TextEditingController(text: '${task['due_date'] ?? ''}');

    String priority = '${task['priority'] ?? 'Medium'}';
    String kind = '${task['kind'] ?? 'assignment'}';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: Text('Edit task', style: heading(20)),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Task title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: course,
                    decoration: const InputDecoration(labelText: 'Course'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: due,
                    decoration: const InputDecoration(
                      labelText: 'Due date (YYYY-MM-DD)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: ['Low', 'Medium', 'High']
                        .map((x) => DropdownMenuItem(
                              value: x,
                              child: Text(x),
                            ))
                        .toList(),
                    onChanged: (x) => update(() => priority = x ?? 'Medium'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: kind,
                    decoration: const InputDecoration(labelText: 'Task type'),
                    items: ['assignment', 'study', 'exam']
                        .map((x) => DropdownMenuItem(
                              value: x,
                              child: Text(x),
                            ))
                        .toList(),
                    onChanged: (x) =>
                        update(() => kind = x ?? 'assignment'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );

    if (ok == true && title.text.trim().isNotEmpty) {
      try {
        await updateTask(task['id'] as int, {
          'title': title.text.trim(),
          'course': course.text.trim(),
          'due_date': due.text.trim(),
          'priority': priority,
          'kind': kind,
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update task: $e')),
        );
      }
    }

    title.dispose();
    course.dispose();
    due.dispose();
  }


  void addCourse() async {
    final name = TextEditingController();
    final ok = await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
      title: Text('Add course', style: heading(20)),
      content: SizedBox(width: 420, child: TextField(controller:name,decoration:const InputDecoration(labelText:'Course name', prefixIcon: Icon(Icons.menu_book_outlined)))),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save'))]));
    if(ok==true && name.text.trim().isNotEmpty) await post('/courses', {'name':name.text.trim()});
  }
  void addSession() async {
    final topic = TextEditingController(), course = TextEditingController(text:'General'), minutes = TextEditingController(text:'30');
    final ok = await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
      title: Text('Add study session', style: heading(20)),
      content: SizedBox(width: 420, child: Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:topic,decoration:const InputDecoration(labelText:'Topic', prefixIcon: Icon(Icons.lightbulb_outline))),
        const SizedBox(height: 12),
        TextField(controller:course,decoration:const InputDecoration(labelText:'Course', prefixIcon: Icon(Icons.menu_book_outlined))),
        const SizedBox(height: 12),
        TextField(controller:minutes,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Minutes', prefixIcon: Icon(Icons.timer_outlined)))])),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Save'))]));
    if(ok==true && topic.text.trim().isNotEmpty) await post('/sessions', {'topic':topic.text,'course':course.text,'minutes':int.tryParse(minutes.text)??30});
  }

  // ───────────── UI helpers ─────────────

  static const _tabLabels = ['Dashboard', 'Courses', 'Sessions', 'Reminders'];
  static const _tabIcons = [Icons.dashboard_outlined, Icons.menu_book_outlined, Icons.timer_outlined, Icons.notifications_outlined];
  static const _tabIconsOn = [Icons.dashboard, Icons.menu_book, Icons.timer, Icons.notifications];

  Color _priorityColor(String p) => p == 'High' ? kRose : p == 'Low' ? kGreen : kAmber;

  // Centers content with a max width, like a website container.
  Widget _container(Widget child, bool wide) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Padding(padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16), child: child),
    ),
  );

  Widget _chip(IconData icon, String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(6)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color), const SizedBox(width: 5),
      Text(text, style: GoogleFonts.inter(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _panel({required Widget child, EdgeInsets padding = const EdgeInsets.all(20)}) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kBorder),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: child,
  );

  Widget _sectionHeader(String title, String subtitle, {String? buttonLabel, VoidCallback? onAdd}) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 16),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: heading(22)),
        const SizedBox(height: 2),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 13.5, color: kMuted)),
      ])),
      if (onAdd != null) FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add, size: 18), label: Text(buttonLabel ?? 'Add')),
    ]),
  );

  Widget _empty(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), shape: BoxShape.circle),
        child: Icon(icon, size: 36, color: kPrimary),
      ),
      const SizedBox(height: 14),
      Text(text, style: GoogleFonts.inter(color: kMuted, fontSize: 14.5)),
    ])),
  );

  // ───────────── Navbar ─────────────

  Widget _navbar(bool wide) => Container(
    decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: kBorder))),
    child: SafeArea(
      bottom: false,
      child: _container(SizedBox(height: 64, child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kPrimary, kViolet]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Text('StudyFlow', style: heading(20)),
        const Spacer(),
        if (wide) ...List.generate(4, (i) {
          final on = tab == i;
          return Padding(
            padding: const EdgeInsets.only(left: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => tab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(color: on ? kPrimary.withOpacity(0.10) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  Icon(on ? _tabIconsOn[i] : _tabIcons[i], size: 18, color: on ? kPrimary : kMuted),
                  const SizedBox(width: 7),
                  Text(_tabLabels[i], style: GoogleFonts.inter(fontSize: 14, fontWeight: on ? FontWeight.w600 : FontWeight.w500, color: on ? kPrimary : kMuted)),
                ]),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        IconButton(onPressed: refresh, icon: const Icon(Icons.refresh_rounded), color: kMuted, tooltip: 'Refresh'),
      ])), wide),
    ),
  );

  // ───────────── Hero + stats ─────────────

  Widget _hero(bool wide) {
    final progress = ((dashboard['progress_percent'] ?? 0) as num);
    final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(20)),
        child: Text('Your study planner', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
      const SizedBox(height: 14),
      Text('Stay organized.\nStudy smarter.', style: heading(wide ? 34 : 26, color: Colors.white).copyWith(height: 1.2)),
      const SizedBox(height: 10),
      Text('Track assignments, courses and study sessions in one place.',
        style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: wide ? 15 : 13.5)),
    ]);
    final ring = SizedBox(
      width: 120, height: 120,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(width: 120, height: 120, child: CircularProgressIndicator(
          value: progress / 100, strokeWidth: 10, strokeCap: StrokeCap.round,
          backgroundColor: Colors.white.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation(Colors.white),
        )),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${dashboard['progress_percent'] ?? 0}%', style: heading(26, color: Colors.white)),
          Text('complete', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12)),
        ]),
      ]),
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(wide ? 36 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kPrimary, kViolet], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: wide
        ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: text), const SizedBox(width: 24), ring])
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [text, const SizedBox(height: 20), Center(child: ring)]),
    );
  }

  Widget _stat(String label, dynamic value, IconData icon, Color color, bool wide) => Container(
    padding: EdgeInsets.all(wide ? 20 : 12),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: wide
      ? Row(children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$value', style: heading(26)),
            Text(label, style: GoogleFonts.inter(fontSize: 13.5, color: kMuted)),
          ]),
        ])
      : Column(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18)),
          const SizedBox(height: 8),
          Text('$value', style: heading(20)),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: kMuted)),
        ]),
  );

  // ───────────── Task list ─────────────

  Widget taskList({bool remindersOnly=false}) {
    final shown = remindersOnly ? tasks.where((t)=>t['due_date']!='' && t['completed']==false).toList() : tasks;
    if (shown.isEmpty) return _panel(child: _empty(remindersOnly ? Icons.notifications_none : Icons.task_alt, 'Nothing here yet. Add a task!'));
    return Column(children: shown.map<Widget>((t) {
      final done = t['completed'] == true;
      final pColor = _priorityColor('${t['priority']}');
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(width: 5, color: done ? kGreen : pColor),
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: Checkbox(
                  value: t['completed'], activeColor: kGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  onChanged: (_) => toggle(t['id']),
                ),
                title: Text(t['title'], style: GoogleFonts.inter(
                  fontSize: 15.5, fontWeight: FontWeight.w600,
                  color: done ? kMuted : kInk,
                  decoration: done ? TextDecoration.lineThrough : null,
                )),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(spacing: 8, runSpacing: 6, children: [
                    _chip(Icons.menu_book_outlined, '${t['course']}', kPrimary),
                    _chip(Icons.flag_outlined, '${t['priority']}', pColor),
                    _chip(Icons.event_outlined, t['due_date'].isEmpty ? 'Not set' : '${t['due_date']}', kTeal),
                  ]),
                ),
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(Icons.edit_outlined),
      color: kPrimary,
      tooltip: 'Edit task',
      onPressed: () => editTask(t),
    ),
    IconButton(
      icon: const Icon(Icons.delete_outline),
      color: kMuted,
      tooltip: 'Delete task',
      onPressed: () => remove('/tasks/${t['id']}'),
    ),
  ],
),              ),
            )),
          ])),
        ),
      );
    }).toList());
  }

  // ───────────── Pages ─────────────

  Widget _grid(List<Widget> items) => GridView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 360, mainAxisExtent: 88, crossAxisSpacing: 14, mainAxisSpacing: 14,
    ),
    children: items,
  );

  Widget _infoCard({required IconData icon, required Color color, required String title, String? subtitle, Widget? trailing}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
      const SizedBox(width: 14),
      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w600, color: kInk)),
        if (subtitle != null) ...[const SizedBox(height: 3), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 13, color: kMuted))],
      ])),
      if (trailing != null) trailing,
    ]),
  );



  Widget page(bool wide) {
    final stats = [
      _stat('Total Tasks', dashboard['total'] ?? 0, Icons.list_alt_rounded, kPrimary, wide),
      _stat('Pending', dashboard['pending'] ?? 0, Icons.hourglass_bottom_rounded, kAmber, wide),
      _stat('Completed', dashboard['completed'] ?? 0, Icons.check_circle_outline_rounded, kGreen, wide),
    ];
    Widget body;
    if (tab == 0) {
      body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _hero(wide),
        const SizedBox(height: 20),
        Row(children: [
          for (int i = 0; i < stats.length; i++) ...[Expanded(child: stats[i]), if (i < stats.length - 1) SizedBox(width: wide ? 16 : 10)],
        ]),
        const SizedBox(height: 28),
        _sectionHeader('My Tasks', 'Everything you need to get done', buttonLabel: wide ? 'Add Task' : null, onAdd: wide ? addTask : null),
        taskList(),
      ]);
    } else if (tab == 1) {
      body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('Courses', '${courses.length} enrolled', buttonLabel: 'Add Course', onAdd: addCourse),
        courses.isEmpty
          ? _panel(child: _empty(Icons.menu_book_outlined, 'No courses yet'))
          : _grid(courses.map<Widget>((c) => _infoCard(
              icon: Icons.menu_book_rounded, color: kViolet, title: '${c['name']}',
              trailing: IconButton(icon: const Icon(Icons.delete_outline), color: kMuted, onPressed: () => remove('/courses/${c['id']}')),
            )).toList()),
      ]);
    } else if (tab == 2) {
      body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('Study Sessions', '${sessions.length} logged', buttonLabel: 'Add Session', onAdd: addSession),
        sessions.isEmpty
          ? _panel(child: _empty(Icons.timer_outlined, 'No study sessions yet'))
          : _grid(sessions.map<Widget>((s) => _infoCard(
              icon: Icons.timer_rounded, color: kTeal, title: '${s['topic']}',
              subtitle: '${s['course']} • ${s['minutes']} minutes',
            )).toList()),
      ]);
    } else {
      body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('Reminders', 'Upcoming tasks with a due date'),
        taskList(remindersOnly: true),
      ]);
    }
    return SingleChildScrollView(child: Column(children: [
      _container(Padding(padding: const EdgeInsets.only(top: 24), child: body), wide),
     
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 800;
    return Scaffold(
      floatingActionButton: (!wide && tab == 0) ? FloatingActionButton.extended(
        onPressed: addTask, backgroundColor: kPrimary, foregroundColor: Colors.white,
        icon: const Icon(Icons.add), label: Text('Add Task', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ) : null,
      body: Column(children: [
        _navbar(wide),
        Expanded(child: busy
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty && courses.isEmpty && sessions.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('Could not load data. Is FastAPI running?'),
                const SizedBox(height: 10),
                FilledButton(onPressed: refresh, child: const Text('Retry')),
              ]))
            : page(wide)),
      ]),
      bottomNavigationBar: wide ? null : NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: List.generate(4, (i) => NavigationDestination(icon: Icon(_tabIcons[i]), selectedIcon: Icon(_tabIconsOn[i], color: kPrimary), label: _tabLabels[i])),
      ),
    );
  }
}