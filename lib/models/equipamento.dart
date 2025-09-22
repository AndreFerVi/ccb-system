class Equipamento {
  final int id;
  final int usuarioId;
  final String macAddress;
  final String tipoEquipamento;
  final DateTime createdAt;
  final DateTime updatedAt;

  Equipamento({
    required this.id,
    required this.usuarioId,
    required this.macAddress,
    required this.tipoEquipamento,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Equipamento.fromJson(Map<String, dynamic> json) {
    try {
      return Equipamento(
        id: json['id'] is int
            ? json['id']
            : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        usuarioId: json['usuario_id'] is int
            ? json['usuario_id']
            : int.tryParse(json['usuario_id']?.toString() ?? '0') ?? 0,
        macAddress: json['mac_address']?.toString() ?? '',
        tipoEquipamento: json['tipo_equipamento']?.toString() ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString())
            : DateTime.now(),
      );
    } catch (e) {
      print('Erro ao criar Equipamento.fromJson: $e');
      print('JSON recebido: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'mac_address': macAddress,
      'tipo_equipamento': tipoEquipamento,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'usuario_id': usuarioId,
      'mac_address': macAddress,
      'tipo_equipamento': tipoEquipamento,
    };
  }
}
