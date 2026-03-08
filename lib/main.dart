// ============================================================
// Project Milestone 2: Student Grade Calculator - Dart/Flutter GUI
// Built with Flutter
//
// HOW TO RUN:
//   1. Install Flutter SDK: https://docs.flutter.dev/get-started/install
//   2. Create new project: flutter create grade_calculator
//   3. Replace lib/main.dart with this file
//   4. Add to pubspec.yaml dependencies:
//        excel: ^4.0.2
//        xml: ^6.3.0
//        path_provider: ^2.1.1
//        file_saver: ^0.2.12
//   5. Run: flutter run
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';

// ── Color Palette ─────────────────────────────────────────
class AppColors {
  static const darkBlue = Color(0xFF0D1B3E);
  static const midBlue = Color(0xFF1A2F5E);
  static const orange = Color(0xFFFF6B00);
  static const orangeLight = Color(0xFFFF8C3A);
  static const white = Color(0xFFFFFFFF);
  static const gray = Color(0xFFB0B8C8);
  static const greenPass = Color(0xFF28A745);
  static const redFail = Color(0xFFDC3545);
}

// ── Data Model ────────────────────────────────────────────
class Student {
  String id;
  String name;
  List<double> grades;

  Student({required this.id, required this.name, List<double>? grades})
      : grades = grades ?? [];

  double calculateAverage() {
    if (grades.isEmpty) return 0.0;
    return grades.reduce((a, b) => a + b) / grades.length;
  }

  String getLetterGrade() {
    final avg = calculateAverage();
    if (avg >= 90) return 'A';
    if (avg >= 80) return 'B';
    if (avg >= 70) return 'C';
    if (avg >= 60) return 'D';
    return 'F';
  }

  bool isPassing() => calculateAverage() >= 60;

  bool addGrade(double grade) {
    if (grade >= 0 && grade <= 100) {
      grades.add(grade);
      return true;
    }
    return false;
  }
}

// ── Higher-Order Functions ────────────────────────────────
void processStudents(List<Student> students, void Function(Student) action) =>
    students.forEach(action);

List<Student> filterStudents(List<Student> s, bool Function(Student) pred) =>
    s.where(pred).toList();

List<T> mapStudents<T>(List<Student> s, T Function(Student) fn) =>
    s.map(fn).toList();

// ── Export Helpers (returns String for web/download) ──────
String toHtml(List<Student> students) {
  final rows = students
      .map((s) {
    final color = s.isPassing() ? '#28a745' : '#dc3545';
    return '<tr>'
        '<td>${s.id}</td><td>${s.name}</td>'
        '<td>${s.grades.map((g) => g.toInt()).join(', ')}</td>'
        '<td>${s.calculateAverage().toStringAsFixed(2)}</td>'
        '<td style="color:$color;font-weight:bold">${s.getLetterGrade()}</td>'
        '<td style="color:$color">${s.isPassing() ? "PASS" : "FAIL"}</td>'
        '</tr>';
  })
      .join('\n');
  return '''<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Grade Report</title>
<style>
  body{font-family:Segoe UI,sans-serif;background:#0D1B3E;color:#fff;margin:40px}
  h1{color:#FF6B00} table{border-collapse:collapse;width:100%}
  th{background:#FF6B00;color:#fff;padding:12px}
  td{background:#1A2F5E;color:#fff;padding:10px;border:1px solid #2a4080}
</style></head><body>
<h1>📊 Student Grade Report</h1>
<table><tr><th>ID</th><th>Name</th><th>Grades</th><th>Average</th><th>Letter</th><th>Status</th></tr>
$rows</table></body></html>''';
}

String toXml(List<Student> students) {
  final buf = StringBuffer(
    '<?xml version="1.0" encoding="UTF-8"?>\n<students>\n',
  );
  for (final s in students) {
    buf.write(
      '  <student id="${s.id}">\n'
          '    <name>${s.name}</name>\n'
          '    <grades>${s.grades.join(',')}</grades>\n'
          '    <average>${s.calculateAverage().toStringAsFixed(2)}</average>\n'
          '    <letterGrade>${s.getLetterGrade()}</letterGrade>\n'
          '    <status>${s.isPassing() ? "PASS" : "FAIL"}</status>\n'
          '  </student>\n',
    );
  }
  buf.write('</students>');
  return buf.toString();
}

String toCsv(List<Student> students) {
  final buf = StringBuffer('ID,Name,Grades,Average,Letter Grade,Status\n');
  for (final s in students) {
    buf.write(
      '${s.id},${s.name},"${s.grades.join(';')}",'
          '${s.calculateAverage().toStringAsFixed(2)},'
          '${s.getLetterGrade()},${s.isPassing() ? "PASS" : "FAIL"}\n',
    );
  }
  return buf.toString();
}

// ── App Entry ─────────────────────────────────────────────
void main() => runApp(const GradeCalculatorApp());

class GradeCalculatorApp extends StatelessWidget {
  const GradeCalculatorApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Student Grade Calculator',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.darkBlue,
      colorScheme: const ColorScheme.dark(primary: AppColors.orange),
    ),
    home: const GradeHomePage(),
  );
}

class GradeHomePage extends StatefulWidget {
  const GradeHomePage({super.key});
  @override
  State<GradeHomePage> createState() => _GradeHomePageState();
}

