class Person {
  final String name;
  final int age;
  Person(this.name, this.age);
}

void main() {
  var people = [
    Person("Alice", 25),
    Person("Bob", 30),
    Person("Charlie", 35),
    Person("Anna", 22),
    Person("Ben", 28),
  ];

  var filtered = people
      .where((p) => p.name.startsWith("A") || p.name.startsWith("B"))
      .toList();

  var avgAge = filtered.map((p) => p.age).reduce((a, b) => a + b) / filtered.length;

  print("Average age: ${avgAge.toStringAsFixed(1)}");
}