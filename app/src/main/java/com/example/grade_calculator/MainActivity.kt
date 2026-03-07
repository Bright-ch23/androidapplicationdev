package com.example.grade_calculator

// ============================================================
// Student Grade Calculator - Kotlin GUI
// Built with Jetpack Compose for Desktop
// Project Milestone 2
// ============================================================
//
// HOW TO RUN:
//   1. Ensure you have Gradle and JDK 17+ installed
//   2. Place this in a Gradle Compose Desktop project
//   3. Run: ./gradlew run
//
// build.gradle.kts (add to your project):
// ------------------------------------------------------------
// plugins {
//     kotlin("jvm") version "1.9.0"
//     id("org.jetbrains.compose") version "1.5.0"
// }
// dependencies {
//     implementation(compose.desktop.currentOs)
//     implementation("org.apache.poi:poi-ooxml:5.2.3")  // For Excel export
// }
// compose.desktop { application { mainClass = "MainKt" } }
// ============================================================

import androidx.compose.desktop.ui.tooling.preview.Preview
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.*
import java.io.File
import java.io.FileWriter
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.transform.TransformerFactory
import javax.xml.transform.dom.DOMSource
import javax.xml.transform.stream.StreamResult

// ── Color Palette ─────────────────────────────────────────
object AppColors {
    val DarkBlue  = Color(0xFF0D1B3E)
    val MidBlue   = Color(0xFF1A2F5E)
    val Orange    = Color(0xFFFF6B00)
    val OrangeLight = Color(0xFFFF8C3A)
    val White     = Color(0xFFFFFFFF)
    val OffWhite  = Color(0xFFF5F7FA)
    val Gray      = Color(0xFFB0B8C8)
    val GreenPass = Color(0xFF28A745)
    val RedFail   = Color(0xFFDC3545)
}

// ── Data Model ────────────────────────────────────────────
data class Student(
    val id: String,
    val name: String,
    val grades: MutableList<Double> = mutableListOf()
) {
    fun calculateAverage(): Double =
        if (grades.isEmpty()) 0.0 else grades.sum() / grades.size

    fun getLetterGrade(): String = when {
        calculateAverage() >= 90 -> "A"
        calculateAverage() >= 80 -> "B"
        calculateAverage() >= 70 -> "C"
        calculateAverage() >= 60 -> "D"
        else                     -> "F"
    }

    fun isPassing() = calculateAverage() >= 60

    fun addGrade(grade: Double): Boolean {
        return if (grade in 0.0..100.0) { grades.add(grade); true } else false
    }
}

// ── Higher-Order Functions ────────────────────────────────
fun processStudents(students: List<Student>, action: (Student) -> Unit) =
    students.forEach(action)

fun filterStudents(students: List<Student>, pred: (Student) -> Boolean) =
    students.filter(pred)

fun <T> mapStudents(students: List<Student>, transform: (Student) -> T) =
    students.map(transform)

// ── Export Functions ──────────────────────────────────────
fun exportToHtml(students: List<Student>, path: String) {
    val rows = students.joinToString("\n") { s ->
        val color = if (s.isPassing()) "#28a745" else "#dc3545"
        """
        <tr>
          <td>${s.id}</td><td>${s.name}</td>
          <td>${s.grades.joinToString(", ")}</td>
          <td>${"%.2f".format(s.calculateAverage())}</td>
          <td style="color:$color;font-weight:bold">${s.getLetterGrade()}</td>
          <td style="color:$color">${if (s.isPassing()) "PASS" else "FAIL"}</td>
        </tr>
        """.trimIndent()
    }
    val html = """
    <!DOCTYPE html>
    <html><head><meta charset="UTF-8">
    <title>Student Grade Report</title>
    <style>
      body { font-family: 'Segoe UI', sans-serif; background:#0D1B3E; color:#fff; margin:40px; }
      h1   { color:#FF6B00; }
      table{ border-collapse:collapse; width:100%; }
      th   { background:#FF6B00; color:#fff; padding:12px; }
      td   { background:#1A2F5E; color:#fff; padding:10px; border:1px solid #2a4080; }
      tr:hover td { background:#243a70; }
    </style></head>
    <body>
    <h1>📊 Student Grade Report</h1>
    <table><tr><th>ID</th><th>Name</th><th>Grades</th><th>Average</th><th>Letter</th><th>Status</th></tr>
    $rows
    </table></body></html>
    """.trimIndent()
    File(path).writeText(html)
}

