# 📊 Student Grade Calculator — Project Milestone 2

> **Objective:** Add functions and collection processing to your app's data model.  
> Demonstrates higher-order functions, lambda expressions, and collection operations in both **Kotlin** and **Dart**.

---

## 📁 Project Structure

```
student-grade-calculator/
├── kotlin/
│   ├── StudentGradeCalculator.kt       ← Console application (Kotlin)
│   └── StudentGradeCalculatorGUI.kt    ← GUI application (Jetpack Compose for Desktop)
├── dart/
│   ├── student_grade_calculator.dart   ← Console application (Dart)
│   └── student_grade_calculator_gui.dart ← GUI application (Flutter)
├── web/
│   └── index.html                      ← Full web GUI (HTML/CSS/JS) with export
└── README.md                           ← This file
```

---

## 🎯 Milestone 2 Requirements Checklist

| Requirement | Implemented? | Where |
|---|---|---|
| ✅ At least 2 functions on the data class | ✅ Yes | `calculateAverage()`, `getLetterGrade()`, `addGrade()`, `formatSummary()` |
| ✅ Higher-order function with lambda | ✅ Yes | `processStudents()`, `filterStudents()`, `mapStudents()` |
| ✅ Collection operation (filter a list) | ✅ Yes | Filter passing/failing students, grade distribution |
| ✅ Lambda passed to custom HOF | ✅ Yes | All three HOF functions accept lambdas |

---

## 🚀 Running the Applications

### 1. Kotlin — Console App

**Requirements:** JDK 17+, Kotlin compiler

```bash
# Install Kotlin (if not installed)
brew install kotlin            # macOS
sudo snap install kotlin       # Linux

# Compile and run
cd kotlin/
kotlinc StudentGradeCalculator.kt -include-runtime -d app.jar
java -jar app.jar
```

**Expected output:** A full grade report in the terminal showing all students, averages, letter grades, pass/fail status, and a grade distribution chart.

---

### 2. Kotlin — GUI App (Jetpack Compose for Desktop)

**Requirements:** JDK 17+, Gradle 8+

1. Create a new Compose Desktop project:
   ```bash
   # Option A: Use IntelliJ IDEA → File → New Project → Compose Multiplatform
   # Option B: Use the Kotlin Multiplatform wizard at https://kmp.jetbrains.com
   ```

2. Replace `src/main/kotlin/Main.kt` with `StudentGradeCalculatorGUI.kt`

3. Your `build.gradle.kts` should include:
   ```kotlin
   plugins {
       kotlin("jvm") version "1.9.21"
       id("org.jetbrains.compose") version "1.5.11"
   }
   
   dependencies {
       implementation(compose.desktop.currentOs)
   }
   
   compose.desktop {
       application {
           mainClass = "MainKt"
       }
   }
   ```

4. Run the application:
   ```bash
   ./gradlew run
   ```

**Features:**
- Add/remove students via form inputs
- Filter by passing/failing
- Export to HTML, XML, Excel (CSV)
- Live class statistics footer
- Color-coded grade badges (orange/dark-blue/white theme)

---

### 3. Dart — Console App

**Requirements:** Dart SDK 3.0+

```bash
# Install Dart SDK
# macOS:  brew install dart
# Linux:  see https://dart.dev/get-dart
# Windows: use choco install dart-sdk

# Run directly
cd dart/
dart run student_grade_calculator.dart
```

**Expected output:** Identical report to the Kotlin console app, demonstrating the same logic translated to Dart.

---

### 4. Dart — GUI App (Flutter)

**Requirements:** Flutter SDK 3.10+

```bash
# Install Flutter
# https://docs.flutter.dev/get-started/install

# Create new Flutter project
flutter create grade_calculator
cd grade_calculator

# Copy GUI file
cp ../dart/student_grade_calculator_gui.dart lib/main.dart

# Add dependencies to pubspec.yaml:
#   excel: ^4.0.2
#   xml: ^6.3.0
#   path_provider: ^2.1.1

# Run on desktop/mobile/web
flutter run
flutter run -d chrome          # Web
flutter run -d windows         # Windows desktop
flutter run -d macos           # macOS desktop
```

