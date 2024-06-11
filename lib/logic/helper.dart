class Helper {
  static String toCurrencyFormat(double value) {
    // 2 decimal places and ',' for thousands
    var temp = value.toStringAsFixed(2);
    var parts = temp.split('.');
    var whole = parts[0];
    var decimal = parts[1];
    var result = '';
    for (var i = 0; i < whole.length; i++) {
      if (i != 0 && i % 3 == 0) {
        result = ',$result';
      }
      result = whole[whole.length - 1 - i] + result;
    }
    return '$result.$decimal';
  }
}