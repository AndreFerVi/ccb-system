import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/usuario.dart';
import 'package:flutter/material.dart';

class RelatorioUsuarios {
  static Future<void> gerarPDF(BuildContext context, List<Usuario> usuarios) async {
  final pdf = pw.Document();

  try {
    // Fallback para fontes padrão se as customizadas falharem
    final robotoRegular = await PdfGoogleFonts.robotoRegular();
    final robotoBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Relatório de Usuários', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: robotoBold)),
          ),
          pw.TableHelper.fromTextArray(
            headers: ['Nome', 'CPF', 'Departamento', 'Cargo', 'UF', 'Equipamentos'],
            data: usuarios.map((u) => [
              u.nomeCompleto ?? '',
              u.cpf ?? '',
              u.departamento ?? '',
              u.cargoFuncao ?? '',
              u.uf ?? '',
              u.equipamentos.isNotEmpty ? u.equipamentos.map((e) => e.macAddress ?? '').join(', ') : '',
            ]).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  } catch (e) {
    print('Erro ao gerar PDF: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Falha ao gerar PDF: $e')),
    );
  }
}
}
