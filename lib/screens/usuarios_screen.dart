import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../widgets/usuario_card.dart';
import '../widgets/usuario_form_dialog.dart';
import '../widgets/loading_overlay.dart';
import '../services/relatorio_service.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  List<Usuario> _usuarios = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  String _selectedDepartamento = '';
  String _selectedUF = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
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
      _loadUsuarios();
    }
  }

  Future<void> _loadUsuarios({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await ApiService.getUsuarios(
        page: _currentPage,
        search: _searchQuery,
        departamento: _selectedDepartamento,
        uf: _selectedUF,
      );
      if (result['success']) {
        setState(() {
          _usuarios = result['data'];
          _totalPages = result['pagination']['totalPages'];
        });
      }
    } catch (e) {
      if (mounted && !e.toString().contains('Null')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar usuários: ${e.toString()}'),
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

  Future<void> _refreshUsuarios() async {
    await _loadUsuarios(resetPage: true);
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempDepartamento = _selectedDepartamento;
        String tempUF = _selectedUF;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Buscar e Filtrar Usuários'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Qualquer atributo (nome, CPF, cargo, etc)',
                      ),
                      onSubmitted: (_) {
                        setState(() {
                          _searchQuery = _searchController.text.trim();
                          _selectedDepartamento = tempDepartamento;
                          _selectedUF = tempUF;
                        });
                        _loadUsuarios(resetPage: true);
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: tempDepartamento.isEmpty
                          ? null
                          : tempDepartamento,
                      decoration: const InputDecoration(
                        labelText: 'Departamento',
                      ),
                      items:
                          <String>[
                                '',
                                'TI',
                                'RH',
                                'Financeiro',
                                'Operacional',
                                'Outros',
                              ]
                              .map(
                                (dep) => DropdownMenuItem(
                                  value: dep,
                                  child: Text(dep.isEmpty ? 'Todos' : dep),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          tempDepartamento = value ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: tempUF.isEmpty ? null : tempUF,
                      decoration: const InputDecoration(labelText: 'UF'),
                      items:
                          <String>[
                                '',
                                'AC',
                                'AL',
                                'AP',
                                'AM',
                                'BA',
                                'CE',
                                'DF',
                                'ES',
                                'GO',
                                'MA',
                                'MT',
                                'MS',
                                'MG',
                                'PA',
                                'PB',
                                'PR',
                                'PE',
                                'PI',
                                'RJ',
                                'RN',
                                'RS',
                                'RO',
                                'RR',
                                'SC',
                                'SP',
                                'SE',
                                'TO',
                                'Outros',
                              ]
                              .map(
                                (uf) => DropdownMenuItem(
                                  value: uf,
                                  child: Text(uf.isEmpty ? 'Todos' : uf),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          tempUF = value ?? '';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = _searchController.text.trim();
                      _selectedDepartamento = tempDepartamento;
                      _selectedUF = tempUF;
                    });
                    _loadUsuarios(resetPage: true);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Buscar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editarUsuario(Usuario usuario) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => UsuarioFormDialog(
        usuario: usuario,
        onSaved: (u) async {
          await _refreshUsuarios();
          // Notificar outras páginas sobre a mudança
          Provider.of<NotificationService>(
            context,
            listen: false,
          ).notifyAllChanged();
        },
      ),
    );
    if (updated == true) {
      _refreshUsuarios();
    }
  }

  void _deletarUsuario(Usuario usuario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Usuário'),
        content: Text(
          'Tem certeza que deseja excluir ${usuario.nomeCompleto}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.deleteUsuario(usuario.id);
              Navigator.of(context).pop(true);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _refreshUsuarios();
      // Notificar outras páginas sobre a mudança
      Provider.of<NotificationService>(
        context,
        listen: false,
      ).notifyAllChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Usuários'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showSearchDialog,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshUsuarios,
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Gerar Relatório PDF',
              onPressed: _usuarios.isEmpty
                  ? null
                  : () async {
                      try {
                        await RelatorioUsuarios.gerarPDF(context, _usuarios);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Erro ao gerar PDF:\n${e.toString()}',
                              ),
                              duration: Duration(seconds: 4),
                              // Para Flutter 3.7+:
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _usuarios.length,
                itemBuilder: (context, index) {
                  final usuario = _usuarios[index];
                  return UsuarioCard(
                    usuario: usuario,
                    onEdit: () => _editarUsuario(usuario),
                    onDelete: () => _deletarUsuario(usuario),
                  );
                },
              ),
            ),
            if (_totalPages > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 1
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                              _loadUsuarios();
                            }
                          : null,
                    ),
                    Text('Página $_currentPage de $_totalPages'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentPage < _totalPages
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                              _loadUsuarios();
                            }
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final created = await showDialog<bool>(
              context: context,
              builder: (context) => UsuarioFormDialog(
                onSaved: (u) async {
                  await _refreshUsuarios();
                  // Notificar outras páginas sobre a mudança
                  Provider.of<NotificationService>(
                    context,
                    listen: false,
                  ).notifyAllChanged();
                },
              ),
            );
            if (created == true) {
              _refreshUsuarios();
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
