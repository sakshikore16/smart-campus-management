import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/empty_state_with_action.dart';

class StudentsManageScreen extends StatefulWidget {
  const StudentsManageScreen({super.key});

  @override
  State<StudentsManageScreen> createState() => _StudentsManageScreenState();
}

class _StudentsManageScreenState extends State<StudentsManageScreen> {
  List<dynamic> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getStudents();
      if (mounted) setState(() {
        _list = data;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showAddDialog() {
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    final rollNo = TextEditingController();
    final department = TextEditingController();
    final course = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
              TextField(controller: password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              TextField(controller: rollNo, decoration: const InputDecoration(labelText: 'Roll No')),
              TextField(controller: department, decoration: const InputDecoration(labelText: 'Department')),
              TextField(controller: course, decoration: const InputDecoration(labelText: 'Course')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (name.text.isEmpty || email.text.isEmpty || password.text.length < 6 || rollNo.text.isEmpty || department.text.isEmpty || course.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields, password min 6')));
                return;
              }
              Navigator.pop(ctx);
              try {
                await ApiService.addStudent({
                  'name': name.text,
                  'email': email.text,
                  'password': password.text,
                  'rollNo': rollNo.text,
                  'department': department.text,
                  'course': course.text,
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student added')));
                  _load();
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Students'), actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add student'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _list.isEmpty
                ? EmptyStateWithAction(message: 'No records found', actionLabel: 'Add student', onAction: _showAddDialog, icon: Icons.person_add)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _list.length,
                    itemBuilder: (_, i) {
                      final s = _list[i] as Map<String, dynamic>;
                      final user = s['userId'] is Map ? s['userId'] as Map<String, dynamic> : null;
                      final name = user?['name'] ?? '';
                      final email = user?['email'] ?? '';
                      final rollNo = s['rollNo'] ?? '';
                      final id = s['_id'] as String?;
                      return Card(
                        child: ListTile(
                          title: Text('$name ($rollNo)'),
                          subtitle: Text(email),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: id == null
                                ? null
                                : () async {
                                    if (await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete student?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes'))])) != true) return;
                                    try {
                                      await ApiService.deleteStudent(id);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
                                        _load();
                                      }
                                    } catch (e) {
                                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                                    }
                                  },
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
