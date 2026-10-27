import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/budget_provider.dart';
import 'widgets/monthly_report_view.dart';
import 'widgets/yearly_report_view.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _isMonthly = true;

  @override
  Widget build(BuildContext context) {
    final monthYear = ref.watch(selectedMonthYearProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Reports',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ActionChip(
              avatar: const Icon(Icons.calendar_month, size: 16),
              label: Text(
                _isMonthly
                    ? DateFormatter.formatShortMonthYear(DateTime(monthYear.year, monthYear.month, 1))
                    : '${monthYear.year}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              onPressed: () => _pickDate(context),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented selector: Monthly vs Yearly
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Monthly Report'),
                  icon: Icon(Icons.calendar_view_month, size: 16),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Yearly Report'),
                  icon: Icon(Icons.calendar_today, size: 16),
                ),
              ],
              selected: {_isMonthly},
              onSelectionChanged: (set) => setState(() => _isMonthly = set.first),
            ),
          ),

          Expanded(
            child: _isMonthly ? const MonthlyReportView() : const YearlyReportView(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final current = ref.read(selectedMonthYearProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(current.year, current.month, 1),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      ref.read(selectedMonthYearProvider.notifier).state =
          MonthYear(year: picked.year, month: picked.month);
    }
  }
}
