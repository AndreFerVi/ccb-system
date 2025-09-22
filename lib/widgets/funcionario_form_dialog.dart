import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/usuario.dart';
import '../models/equipamento.dart';
import 'custom_text_field.dart';

class UsuarioFormDialog extends StatefulWidget {
  final Usuario? usuario;
  final Function(Usuario) onSaved;

  const UsuarioFormDialog({
    super.key,
    this.usuario,
    required this.onSaved,
  });

  @override
  State<UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends State<UsuarioFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _departamentoController = TextEditingController();
  final _cargoController = TextEditingController();

  DateTime? _dataNascimento;
  bool _isAdm = false;
  String _selectedUF = 'SP';
  List<EquipamentoForm> _equipamentos = [];

  final List<String> _ufs = [
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
  ];

  @override
  void initState() {
    super.initState();
    if (widget.usuario != null) {
      _loadUsuarioData();
    } else {
      _equipamentos.add(EquipamentoForm());
    }
  }

  void _loadUsuarioData() {
    final usuario = widget.usuario!;
    _nomeController.text = usuario.nomeCompleto;
    _cpfController.text = usuario.cpf;
    _departamentoController.text = usuario.departamento;
    _cargoController.text = usuario.cargoFuncao;
    _dataNascimento = usuario.dataNascimento;
    _isAdm = usuario.adm;
    _selectedUF = usuario.uf;

    _equipamentos = usuario.equipamentos
        .map(
          (e) => EquipamentoForm(
            macAddress: e.macAddress,
            tipoEquipamento: e.tipoEquipamento,
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _departamentoController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  String? _validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }

    // Remove formatação
    final cpf = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return 'CPF inválido';
    }

    // Validação básica dos dígitos verificadores
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int remainder = sum % 11;
    int digit1 = remainder < 2 ? 0 : 11 - remainder;

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    remainder = sum % 11;
    int digit2 = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cpf[9]) != digit1 || int.parse(cpf[10]) != digit2) {
      return 'CPF inválido';
    }

    return null;
  }

  String? _validateMACAddress(String? value) {
    if (value == null || value.isEmpty) {
      return null; // MAC Address não é obrigatório se estiver vazio
    }

    final macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    if (!macRegex.hasMatch(value)) {
      return 'MAC Address inválido (formato: XX:XX:XX:XX:XX:XX)';
    }

    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _dataNascimento ??
          DateTime.now().subtract(const Duration(days: 6570)), // 18 anos atrás
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(
        const Duration(days: 5840),
      ), // 16 anos atrás
    );

    if (picked != null && picked != _dataNascimento) {
      setState(() {
        _dataNascimento = picked;
      });
    }
  }

  void _addEquipamento() {
    if (_equipamentos.length < 3) {
      setState(() {
        _equipamentos.add(EquipamentoForm());
      });
    }
  }

  void _removeEquipamento(int index) {
    setState(() {
      _equipamentos.removeAt(index);
    });
  }

  void _saveUsuario() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_dataNascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data de nascimento é obrigatória')),
      );
      return;
    }

    final equipamentos = _equipamentos
        .where((e) => e.macAddress.isNotEmpty)
        .map(
          (e) => Equipamento(
            id: 0, // Será definido pelo backend
            usuarioId: 0, // Será definido pelo backend
            macAddress: e.macAddress,
            tipoEquipamento: e.tipoEquipamento,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        )
        .toList();

    // Formatar CPF para o padrão esperado pelo backend
    String cpfFormatted = _cpfController.text.trim();
    if (!cpfFormatted.contains('.')) {
      // Se não tem pontos, adicionar formatação
      cpfFormatted = cpfFormatted.replaceAll(RegExp(r'[^\d]'), '');
      if (cpfFormatted.length == 11) {
        cpfFormatted =
            '${cpfFormatted.substring(0, 3)}.${cpfFormatted.substring(3, 6)}.${cpfFormatted.substring(6, 9)}-${cpfFormatted.substring(9)}';
      }
    }

    final usuario = Usuario(
      id: widget.usuario?.id ?? 0,
      nomeCompleto: _nomeController.text.trim(),
      dataNascimento: _dataNascimento!,
      cpf: cpfFormatted,
      adm: _isAdm,
      uf: _selectedUF,
      departamento: _departamentoController.text.trim(),
      cargoFuncao: _cargoController.text.trim(),
      createdAt: widget.usuario?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      equipamentos: equipamentos,
    );

    widget.onSaved(usuario);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              widget.usuario == null
                  ? 'Novo Funcionário'
                  : 'Editar Funcionário',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Nome Completo
                      CustomTextField(
                        controller: _nomeController,
                        label: 'Nome Completo',
                        hint: 'Digite o nome completo',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nome completo é obrigatório';
                          }
                          if (value.trim().length < 2) {
                            return 'Nome deve ter pelo menos 2 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Data de Nascimento
                      GestureDetector(
                        onTap: _selectDate,
                        child: AbsorbPointer(
                          child: CustomTextField(
                            controller: TextEditingController(
                              text: _dataNascimento != null
                                  ? DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_dataNascimento!)
                                  : '',
                            ),
                            label: 'Data de Nascimento',
                            hint: 'Selecione a data de nascimento',
                            prefixIcon: Icons.calendar_today,
                            validator: (value) {
                              if (_dataNascimento == null) {
                                return 'Data de nascimento é obrigatória';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // CPF
                      CustomTextField(
                        controller: _cpfController,
                        label: 'CPF',
                        hint: '000.000.000-00',
                        prefixIcon: Icons.badge,
                        keyboardType: TextInputType.number,
                        validator: _validateCPF,
                        maxLength: 14,
                      ),
                      const SizedBox(height: 16),

                      // ADM Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _isAdm,
                            onChanged: (value) {
                              setState(() {
                                _isAdm = value ?? false;
                              });
                            },
                          ),
                          const Text('Administrador'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // UF
                      DropdownButtonFormField<String>(
                        initialValue: _selectedUF,
                        decoration: const InputDecoration(
                          labelText: 'UF',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        items: _ufs
                            .map(
                              (uf) =>
                                  DropdownMenuItem(value: uf, child: Text(uf)),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUF = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Departamento
                      CustomTextField(
                        controller: _departamentoController,
                        label: 'Departamento',
                        hint: 'Ex: TI, RH, Vendas',
                        prefixIcon: Icons.business,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Departamento é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Cargo/Função
                      CustomTextField(
                        controller: _cargoController,
                        label: 'Cargo/Função',
                        hint: 'Ex: Desenvolvedor, Analista',
                        prefixIcon: Icons.work,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Cargo/Função é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Equipamentos
                      Row(
                        children: [
                          Text(
                            'Equipamentos (${_equipamentos.length}/3)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_equipamentos.length < 3)
                            IconButton(
                              onPressed: _addEquipamento,
                              icon: const Icon(Icons.add),
                              tooltip: 'Adicionar equipamento',
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      ...List.generate(_equipamentos.length, (index) {
                        final equipamento = _equipamentos[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Equipamento ${index + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () =>
                                            _removeEquipamento(index),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Remover equipamento',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller:
                                        equipamento.macAddressController,
                                    decoration: const InputDecoration(
                                      labelText: 'MAC Address',
                                      hintText: '00:1B:44:11:3A:B7',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: _validateMACAddress,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller:
                                        equipamento.tipoEquipamentoController,
                                    decoration: const InputDecoration(
                                      labelText: 'Tipo de Equipamento',
                                      hintText: 'Computador, Notebook, etc.',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveUsuario,
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EquipamentoForm {
  final TextEditingController macAddressController;
  final TextEditingController tipoEquipamentoController;

  EquipamentoForm({String? macAddress, String? tipoEquipamento})
    : macAddressController = TextEditingController(text: macAddress ?? ''),
      tipoEquipamentoController = TextEditingController(
        text: tipoEquipamento ?? 'Computador',
      );

  String get macAddress => macAddressController.text.trim();
  String get tipoEquipamento => tipoEquipamentoController.text.trim();
}
