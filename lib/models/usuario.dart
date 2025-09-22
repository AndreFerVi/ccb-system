import 'equipamento.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class Usuario {
  final int id;
  final String nomeCompleto;
  final DateTime dataNascimento;
  final String cpf;
  final bool adm;
  final String uf;
  final String departamento;
  final String cargoFuncao;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Equipamento> equipamentos;

  Usuario({
    required this.id,
    required this.nomeCompleto,
    required this.dataNascimento,
    required this.cpf,
    required this.adm,
    required this.uf,
    required this.departamento,
    required this.cargoFuncao,
    required this.createdAt,
    required this.updatedAt,
    this.equipamentos = const [],
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    try {
      List<Equipamento> equipamentosList = [];

      if (json['equipamentos'] != null && json['equipamentos'] is List) {
        equipamentosList = (json['equipamentos'] as List)
            .where(
              (e) =>
                  e != null &&
                  e is Map<String, dynamic> &&
                  (e['id'] != null || e['mac_address'] != null),
            )
            .map((e) => Equipamento.fromJson(e))
            .toList();
      }

      return Usuario(
        id: json['id'] is int
            ? json['id']
            : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        nomeCompleto: json['nome_completo']?.toString() ?? '',
        dataNascimento: json['data_nascimento'] != null
            ? DateTime.parse(json['data_nascimento'].toString())
            : DateTime.now(),
        cpf: json['cpf']?.toString() ?? '',
        adm:
            json['adm'] == 1 ||
            json['adm'] == true ||
            json['adm']?.toString() == '1',
        uf: json['uf']?.toString() ?? '',
        departamento: json['departamento']?.toString() ?? '',
        cargoFuncao: json['cargo_funcao']?.toString() ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString())
            : DateTime.now(),
        equipamentos: equipamentosList,
      );
    } catch (e) {
      print('Erro ao criar Usuario.fromJson: $e');
      print('JSON recebido: $json');
      rethrow;
    }
  }

  // Factory para criar usuário apenas com dados básicos (sem equipamentos)
  factory Usuario.fromBasicJson(Map<String, dynamic> json) {
    try {
      return Usuario(
        id:
            (json['id'] as num?)?.toInt() ??
            0, // Melhor tratamento para números
        nomeCompleto: json['nome_completo']?.toString() ?? '',
        dataNascimento: json['data_nascimento'] != null
            ? DateTime.tryParse(json['data_nascimento'].toString()) ??
                  DateTime.now()
            : DateTime.now(),
        cpf: json['cpf']?.toString() ?? '',
        adm:
            json['adm'] == 1 ||
            json['adm'] == true ||
            (json['adm']?.toString() == '1'),
        uf: json['uf']?.toString().toUpperCase() ?? '', // Padroniza UF
        departamento: json['departamento']?.toString() ?? '',
        cargoFuncao: json['cargo_funcao']?.toString() ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        equipamentos: const [],
      );
    } catch (e, stackTrace) {
      debugPrint('Erro ao criar Usuario.fromBasicJson: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('JSON recebido: $json');
      return Usuario(
        id: 0,
        nomeCompleto: '',
        dataNascimento: DateTime.now(),
        cpf: '',
        adm: false,
        uf: '',
        departamento: '',
        cargoFuncao: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        equipamentos: const [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_completo': nomeCompleto,
      'data_nascimento': dataNascimento.toIso8601String().split('T')[0],
      'cpf': cpf,
      'adm': adm,
      'uf': uf,
      'departamento': departamento,
      'cargo_funcao': cargoFuncao,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'equipamentos': equipamentos.map((e) => e.toJson()).toList(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'nome_completo': nomeCompleto,
      'data_nascimento': dataNascimento.toIso8601String().split('T')[0],
      'cpf': cpf,
      'adm': adm,
      'uf': uf,
      'departamento': departamento,
      'cargo_funcao': cargoFuncao,
      'equipamentos': equipamentos.map((e) => e.toCreateJson()).toList(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    Map<String, dynamic> json = {};
    json['nome_completo'] = nomeCompleto;
    json['data_nascimento'] = dataNascimento.toIso8601String().split('T')[0];
    json['cpf'] = cpf;
    json['adm'] = adm;
    json['uf'] = uf;
    json['departamento'] = departamento;
    json['cargo_funcao'] = cargoFuncao;
    // Adiciona equipamentos ao atualizar
    json['equipamentos'] = equipamentos.map((e) => e.toCreateJson()).toList();
    return json;
  }

  String get formattedCpf {
    return cpf.replaceAllMapped(
      RegExp(r'(\d{3})(\d{3})(\d{3})(\d{2})'),
      (Match m) => '${m[1]}.${m[2]}.${m[3]}-${m[4]}',
    );
  }

  String get formattedDataNascimento {
    return '${dataNascimento.day.toString().padLeft(2, '0')}/'
        '${dataNascimento.month.toString().padLeft(2, '0')}/'
        '${dataNascimento.year}';
  }

  int get idade {
    final now = DateTime.now();
    int age = now.year - dataNascimento.year;
    if (now.month < dataNascimento.month ||
        (now.month == dataNascimento.month && now.day < dataNascimento.day)) {
      age--;
    }
    return age;
  }
}
