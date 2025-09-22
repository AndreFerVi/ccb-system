import 'package:flutter/foundation.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _disposed = false;

  // Notificar que funcionários foram alterados
  void notifyUsuariosChanged() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Notificar que equipamentos foram alterados
  void notifyEquipamentosChanged() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Notificar que estatísticas foram alteradas
  void notifyStatsChanged() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Notificar que tudo foi alterado
  void notifyAllChanged() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
