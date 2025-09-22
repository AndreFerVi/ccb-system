import '../models/usuario.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import '../models/funcionario.dart';
import '../models/equipamento.dart';

class ApiService {
  static const String baseUrl = 'https://ccb-backend-lhs3.onrender.com/api';
  static String? _token;

  // Inicializar token do SharedPreferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Salvar token
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Remover token
  static Future<void> removeToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Obter headers com autenticação
  static Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Tratar resposta da API
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      // Adicione tratamento específico para diferentes códigos de status
      switch (response.statusCode) {
        case 400:
          throw Exception(data['message'] ?? 'Requisição inválida');
        case 401:
          throw Exception(data['message'] ?? 'Não autorizado');
        case 403:
          throw Exception(data['message'] ?? 'Acesso proibido');
        case 404:
          throw Exception(data['message'] ?? 'Recurso não encontrado');
        case 500:
          throw Exception(data['message'] ?? 'Erro interno do servidor');
        default:
          throw Exception(
            data['message'] ??
                'Falha na requisição com status ${response.statusCode}',
          );
      }
    }
  }

  // AUTH ENDPOINTS

  // Login
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: json.encode({'username': username, 'password': password}),
      );

      final data = _handleResponse(response);

      if (data['success'] && data['data']['token'] != null) {
        await saveToken(data['data']['token']);
      }

      return data;
    } on SocketException {
      throw Exception('Erro de conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Verificar token
  static Future<Map<String, dynamic>> verifyToken() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: _getHeaders(),
      );

      return _handleResponse(response);
    } on SocketException {
      throw Exception('Erro de conexão. Verifique sua internet.');
    } catch (e) {
      await removeToken();
      throw Exception(e.toString());
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _getHeaders(),
      );

      await removeToken();
      return _handleResponse(response);
    } catch (e) {
      await removeToken();
      throw Exception(e.toString());
    }
  }

  // USUÁRIOS ENDPOINTS
  static Future<Map<String, dynamic>> getUsuarios({
    int page = 1,
    int limit = 10,
    String search = '',
    String departamento = '',
    String uf = '',
  }) async {
    try {
      final queryParams = {'page': page.toString(), 'limit': limit.toString()};
      if (search.isNotEmpty) queryParams['search'] = search;
      if (departamento.isNotEmpty) queryParams['departamento'] = departamento;
      if (uf.isNotEmpty) queryParams['uf'] = uf;
      final uri = Uri.parse(
        '$baseUrl/usuarios',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders());
      final data = _handleResponse(response);
      if (data['success']) {
        final usuarios = (data['data'] as List)
            .map((json) => Usuario.fromJson(json))
            .toList();
        return {
          'success': true,
          'data': usuarios,
          'pagination': data['pagination'],
        };
      }
      return data;
    } on SocketException {
      throw Exception('Erro de conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Usuario> getUsuario(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: _getHeaders(),
      );
      final data = _handleResponse(response);
      if (data['success']) {
        return Usuario.fromJson(data['data']);
      }
      throw Exception(data['message']);
    } on SocketException {
      throw Exception('Erro de conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Usuario> createUsuario(Usuario usuario) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: _getHeaders(),
        body: json.encode(usuario.toCreateJson()),
      );
      final data = _handleResponse(response);
      if (data['success']) {
        return Usuario.fromJson(data['data']);
      }
      throw Exception(data['message']);
    } on SocketException {
      throw Exception('Erro de conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Usuario> updateUsuario(int id, Usuario usuario) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: _getHeaders(),
        body: json.encode(usuario.toUpdateJson()),
      );
      final data = _handleResponse(response);
      if (data['success']) {
        return Usuario.fromJson(data['data']);
      }
      throw Exception(data['message']);
    } on SocketException {
      throw Exception('Erro de conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<void> deleteUsuario(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: _getHeaders(),
      );
      final data = _handleResponse(response);
      if (!data['success']) {
        throw Exception(data['message']);
      }
    } on SocketException {
      throw Exception('Erro de conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Estatísticas por departamento
  static Future<List<Map<String, dynamic>>> getDepartamentosStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/stats/departamentos'),
        headers: _getHeaders(),
      );

      final data = _handleResponse(response);

      if (data['success']) {
        return List<Map<String, dynamic>>.from(data['data']);
      }

      throw Exception(data['message']);
    } on SocketException {
      throw Exception('Erro de conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // EQUIPAMENTOS ENDPOINTS

  // Listar equipamentos
  static Future<List<Equipamento>> getEquipamentos({
    int? usuarioId,
    String search = '',
  }) async {
    try {
      final queryParams = <String, String>{};

      if (usuarioId != null) {
        queryParams['usuario_id'] = usuarioId.toString();
      }
      if (search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(
        '$baseUrl/equipamentos',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getHeaders());
      final data = _handleResponse(response);

      if (data['success']) {
        return (data['data'] as List)
            .map((json) => Equipamento.fromJson(json))
            .toList();
      }

      throw Exception(data['message']);
    } on SocketException {
      throw Exception('Erro de conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Buscar equipamento por ID
  static Future<Equipamento> getEquipamento(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipamentos/$id'),
        headers: _getHeaders(),
      );

      final data = _handleResponse(response);

      if (data['success']) {
        return Equipamento.fromJson(data['data']);
      }

      throw Exception(data['message']);
    } on SocketException {
      throw Exception('Erro de conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Criar equipamento
  static Future<Equipamento> createEquipamento(Equipamento equipamento) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/equipamentos'),
        headers: _getHeaders(),
        body: json.encode(equipamento.toCreateJson()),
      );

      final data = _handleResponse(response);

      if (data['success']) {
        return Equipamento.fromJson(data['data']);
      }

      throw Exception(data['message']);
    } on SocketException {
      throw Exception('Erro de conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Atualizar equipamento
  static Future<Equipamento> updateEquipamento(
    int id,
    Equipamento equipamento,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/equipamentos/$id'),
        headers: _getHeaders(),
        body: json.encode({
          'mac_address': equipamento.macAddress,
          'tipo_equipamento': equipamento.tipoEquipamento,
        }),
      );

      final data = _handleResponse(response);

      if (data['success']) {
        return Equipamento.fromJson(data['data']);
      }

      throw Exception(data['message']);
    } on SocketException {
      throw Exception('Erro de conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Excluir equipamento
  static Future<void> deleteEquipamento(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/equipamentos/$id'),
        headers: _getHeaders(),
      );

      final data = _handleResponse(response);

      if (!data['success']) {
        throw Exception(data['message']);
      }
    } on SocketException {
      throw Exception('Erro de conexão. Verifique sua internet.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
