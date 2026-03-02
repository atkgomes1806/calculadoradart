import 'dart:io';

void main(){
  bool continuarOperando = true;
  
  while (continuarOperando) {
    print('Digite a operação desejada (ex: 2+2-1):');
    String? entrada = stdin.readLineSync();
    
    // Validar entrada vazia
    if (entrada == null || entrada.isEmpty) {
      print('Erro: Entrada vazia! Digite uma expressão matemática.');
      continue;
    }
    
    String operacao = entrada.replaceAll(' ', '');
    
    // Validar entrada
    String? erro = validarEntrada(operacao);
    if (erro != null) {
      print('Erro: $erro');
      continue;
    }
    
    try {
      double resultado = calcular(operacao);
      print('Resultado: $resultado');
    } catch (e) {
      print('Erro durante o cálculo: $e');
    }
    
    // Pergunta ao usuário se deseja fazer uma nova operação
    print('\nDeseja fazer outra operação? (s/n):');
    String? resposta = stdin.readLineSync();
    
    if (resposta != null && resposta.toLowerCase() == 's') {
      print('');
      continuarOperando = true;
    } else {
      print('Encerrando a calculadora. Até logo!');
      continuarOperando = false;
    }
  }
}

String? validarEntrada(String expressao) {
  // Verificar se está vazio
  if (expressao.isEmpty) {
    return 'Entrada vazia!';
  }
  
  // Verificar se contém apenas números
  if (RegExp(r'^[0-9.]+$').hasMatch(expressao)) {
    return 'Digite uma operação matemática válida. Exemplo: 2+3 ou 10-5';
  }
  
  // Verificar se começa com operador
  if (expressao[0] == '+' || expressao[0] == '-' || expressao[0] == '*' || expressao[0] == '/') {
    return 'A expressão não pode começar com um operador.';
  }
  
  // Verificar se termina com operador
  String ultimoChar = expressao[expressao.length - 1];
  if (ultimoChar == '+' || ultimoChar == '-' || ultimoChar == '*' || ultimoChar == '/') {
    return 'A expressão não pode terminar com um operador.';
  }
  
  // Verificar caracteres inválidos
  for (int i = 0; i < expressao.length; i++) {
    String char = expressao[i];
    bool ehNumero = char.contains(RegExp(r'[0-9.]'));
    bool ehOperador = char == '+' || char == '-' || char == '*' || char == '/';
    
    if (!ehNumero && !ehOperador) {
      return 'Caractere inválido encontrado: "$char". Use apenas números (0-9), ponto (.) e operadores (+, -, *, /).';
    }
  }
  
  // Verificar operadores duplicados consecutivos
  if (expressao.contains('++') || expressao.contains('--') || 
      expressao.contains('**') || expressao.contains('//') ||
      expressao.contains('+-') || expressao.contains('-+') ||
      expressao.contains('*+') || expressao.contains('+*') ||
      expressao.contains('*/') || expressao.contains('/*') ||
      expressao.contains('/-') || expressao.contains('-/')) {
    return 'Operadores duplicados ou consecutivos encontrados.';
  }
  
  // Verificar múltiplos pontos em um número
  List<String> partes = expressao.split(RegExp(r'[+\-*/]'));
  for (String parte in partes) {
    if (parte.isEmpty) continue;
    if (parte.contains('.')) {
      int contadorPontos = '.'.allMatches(parte).length;
      if (contadorPontos > 1) {
        return 'Número inválido: "$parte" contém múltiplos pontos decimais.';
      }
    }
  }
  
  return null; // Nenhum erro encontrado
}

double calcular(String expressao) {
  // Separar números e operadores
  List<double> numeros = [];
  List<String> operadores = [];
  
  String numero = '';
  
  for (int i = 0; i < expressao.length; i++) {
    String char = expressao[i];
    
    if (char == '+' || char == '-' || char == '*' || char == '/') {
      if (numero.isEmpty) {
        throw 'Erro: Operador "$char" sem número antes dele.';
      }
      try {
        numeros.add(double.parse(numero));
      } catch (e) {
        throw 'Erro: Não foi possível converter "$numero" para número.';
      }
      operadores.add(char);
      numero = '';
    } else {
      numero += char;
    }
  }
  
  if (numero.isEmpty) {
    throw ('Erro: A expressão termina com um operador.');
  }
  
  try {
    numeros.add(double.parse(numero));
  } catch (e) {
    throw 'Erro: Não foi possível converter "$numero" para número.';
  }
  
  // Primeira passagem: multiplicação e divisão
  for (int i = 0; i < operadores.length; i++) {
    if (operadores[i] == '*') {
      numeros[i] = numeros[i] * numeros[i + 1];
      numeros.removeAt(i + 1);
      operadores.removeAt(i);
      i--;
    } else if (operadores[i] == '/') {
      // Validar divisão por zero
      if (numeros[i + 1] == 0) {
        throw 'Erro: Divisão por zero! Não é possível dividir por 0.';
      }
      numeros[i] = numeros[i] / numeros[i + 1];
      numeros.removeAt(i + 1);
      operadores.removeAt(i);
      i--;
    }
  }
  
  // Segunda passagem: adição e subtração
  double resultado = numeros[0];
  for (int i = 0; i < operadores.length; i++) {
    if (operadores[i] == '+') {
      resultado += numeros[i + 1];
    } else if (operadores[i] == '-') {
      resultado -= numeros[i + 1];
    }
  }
  
  return resultado;
}