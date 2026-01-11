const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
const _latinDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

extension StringNumberConverter on String {
  String toLatinNumbers() {
    String result = this;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(_arabicDigits[i], _latinDigits[i]);
    }
    return result;
  }
}

extension IntNumberConverter on int {
  String toLatinString() {
    return toString();
  }
}
