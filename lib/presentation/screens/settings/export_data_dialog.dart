import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/export_helper.dart';
import '../../providers/category_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';

class ExportDataDialog extends ConsumerStatefulWidget {
  const ExportDataDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const ExportDataDialog(),
    );
  }

  @override
  ConsumerState<ExportDataDialog> createState() => _ExportDataDialogState();
}

class _ExportDataDialogState extends ConsumerState<ExportDataDialog> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _exportFormat = 'csv'; // 'csv' or 'summary'
  String? _generatedOutput;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Export Financial Data', style: TextStyle(fontWeight: FontWeight.w700)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Export Format:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'csv', label: Text('CSV Spreadsheet')),
                  ButtonSegment(value: 'summary', label: Text('Summary Report')),
                ],
                selected: {_exportFormat},
                onSelectionChanged: (set) => setState(() {
                  _exportFormat = set.first;
                  _generatedOutput = null;
                }),
              ),
              const SizedBox(height: 16),
              const Text('Select Date Range:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) setState(() => _startDate = picked);
                      },
                      child: Text(DateFormatter.formatDate(_startDate), style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('to'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) setState(() => _endDate = picked);
                      },
                      child: Text(DateFormatter.formatDate(_endDate), style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Generate Export'),
                onPressed: _generateExport,
              ),
              if (_generatedOutput != null) ...[
                const SizedBox(height: 16),
                const Text('Generated Output:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _generatedOutput!,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy to Clipboard'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _generatedOutput!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export copied to clipboard!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _generateExport() async {
    final expenseRepo = ref.read(expenseRepositoryProvider);
    final categoryMap = ref.read(categoryMapProvider);
    final currencySymbol = ref.read(currencySymbolProvider);

    final all = await expenseRepo.watchAllExpenses().first;
    final filtered = all.where((e) {
      return e.date.isAfter(_startDate.subtract(const Duration(seconds: 1))) &&
          e.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();

    if (_exportFormat == 'csv') {
      final csv = ExportHelper.exportTransactionsToCsv(
        expenses: filtered,
        categories: categoryMap,
        currencySymbol: currencySymbol,
      );
      setState(() => _generatedOutput = csv);
    } else {
      int totalMinor = 0;
      final Map<String, int> catTotals = {};
      for (final e in filtered) {
        totalMinor += e.amountMinor;
        catTotals[e.categoryId] = (catTotals[e.categoryId] ?? 0) + e.amountMinor;
      }

      final summary = ExportHelper.generateSummaryText(
        title: 'Custom Range Financial Summary',
        dateRangeStart: _startDate,
        dateRangeEnd: _endDate,
        totalExpensesMinor: totalMinor,
        totalTransactions: filtered.length,
        categoryTotalsMinor: catTotals,
        categories: categoryMap,
        currencySymbol: currencySymbol,
      );
      setState(() => _generatedOutput = summary);
    }
  }
}
