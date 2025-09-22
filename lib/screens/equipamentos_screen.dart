import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/equipamento.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../widgets/equipamento_card.dart';
import '../widgets/loading_overlay.dart';

class EquipamentosScreen extends StatefulWidget {
  const EquipamentosScreen({super.key});

  @override
  State<EquipamentosScreen> createState() => _EquipamentosScreenState();
}

class _EquipamentosScreenState extends State<EquipamentosScreen> {
  List<Equipamento> _equipamentos = [];
  bool _isLoading = false;
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEquipamentos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Escutar mudanças nas notificações
    Provider.of<NotificationService>(
      context,
    ).addListener(_onNotificationReceived);
  }

  @override
  void dispose() {
    // Remover listener
    Provider.of<NotificationService>(
      context,
      listen: false,
    ).removeListener(_onNotificationReceived);
    _searchController.dispose();
    super.dispose();
  }

  void _onNotificationReceived() {
    if (mounted) {
      _loadEquipamentos();
    }
  }

  Future<void> _loadEquipamentos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final equipamentos = await ApiService.getEquipamentos(
        search: _searchQuery,
      );

      setState(() {
        _equipamentos = equipamentos;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar equipamentos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshEquipamentos() async {
    await _loadEquipamentos();
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Equipamentos'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Buscar por MAC, funcionário ou tipo',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text.trim();
              });
              Navigator.of(context).pop();
              _loadEquipamentos();
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: RefreshIndicator(
          onRefresh: _refreshEquipamentos,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Equipamentos (${_equipamentos.length})',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: _showSearchDialog,
                      icon: const Icon(Icons.search),
                      tooltip: 'Buscar',
                    ),
                  ],
                ),
              ),

              // Lista de equipamentos
              Expanded(
                child: _equipamentos.isEmpty && !_isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.computer_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum equipamento encontrado',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _equipamentos.length,
                        itemBuilder: (context, index) {
                          final equipamento = _equipamentos[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EquipamentoCard(
                              equipamento: equipamento,
                              onRefresh: _refreshEquipamentos,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