class _GradeHomePageState extends State<GradeHomePage> {
  final _students = <Student>[
    Student(id: 'STU001', name: 'Alice Johnson', grades: [92, 88, 95, 91, 87]),
    Student(id: 'STU002', name: 'Bob Smith', grades: [74, 68, 72, 65, 70]),
    Student(id: 'STU003', name: 'Carol White', grades: [55, 60, 58, 52, 57]),
    Student(id: 'STU004', name: 'David Brown', grades: [81, 85, 79, 88, 82]),
    Student(id: 'STU005', name: 'Eva Martinez', grades: [98, 96, 99, 97, 95]),
  ];

  String _filter = 'All';
  String _statusMsg = '';
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _gradesCtrl = TextEditingController();

  List<Student> get _displayed {
    if (_filter == 'Passing')
      return filterStudents(_students, (s) => s.isPassing());
    if (_filter == 'Failing')
      return filterStudents(_students, (s) => !s.isPassing());
    return _students;
  }

  void _addStudent() {
    if (_idCtrl.text.isEmpty || _nameCtrl.text.isEmpty) {
      setState(() => _statusMsg = '⚠ ID and Name are required.');
      return;
    }
    final s = Student(id: _idCtrl.text.trim(), name: _nameCtrl.text.trim());
    _gradesCtrl.text
        .split(',')
        .map((g) => double.tryParse(g.trim()))
        .whereType<double>()
        .forEach(s.addGrade);
    setState(() {
      _students.add(s);
      _statusMsg = '✓ ${s.name} added successfully.';
      _idCtrl.clear();
      _nameCtrl.clear();
      _gradesCtrl.clear();
    });
  }

  void _showExport(String type) {
    String content;
    switch (type) {
      case 'HTML':
        content = toHtml(_students);
        break;
      case 'XML':
        content = toXml(_students);
        break;
      default:
        content = toCsv(_students);
        break;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.midBlue,
        title: Text(
          '$type Export Preview',
          style: const TextStyle(color: AppColors.orange),
        ),
        content: SizedBox(
          width: 500,
          height: 350,
          child: SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(
                color: AppColors.white,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.orange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allStudents = _students;
    final classAvg = allStudents.isEmpty
        ? 0.0
        : allStudents.map((s) => s.calculateAverage()).reduce((a, b) => a + b) /
        allStudents.length;
    final topStudent = allStudents.isEmpty
        ? null
        : allStudents.reduce(
          (a, b) => a.calculateAverage() >= b.calculateAverage() ? a : b,
    );

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student Grade Calculator',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Project Milestone 2 — Flutter GUI',
                        style: TextStyle(color: AppColors.gray, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Add Student Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.midBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Student',
                      style: TextStyle(
                        color: AppColors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _field(_idCtrl, 'Student ID', flex: 1),
                        const SizedBox(width: 10),
                        _field(_nameCtrl, 'Full Name', flex: 2),
                        const SizedBox(width: 10),
                        _field(
                          _gradesCtrl,
                          'Grades (comma separated)',
                          flex: 3,
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _addStudent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    if (_statusMsg.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _statusMsg,
                        style: TextStyle(
                          color: _statusMsg.startsWith('✓')
                              ? AppColors.greenPass
                              : Colors.yellow,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Filter + Export
              Row(
                children: [
                  const Text(
                    'Filter:',
                    style: TextStyle(color: AppColors.gray),
                  ),
                  const SizedBox(width: 8),
                  ...['All', 'Passing', 'Failing'].map(
                        (mode) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ElevatedButton(
                        onPressed: () => setState(() => _filter = mode),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _filter == mode
                              ? AppColors.orange
                              : AppColors.midBlue,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          mode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Export:',
                    style: TextStyle(color: AppColors.gray),
                  ),
                  const SizedBox(width: 8),
                  ...['HTML', 'XML', 'Excel'].map(
                        (t) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: OutlinedButton(
                        onPressed: () => _showExport(t),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.orange),
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(color: AppColors.orangeLight),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Table
              Container(
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    for (final h in [
                      'ID',
                      'Name',
                      'Grades',
                      'Avg',
                      'Grade',
                      'Status',
                    ])
                      Expanded(
                        child: Text(
                          h,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _displayed.length,
                  itemBuilder: (_, i) {
                    final s = _displayed[i];
                    final bg = i.isEven
                        ? AppColors.midBlue
                        : AppColors.darkBlue;
                    final sc = s.isPassing()
                        ? AppColors.greenPass
                        : AppColors.redFail;
                    return Container(
                      color: bg,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.id,
                              style: const TextStyle(
                                color: AppColors.gray,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              s.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              s.grades.map((g) => g.toInt()).join(', '),
                              style: const TextStyle(
                                color: AppColors.gray,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              s.calculateAverage().toStringAsFixed(2),
                              style: const TextStyle(
                                color: AppColors.orangeLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              s.getLetterGrade(),
                              style: const TextStyle(
                                color: AppColors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              s.isPassing() ? 'PASS' : 'FAIL',
                              style: TextStyle(
                                color: sc,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Stats
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.midBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('${allStudents.length}', 'Students'),
                    _stat(classAvg.toStringAsFixed(1), 'Class Avg'),
                    _stat(
                      '${filterStudents(allStudents, (s) => s.isPassing()).length}',
                      'Passing',
                      color: AppColors.greenPass,
                    ),
                    _stat(topStudent?.name ?? '-', 'Top Student'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {int flex = 1}) =>
      Expanded(
        flex: flex,
        child: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: AppColors.gray),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.gray),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.orange),
            ),
          ),
        ),
      );

  Widget _stat(String value, String label, {Color color = AppColors.orange}) =>
      Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.gray, fontSize: 12),
          ),
        ],
      );
}
