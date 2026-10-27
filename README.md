# SpendWise - Smart Expense Tracker & Daily Budget Manager

A modern, responsive, offline-first personal finance mobile application built with **Flutter**, **Dart**, **Riverpod**, and **SQLite with Drift**.

SpendWise helps users take control of their finances by calculating a dynamic daily spending allowance based on actual calendar month lengths (with leap-year handling), tracking all expenses and income, and providing rich visual reports.

---

## 🚀 Key Features

### 1. Smart Budget Calculations
* **Calendar-Aware Daily Budget**: Automatically calculates planned daily budget using actual calendar days in the month (including leap-year handling for February: 29 days in 2024/2028, 28 days in 2025/2026).
  $$\text{Planned Daily Budget} = \frac{\text{Monthly Budget}}{\text{Days in Selected Month}}$$
* **Indicative Safe-to-Spend Average**: Dynamically recalculates what is safe to spend per remaining day:
  $$\text{Safe-to-Spend Per Remaining Day} = \frac{\text{Remaining Monthly Budget}}{\text{Remaining Days in Month}}$$
* **Optional Unused-Budget Rollover**: When enabled, unused daily budget carries forward to subsequent days of the month.
* **Non-destructive Overspending Display**: When monthly or daily spending exceeds the limit, the overspent amount is highlighted with high-contrast alert badges without hiding or resetting the original budget.
* **Zero Floating-Point Error**: All monetary calculations and database storage use integer minor currency units (paise/cents: ₹1.00 = 100 paise).

### 2. Interactive Dashboard
* **Today's Pulse Card**: Displays remaining allowance to spend today, spent today, today's budget, progress bar, rollover amount badge, and status pill ("On Track", "Nearing Limit", "Daily Limit Exceeded").
* **Monthly Budget Overview**: Shows monthly limit, total spent, remaining balance, utilization percentage, planned daily budget, and safe-to-spend per day.
* **Intelligent Budget Alerts**: Visual non-intrusive banner warnings for 50%, 80%, 100%, and exceeded budget thresholds.
* **Top Spending Categories**: Visual breakdown of top categories with percentage bars and amounts.
* **Recent Transactions**: Quick list with category icons, payment method tags, merchant names, amounts, and bottom-sheet inspector with edit/delete actions.

### 3. Fast Expense & Income Entry
* **Rapid-Entry Interface**: Numeric amount input with quick denomination chips (+₹50, +₹100, +₹500, +₹1,000, +₹2,000).
* **Expense / Income Toggle**: Log both expenses and income sources.
* **Predefined & Custom Categories**: Food & Dining, Groceries, Transport, Shopping, Education, Healthcare, Entertainment, Bills & Utilities, Subscriptions, Other, plus on-the-fly custom category creator with custom icon and color palette.
* **Rich Metadata**: Description, merchant/location, date picker, time picker, payment method (UPI, Cash, Credit Card, Debit Card, Net Banking, Other), and optional notes.
* **Strict Validation**: Validates positive amounts, required fields, and valid dates.

### 4. Daily Tracking Screen
* **Interactive Date Navigator**: Smooth navigation between days (`<`, Date Picker, `>`) and quick jump to "Today".
* **Day Metrics**: Daily budget, total spent, remaining allowance, transaction count.
* **Category Breakdown**: Spending summary for the selected day.
* **Dismissible Transactions**: Swipe-to-delete with confirmation dialog and tap-to-edit.

### 5. Financial Reports (Monthly & Yearly)
* **Monthly Report View**:
  * Total spent, remaining budget, daily average, peak spending day.
  * Month-over-month comparison (% change and difference vs previous month).
  * Daily spending trend bar chart (`fl_chart`).
  * Category breakdown with counts and percentages.
* **Yearly Report View**:
  * Total annual expenditure, total income, net savings.
  * 12-month expense volume comparison bar chart.
  * Peak spending month and lowest spending month.
  * Annual category breakdown.

### 6. Searchable Transaction History
* **Full Search**: Filter by description, merchant, or notes.
* **Filters**: Date range (Start Date & End Date), Category multi-select, Payment method multi-select.
* **Sorting**: Newest first, Oldest first, Highest amount, Lowest amount.
* **Grouped by Date**: Clear date headers ("Today", "Yesterday", "24 Oct 2026").
* **Direct CSV Export**: Export currently filtered transactions directly to CSV.

### 7. Savings Goals Tracker
* Set target savings goals with target amount, current saved amount, target date, and notes.
* Interactive visual progress bar and deposit button ("Add Funds to Goal").
* Kept logically distinct from day-to-day expense allowances.

### 8. Settings & Data Management
* **Monthly Budget Setting**: Configure monthly limit and rollover preference without affecting historical records.
* **Currency Support**: Default INR (₹), with support for USD ($), EUR (€), GBP (£), JPY (¥), CAD, AUD, AED, SGD.
* **Theme Modes**: System Default, Light Theme, Dark Theme.
* **Category Manager**: View and manage predefined and custom categories.
* **Data Export**: Export to RFC 4180 CSV spreadsheet or formatted plain-text financial report.
* **JSON Backup & Restore**: Copy JSON snapshot of all records or restore from JSON backup.

---

## 🛠️ Technology Stack

* **Framework**: Flutter 3.44+ (Android, iOS, Desktop Windows/macOS/Linux, Web)
* **Language**: Dart 3.12+
* **State Management**: Flutter Riverpod 3.x (`NotifierProvider`, `StreamProvider`, `Provider`)
* **Local Persistence**: SQLite with Drift (`drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider`)
* **Data Visualization**: `fl_chart`
* **Typography & Icons**: `google_fonts` (Inter) & Material Icons
* **Preferences**: `shared_preferences`
* **Formatting**: `intl`
* **Unique IDs**: `uuid`

