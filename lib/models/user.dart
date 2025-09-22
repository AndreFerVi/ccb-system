class User {
  final int id;
  final String? username;
  final int? usuarioId;

  User({required this.id, this.username, this.usuarioId});

  factory User.fromJson(Map<String, dynamic> json) {
    // Tratar id como obrigatório, mas com fallback seguro
    int id;
    if (json['id'] is int) {
      id = json['id'];
    } else if (json['id'] is String) {
      id = int.tryParse(json['id']) ?? 0;
    } else {
      id = 0;
    }

    // Tratar usuarioId de forma segura
    int? usuarioId;
    if (json['usuarioId'] == null) {
      usuarioId = null;
    } else if (json['usuarioId'] is int) {
      usuarioId = json['usuarioId'];
    } else if (json['usuarioId'] is String) {
      usuarioId = int.tryParse(json['usuarioId']);
    } else {
      usuarioId = null;
    }

    // Tratar username de forma segura
    String? username;
    if (json['username'] != null) {
      username = json['username'].toString();
    }

    return User(id: id, username: username, usuarioId: usuarioId);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (username != null) 'username': username,
      'usuarioId': usuarioId,
    };
  }
}
