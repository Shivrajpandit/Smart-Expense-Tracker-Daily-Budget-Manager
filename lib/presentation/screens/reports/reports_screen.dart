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
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _pickDate(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        _isMonthly
                            ? DateFormatter.formatShortMonthYear(DateTime(monthYear.year, monthYear.month, 1))
                            : '${monthYear.year}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented selector: Monthly vs Yearly
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Monthly Report', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    icon: Icon(Icons.calendar_view_month, size: 16),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Yearly Report', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    icon: Icon(Icons.calendar_today, size: 16),
                  ),
                ],
                selected: {_isMonthly},
                onSelectionChanged: (set) => setState(() => _isMonthly = set.first),
              ),
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
