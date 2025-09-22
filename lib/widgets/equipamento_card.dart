import 'package:flutter/material.dart';
import '../models/equipamento.dart';
import '../services/api_service.dart';

class EquipamentoCard extends StatefulWidget {
  final Equipamento equipamento;
  final VoidCallback onRefresh;

  const EquipamentoCard({
    super.key,
    required this.equipamento,
    required this.onRefresh,
  });

  @override
  State<EquipamentoCard> createState() => _EquipamentoCardState();
}

class _EquipamentoCardState extends State<EquipamentoCard> {
  bool _isEditing = false;
  final _macController = TextEditingController();
  final _tipoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _macController.text = widget.equipamento.macAddress;
    _tipoController.text = widget.equipamento.tipoEquipamento;
  }

  @override
  void dispose() {
    _macController.dispose();
    _tipoController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    try {
      final updatedEquipamento = Equipamento(
        id: widget.equipamento.id,
        usuarioId: widget.equipamento.usuarioId,
        macAddress: _macController.text.trim(),
        tipoEquipamento: _tipoController.text.trim(),
        createdAt: widget.equipamento.createdAt,
        updatedAt: DateTime.now(),
      );

      await ApiService.updateEquipamento(
        widget.equipamento.id,
        updatedEquipamento,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipamento atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {
        _isEditing = false;
      });

      widget.onRefresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar equipamento: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteEquipamento() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir o equipamento ${widget.equipamento.macAddress}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteEquipamento(widget.equipamento.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Equipamento excluído com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        widget.onRefresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir equipamento: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.computer, color: Colors.blue[600], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.equipamento.tipoEquipamento,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    } else if (value == 'delete') {
                      await _deleteEquipamento();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_isEditing) ...[
              // Modo de edição
              TextField(
                controller: _macController,
                decoration: const InputDecoration(
                  labelText: 'MAC Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Equipamento',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                      });
                      _macController.text = widget.equipamento.macAddress;
                      _tipoController.text = widget.equipamento.tipoEquipamento;
                    },
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ] else ...[
              // Modo de visualização
              Row(
                children: [
                  Icon(Icons.wifi, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    widget.equipamento.macAddress,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Usuário ID: ${widget.equipamento.usuarioId}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Cadastrado em: ${widget.equipamento.createdAt.day}/${widget.equipamento.createdAt.month}/${widget.equipamento.createdAt.year}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