---

## 📂 Project Structure (Clean Architecture)

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # Semantic color palettes for Light & Dark mode
│   │   ├── app_constants.dart      # Currency defaults, payment methods, thresholds
│   │   └── default_categories.dart # Predefined categories, icons & colors
│   ├── theme/
│   │   └── app_theme.dart          # Light and dark themes with Inter typography
│   └── utils/
│       ├── currency_formatter.dart # Minor unit formatting (paise/cents to ₹)
│       ├── date_formatter.dart     # Relative and ISO date formatting
│       └── export_helper.dart      # RFC 4180 CSV and text summary export
├── data/
│   ├── database/
│   │   ├── app_database.dart       # Drift database with migration and seeding
│   │   ├── app_database.g.dart     # Generated Drift SQLite code
│   │   └── tables.dart             # SQLite tables (Expenses, Incomes, Categories, Budgets, Savings)
│   └── repositories/
│       ├── budget_repository.dart
│       ├── category_repository.dart
│       ├── expense_repository.dart
│       ├── income_repository.dart
│       └── savings_repository.dart
├── domain/
│   ├── models/
│   │   ├── budget_calculation.dart # Immutable calculation output model
│   │   ├── budget_settings_model.dart
│   │   ├── category_model.dart
│   │   ├── daily_report.dart
│   │   ├── expense_model.dart
│   │   ├── filter_options.dart
│   │   ├── income_model.dart
│   │   ├── monthly_report.dart
│   │   ├── savings_goal_model.dart
│   │   └── yearly_report.dart
│   └── services/
│       └── budget_calculator.dart  # Pure calculation service with leap-year & rollover logic
├── presentation/
│   ├── providers/
│   │   ├── alert_provider.dart     # Threshold warnings (50%, 80%, 100%, exceeded)
│   │   ├── budget_provider.dart    # Reactive budget calculations & date state
│   │   ├── category_provider.dart  # Stream and lookup map providers
│   │   ├── database_provider.dart  # Database and repository providers
│   │   ├── expense_provider.dart   # Filtered and recent expense streams
│   │   ├── reports_provider.dart   # Daily, monthly, and yearly reports
│   │   ├── savings_provider.dart   # Savings goals streams
│   │   └── settings_provider.dart  # Currency, theme, and alert preferences
│   ├── screens/
│   │   ├── add_expense/
│   │   │   └── add_expense_screen.dart
│   │   ├── daily/
│   │   │   └── daily_tracking_screen.dart
│   │   ├── dashboard/
│   │   │   ├── dashboard_screen.dart
│   │   │   └── widgets/
│   │   │       ├── budget_alert_banner.dart
│   │   │       ├── category_spending_summary.dart
│   │   │       ├── monthly_budget_card.dart
│   │   │       ├── recent_transactions_list.dart
│   │   │       └── today_pulse_card.dart
│   │   ├── main_screen.dart        # 5-tab root navigation scaffold
│   │   ├── reports/
│   │   │   ├── reports_screen.dart
│   │   │   └── widgets/
│   │   │       ├── monthly_report_view.dart
│   │   │       └── yearly_report_view.dart
│   │   ├── savings/
│   │   │   ├── add_savings_goal_dialog.dart
│   │   │   └── savings_screen.dart
│   │   ├── settings/
│   │   │   ├── edit_budget_dialog.dart
│   │   │   ├── export_data_dialog.dart
│   │   │   ├── manage_categories_screen.dart
│   │   │   └── settings_screen.dart
│   │   └── transactions/
│   │       ├── transaction_filter_sheet.dart
│   │       └── transaction_history_screen.dart
│   └── widgets/
│       ├── confirmation_dialog.dart
│       ├── empty_state_view.dart
│       ├── spendwise_card.dart
│       └── status_badge.dart
└── main.dart                       # Application entry point with ProviderScope
```

---

## 🧪 Testing & Verification

The application comes with 22 automated tests covering core calculation mathematics, edge cases, persistence, CSV export, and UI widgets:

```bash
# Run all tests
flutter test

# Run code analysis
flutter analyze
```

### Verified Test Scenarios:
1. Standard 30-day and 31-day months.
2. February leap years (2024, 2028, 2000) vs non-leap years (2025, 2026, 1900).
3. Planned daily budget calculation for ₹30,000 (3,000,000 paise).
4. Zero monthly budget handling.
5. Remaining monthly budget with zero expenses.
6. Expenses equal to monthly budget (100% utilization).
7. Negative balance and overspending amount calculation without hiding budget.
8. Safe-to-spend indicative average per remaining day.
9. Zero and negative remaining days boundary handling.
10. Accumulated rollover logic from past days (under-budget carry forward).
11. Rollover clamping (no negative penalty carried forward).
12. Full budget calculation with rollover disabled vs enabled.
13. SQLite database persistence of expenses, updates, and deletion.
14. Budget settings persistence across restarts.
15. Custom categories creation and persistence.
16. Income entries and savings goals progress tracking.
17. RFC 4180 CSV transaction export formatting.
18. Plain-text financial report generation.
19. Widget smoke testing of main dashboard and navigation tabs.

---

## 🏃 Running the Application

### Prerequisites:
* Flutter SDK (3.44+)
* Dart SDK (3.12+)

### Run on Windows Desktop:
```bash
flutter run -d windows
```

### Run on Chrome / Web:
```bash
flutter run -d chrome
```

### Run on Connected Android Device or Emulator:
```bash
flutter run -d android
```