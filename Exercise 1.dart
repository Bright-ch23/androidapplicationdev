List<int> processList(List<int> numbers, bool Function(int) predicate) {
  return numbers.where(predicate).toList();
}

void main() {
  var nums = [1, 2, 3, 4, 5, 6];
  var even = processList(nums, (it) => it % 2 == 0);
  print(even); // [2, 4, 6]
}