**Features:**
- Material Design 3 with custom dark theme
- Add students with grade input
- Filter by All / Passing / Failing
- Export previewer dialog for HTML, XML, Excel
- Responsive layout

---

### 5. Web GUI (No setup required!)

Simply open `web/index.html` in any modern browser:

```bash
# macOS
open web/index.html

# Linux
xdg-open web/index.html

# Windows
start web/index.html

# Or use a local server
npx serve web/
```

**Features:**
- ✅ Add / Remove students dynamically
- ✅ Filter: All / Passing / Failing
- ✅ Export to `.html` (download)
- ✅ Export to `.xml` (download)
- ✅ Export to `.xlsx` Excel (full spreadsheet via SheetJS)
- ✅ Live stats: Total, Class Average, Passing, Failing
- ✅ Animated grade bars per student
- ✅ Toast notifications
- ✅ Color palette: Orange (#FF6B00), Dark Blue (#0D1B3E), White (#FFFFFF)

---

## 🧠 Key Concepts Demonstrated

### Data Class Functions

Both Kotlin and Dart implement the same 4 functions on the Student model:

```kotlin
// Kotlin
data class Student(...) {
    fun calculateAverage(): Double { ... }   // Validation + computation
    fun getLetterGrade(): String { ... }     // Uses 'when' expression
    fun addGrade(grade: Double): Boolean { ... } // Input validation
    fun formatSummary(): String { ... }      // Formatted output
}
```

```dart
// Dart
class Student {
  double calculateAverage() { ... }   // Mirrors Kotlin
  String getLetterGrade() { ... }     // Uses if/else chain (like 'when')
  bool addGrade(double grade) { ... } // Validates 0–100 range
  String formatSummary() { ... }      // String interpolation
}
```

---

### Higher-Order Functions with Lambdas

```kotlin
// Kotlin — Lambda passed to custom HOF
processStudents(students) { student ->
    println(student.formatSummary())
}

// Filter with lambda (collection operation)
val passingStudents = filterStudents(students) { it.calculateAverage() >= 60 }

// Map with lambda
val averages = mapStudents(students) { "${it.name}: ${it.calculateAverage()}" }
```

```dart
// Dart — Same pattern
processStudents(students, (student) {
    print(student.formatSummary());
});

final passing = filterStudents(students, (s) => s.isPassing());
final summaries = mapStudents(students, (s) => '${s.name}: ${s.calculateAverage()}');
```

---

### Collection Operations

```kotlin
// Kotlin built-in HOFs used on collections
val distribution = students.groupBy { it.getLetterGrade() }
val classAvg     = students.map { it.calculateAverage() }.average()
val top          = students.maxByOrNull { it.calculateAverage() }
```

```dart
// Dart equivalent
final classAvg = students.fold(0.0, (acc, s) => acc + s.calculateAverage()) / students.length;
final top = students.reduce((a, b) => a.calculateAverage() >= b.calculateAverage() ? a : b);
```

---

## 🎨 Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Dark Blue | `#0D1B3E` | Background, base layer |
| Mid Blue | `#1A2F5E` | Cards, panels, rows |
| Orange | `#FF6B00` | Primary accent, headers, CTAs |
| Orange Light | `#FF8C3A` | Averages, secondary accents |
| White | `#FFFFFF` | Text, foreground |
| Gray | `#B0B8C8` | Labels, secondary text |
| Green | `#28A745` | PASS badges |
| Red | `#DC3545` | FAIL badges |

---

## 📦 Export Formats

| Format | Contents | How to Open |
|--------|----------|-------------|
| `.html` | Styled grade table with matching color palette | Any browser |
| `.xml` | Structured student data (ID, name, grades, average, letter, status) | Any text editor / XML viewer |
| `.xlsx` | Spreadsheet with column headers and all student data | Microsoft Excel, Google Sheets, LibreOffice |

---

## 📚 References

- [Kotlin Higher-Order Functions](https://kotlinlang.org/docs/lambdas.html)
- [Dart Higher-Order Functions](https://dart.dev/guides/language/language-tour#functions)
- [Jetpack Compose for Desktop](https://www.jetbrains.com/lp/compose-multiplatform/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [SheetJS (XLSX export)](https://sheetjs.com/)

---

*Project Milestone 2 — Functional Programming Concepts in Kotlin & Dart*
