void main() {
  //"(50/(2*2.3))*5";
  // print("digite uma formula com +,-,*,/ e ()");
  //final formula = stdin.readLineSync() ?? "0";
  final formula = "((34+39)-(49/-1))*((-18/-36)/(40/26))";
  var result = Calculator().evaluateExpression(formula);
  print("\nresultado: $result");
}

enum Operation { sum, minus, times, divide }

class Calculator {
  ///caso seja necessario alterar esse valor, nao esqueça de alterar tambem as expressoes
  ///regex e certifique-se de que o novo valor nao va dar conflito com as expressoes.
  final _minusSafeOperator = "~";

  String evaluateExpression(String f) {

    final notResult = RegExp(r'[0-9]+[-+*/][0-9]+');
    final regexUnaryMinus = RegExp(r'(?<![\d\)])-(?=\s*(?:\d|\())');

    String formula = f.replaceAllMapped(regexUnaryMinus, (_) => '~');

    var newFormula = formula;
    var hasCalcsToDo = true;
    do {
      newFormula = calculateFormula(newFormula);
      /*      hasCalcsToDo =
          (newFormula.contains("+") ||
          newFormula.contains("-") ||
          newFormula.contains("*") ||
          newFormula.contains("/"));*/
      hasCalcsToDo = notResult.hasMatch(newFormula);
    } while (hasCalcsToDo);

    return newFormula;
  }

  String calculateFormula(String formula) {
    print("calculando $formula");

    RegExpMatch? parenthesesMatch = getMatch(r'\(([^()]+)\)', formula);
    if (parenthesesMatch != null) {
      final matches = parenthesesMatch;
      final result = calculateFormula(matches.group(1)!);
      return updateFormula(matches, result, formula);
    }

    var timesMatches = getMatch(r'([.,\d~]+)\*([.,\d~]+)', formula);
    if (timesMatches != null) {
      var (val1, val2) = getValuesFromMatch(timesMatches);
      return evaluateFraction(Operation.times, val1, val2).toString();
    }

    var divideMatches = getMatch(r'([.,\d~]+)/([.,\d~]+)', formula);
    if (divideMatches != null) {
      var (val1, val2) = getValuesFromMatch(divideMatches);
      return evaluateFraction(Operation.divide, val1, val2).toString();
    }

    var sumMatches = getMatch(r'([.,\d~]+)\+([.,\d~]+)', formula);
    if (sumMatches != null) {
      var (val1, val2) = getValuesFromMatch(sumMatches);
      return evaluateFraction(Operation.sum, val1, val2).toString();
    }

    var minusMatches = getMatch(r'([.,\d~]+)-([.,\d~]+)', formula);
    if (minusMatches != null) {
      var (val1, val2) = getValuesFromMatch(minusMatches);
      return evaluateFraction(Operation.minus, val1, val2).toString();
    }

    return formula;
  }

  String updateFormula(RegExpMatch match, String result, String formula) {
    var beforeMatch = formula.substring(0, match.start);
    var afterMatch = formula.substring(match.end);
    return "$beforeMatch$result$afterMatch";
  }

  RegExpMatch? getMatch(String regexPattern, String formula) {
    final regex = RegExp(regexPattern);
    final matches = regex.allMatches(formula);
    final match = matches.firstOrNull;

    return match;
  }

  double evaluateFraction(Operation op, String sVal1, String sVal2) {
    var val1 = double.parse(sVal1);
    var val2 = double.parse(sVal2);

    switch (op) {
      case Operation.sum:
        return val1 + val2;
      case Operation.minus:
        return val1 - val2;
      case Operation.times:
        return val1 * val2;
      case Operation.divide:
        return val1 / val2;
    }
  }

  (String, String) getValuesFromMatch(RegExpMatch matches) {
    var val1 = matches.group(1).toString();
    var val2 = matches.group(2).toString();
    return (applyMinusSafeOperator(val1), applyMinusSafeOperator(val2));
  }

  String applyMinusSafeOperator(String target) {
    return target.replaceAll(_minusSafeOperator, "-");
  }
}

extension Let<T> on T {
  R let<R>(R Function(T) func) => func(this);
}