fun exportToXml(students: List<Student>, path: String) {
    val sb = StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<students>\n")
    students.forEach { s ->
        sb.append("  <student id=\"${s.id}\">\n")
        sb.append("    <name>${s.name}</name>\n")
        sb.append("    <grades>${s.grades.joinToString(",")}</grades>\n")
        sb.append("    <average>${"%.2f".format(s.calculateAverage())}</average>\n")
        sb.append("    <letterGrade>${s.getLetterGrade()}</letterGrade>\n")
        sb.append("    <status>${if (s.isPassing()) "PASS" else "FAIL"}</status>\n")
        sb.append("  </student>\n")
    }
    sb.append("</students>")
    File(path).writeText(sb.toString())
}

fun exportToCsv(students: List<Student>, path: String) {
    // CSV is used as a proxy for Excel (.xlsx via Apache POI in real build)
    val sb = StringBuilder("ID,Name,Grades,Average,Letter Grade,Status\n")
    students.forEach { s ->
        sb.append("${s.id},${s.name},\"${s.grades.joinToString(";")}\","
                + "${"%.2f".format(s.calculateAverage())},${s.getLetterGrade()},"
                + "${if (s.isPassing()) "PASS" else "FAIL"}\n")
    }
    File(path).writeText(sb.toString())
}

