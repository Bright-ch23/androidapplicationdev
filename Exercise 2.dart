void main() {
  var words = ["apple", "cat", "banana", "dog", "elephant"];

  var wordLengths = {for (var w in words) w: w.length};

  wordLengths
      .entries
      .where((e) => e.value > 4)
      .forEach((e) => print("${e.key} has length ${e.value}"));
}