// ── Main Composable ───────────────────────────────────────
@Composable
@Preview
fun App() {
    val students = remember {
        mutableStateListOf(
            Student("STU001", "Alice Johnson").also { s -> listOf(92.0,88.0,95.0,91.0,87.0).forEach { s.addGrade(it) } },
            Student("STU002", "Bob Smith").also     { s -> listOf(74.0,68.0,72.0,65.0,70.0).forEach { s.addGrade(it) } },
            Student("STU003", "Carol White").also   { s -> listOf(55.0,60.0,58.0,52.0,57.0).forEach { s.addGrade(it) } },
            Student("STU004", "David Brown").also   { s -> listOf(81.0,85.0,79.0,88.0,82.0).forEach { s.addGrade(it) } },
            Student("STU005", "Eva Martinez").also  { s -> listOf(98.0,96.0,99.0,97.0,95.0).forEach { s.addGrade(it) } }
        )
    }

    var newName    by remember { mutableStateOf("") }
    var newId      by remember { mutableStateOf("") }
    var newGrades  by remember { mutableStateOf("") }
    var statusMsg  by remember { mutableStateOf("") }
    var filterMode by remember { mutableStateOf("All") }

    val displayed = when (filterMode) {
        "Passing" -> filterStudents(students.toList()) { it.isPassing() }
        "Failing" -> filterStudents(students.toList()) { !it.isPassing() }
        else      -> students.toList()
    }

    MaterialTheme(colors = darkColors(
        primary   = AppColors.Orange,
        surface   = AppColors.MidBlue,
        background = AppColors.DarkBlue
    )) {
        Column(
            modifier = Modifier.fillMaxSize().background(AppColors.DarkBlue).padding(24.dp)
        ) {
            // ── Header
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("📊", fontSize = 32.sp)
                Spacer(Modifier.width(12.dp))
                Column {
                    Text("Student Grade Calculator",
                        color = AppColors.Orange, fontSize = 26.sp, fontWeight = FontWeight.Bold)
                    Text("Project Milestone 2 — Kotlin GUI",
                        color = AppColors.Gray, fontSize = 13.sp)
                }
            }

            Spacer(Modifier.height(20.dp))

            // ── Add Student Panel
            Card(
                backgroundColor = AppColors.MidBlue,
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(Modifier.padding(16.dp)) {
                    Text("Add New Student", color = AppColors.Orange, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    Spacer(Modifier.height(10.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        OutlinedTextField(
                            value = newId, onValueChange = { newId = it },
                            label = { Text("Student ID", color = AppColors.Gray) },
                            colors = TextFieldDefaults.outlinedTextFieldColors(
                                textColor = AppColors.White,
                                focusedBorderColor = AppColors.Orange,
                                unfocusedBorderColor = AppColors.Gray
                            ),
                            modifier = Modifier.weight(1f)
                        )
                        OutlinedTextField(
                            value = newName, onValueChange = { newName = it },
                            label = { Text("Full Name", color = AppColors.Gray) },
                            colors = TextFieldDefaults.outlinedTextFieldColors(
                                textColor = AppColors.White,
                                focusedBorderColor = AppColors.Orange,
                                unfocusedBorderColor = AppColors.Gray
                            ),
                            modifier = Modifier.weight(2f)
                        )
                        OutlinedTextField(
                            value = newGrades, onValueChange = { newGrades = it },
                            label = { Text("Grades (comma separated)", color = AppColors.Gray) },
                            colors = TextFieldDefaults.outlinedTextFieldColors(
                                textColor = AppColors.White,
                                focusedBorderColor = AppColors.Orange,
                                unfocusedBorderColor = AppColors.Gray
                            ),
                            modifier = Modifier.weight(2f)
                        )
                        Button(
                            onClick = {
                                if (newId.isNotBlank() && newName.isNotBlank()) {
                                    val s = Student(newId.trim(), newName.trim())
                                    newGrades.split(",").mapNotNull { it.trim().toDoubleOrNull() }
                                        .forEach { s.addGrade(it) }
                                    students.add(s)
                                    statusMsg = "✓ Student '${s.name}' added."
                                    newId = ""; newName = ""; newGrades = ""
                                } else statusMsg = "⚠ ID and Name are required."
                            },
                            colors = ButtonDefaults.buttonColors(backgroundColor = AppColors.Orange),
                            modifier = Modifier.align(Alignment.CenterVertically)
                        ) { Text("Add", color = AppColors.White) }
                    }
                    if (statusMsg.isNotEmpty()) {
                        Spacer(Modifier.height(6.dp))
                        Text(statusMsg, color = if (statusMsg.startsWith("✓")) AppColors.GreenPass else Color.Yellow, fontSize = 13.sp)
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            // ── Filter + Export Row
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                Text("Filter:", color = AppColors.Gray)
                listOf("All", "Passing", "Failing").forEach { mode ->
                    Button(
                        onClick = { filterMode = mode },
                        colors = ButtonDefaults.buttonColors(
                            backgroundColor = if (filterMode == mode) AppColors.Orange else AppColors.MidBlue
                        ),
                        shape = RoundedCornerShape(20.dp)
                    ) { Text(mode, color = AppColors.White, fontSize = 13.sp) }
                }
                Spacer(Modifier.weight(1f))
                Text("Export:", color = AppColors.Gray)
                Button(onClick = { exportToHtml(students.toList(), "GradeReport.html"); statusMsg = "✓ Exported HTML" },
                    colors = ButtonDefaults.buttonColors(backgroundColor = AppColors.MidBlue)) {
                    Text("HTML", color = AppColors.OrangeLight)
                }
                Button(onClick = { exportToXml(students.toList(), "GradeReport.xml"); statusMsg = "✓ Exported XML" },
                    colors = ButtonDefaults.buttonColors(backgroundColor = AppColors.MidBlue)) {
                    Text("XML", color = AppColors.OrangeLight)
                }
                Button(onClick = { exportToCsv(students.toList(), "GradeReport.csv"); statusMsg = "✓ Exported CSV/Excel" },
                    colors = ButtonDefaults.buttonColors(backgroundColor = AppColors.MidBlue)) {
                    Text("Excel", color = AppColors.OrangeLight)
                }
            }

            Spacer(Modifier.height(12.dp))

            // ── Table Header
            Row(
                modifier = Modifier.fillMaxWidth()
                    .background(AppColors.Orange, RoundedCornerShape(topStart = 8.dp, topEnd = 8.dp))
                    .padding(horizontal = 16.dp, vertical = 10.dp)
            ) {
                listOf("ID" to 1f, "Name" to 2f, "Grades" to 3f, "Avg" to 1f, "Grade" to 1f, "Status" to 1f)
                    .forEach { (label, weight) ->
                        Text(label, color = AppColors.White, fontWeight = FontWeight.Bold,
                            modifier = Modifier.weight(weight))
                    }
            }

            // ── Table Body
            LazyColumn(modifier = Modifier.fillMaxWidth().weight(1f)) {
                items(displayed) { student ->
                    val bg = if (displayed.indexOf(student) % 2 == 0) AppColors.MidBlue else AppColors.DarkBlue
                    Row(
                        modifier = Modifier.fillMaxWidth().background(bg).padding(horizontal = 16.dp, vertical = 10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(student.id, color = AppColors.Gray, modifier = Modifier.weight(1f), fontSize = 13.sp)
                        Text(student.name, color = AppColors.White, modifier = Modifier.weight(2f))
                        Text(student.grades.joinToString(", ") { it.toInt().toString() },
                            color = AppColors.Gray, modifier = Modifier.weight(3f), fontSize = 12.sp)
                        Text("%.2f".format(student.calculateAverage()),
                            color = AppColors.OrangeLight, modifier = Modifier.weight(1f), fontWeight = FontWeight.Bold)
                        Text(student.getLetterGrade(),
                            color = AppColors.Orange, modifier = Modifier.weight(1f), fontWeight = FontWeight.Bold, fontSize = 18.sp)
                        val passColor = if (student.isPassing()) AppColors.GreenPass else AppColors.RedFail
                        Text(if (student.isPassing()) "PASS" else "FAIL",
                            color = passColor, modifier = Modifier.weight(1f), fontWeight = FontWeight.Bold)
                    }
                    Divider(color = AppColors.DarkBlue.copy(alpha = 0.5f), thickness = 1.dp)
                }
            }

            Spacer(Modifier.height(12.dp))

            // ── Stats Footer
            val allStudents = students.toList()
            if (allStudents.isNotEmpty()) {
                val classAvg = allStudents.map { it.calculateAverage() }.average()
                val topStudent = allStudents.maxByOrNull { it.calculateAverage() }
                Row(
                    modifier = Modifier.fillMaxWidth()
                        .background(AppColors.MidBlue, RoundedCornerShape(8.dp))
                        .padding(14.dp),
                    horizontalArrangement = Arrangement.SpaceAround
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("${allStudents.size}", color = AppColors.Orange, fontSize = 22.sp, fontWeight = FontWeight.Bold)
                        Text("Students", color = AppColors.Gray, fontSize = 12.sp)
                    }
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("%.1f".format(classAvg), color = AppColors.Orange, fontSize = 22.sp, fontWeight = FontWeight.Bold)
                        Text("Class Avg", color = AppColors.Gray, fontSize = 12.sp)
                    }
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("${filterStudents(allStudents) { it.isPassing() }.size}", color = AppColors.GreenPass, fontSize = 22.sp, fontWeight = FontWeight.Bold)
                        Text("Passing", color = AppColors.Gray, fontSize = 12.sp)
                    }
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("${topStudent?.name ?: "-"}", color = AppColors.OrangeLight, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                        Text("Top Student", color = AppColors.Gray, fontSize = 12.sp)
                    }
                }
            }
        }
    }
}

fun main() = application {
    Window(
        onCloseRequest = ::exitApplication,
        title = "Student Grade Calculator — Kotlin GUI",
        state = rememberWindowState(width = 1100.dp, height = 750.dp)
    ) { App() }
}
