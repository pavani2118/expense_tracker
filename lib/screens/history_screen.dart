import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/expense_service.dart';
import 'add_edit_expense_screen.dart';

class HistoryScreen extends StatefulWidget {
  final ExpenseService expenseService;

  const HistoryScreen({super.key, required this.expenseService});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All Categories';
  String _selectedDateFilter = 'All Dates';

  // Only changes when Search is submitted.
  String _searchQuery = '';

  DateTime? _customDate;

  final List<String> _categories = [
    'All Categories',
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Entertainment',
    'Education',
    'Other',
  ];

  final List<String> _dateFilters = [
    'All Dates',
    'Today',
    'This Month',
    'Select Date',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch() {
    FocusScope.of(context).unfocus();

    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  Future<void> _pickFilterDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _customDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _customDate = pickedDate;
      _selectedDateFilter = 'Select Date';
    });
  }

  bool _matchesCategory(Expense expense) {
    if (_selectedCategory == 'All Categories') {
      return true;
    }

    return expense.category == _selectedCategory;
  }

  bool _matchesDate(Expense expense) {
    if (_selectedDateFilter == 'All Dates') {
      return true;
    }

    final now = DateTime.now();

    if (_selectedDateFilter == 'Today') {
      return expense.date.year == now.year &&
          expense.date.month == now.month &&
          expense.date.day == now.day;
    }

    if (_selectedDateFilter == 'This Month') {
      return expense.date.year == now.year && expense.date.month == now.month;
    }

    if (_selectedDateFilter == 'Select Date' && _customDate != null) {
      return expense.date.year == _customDate!.year &&
          expense.date.month == _customDate!.month &&
          expense.date.day == _customDate!.day;
    }

    return true;
  }

  bool _matchesSearch(Expense expense) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return true;
    }

    final title = expense.title.toLowerCase();

    final category = expense.category.toLowerCase();

    final note = (expense.note ?? '').toLowerCase();

    return title.contains(query) ||
        category.contains(query) ||
        note.contains(query);
  }

  bool get _filtersActive {
    return _selectedCategory != 'All Categories' ||
        _selectedDateFilter != 'All Dates' ||
        _searchQuery.trim().isNotEmpty;
  }

  void _clearFilters() {
    _searchController.clear();

    FocusScope.of(context).unfocus();

    setState(() {
      _selectedCategory = 'All Categories';

      _selectedDateFilter = 'All Dates';

      _customDate = null;

      _searchQuery = '';
    });
  }

  void _openEditScreen(BuildContext context, Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditExpenseScreen(
          expenseService: widget.expenseService,
          expense: expense,
        ),
      ),
    );
  }

  Future<void> _deleteExpense(BuildContext context, Expense expense) async {
    if (expense.id == null) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          icon: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline,
              color: scheme.onErrorContainer,
              size: 28,
            ),
          ),
          title: const Text('Delete Expense?', textAlign: TextAlign.center),
          content: Text(
            'Are you sure you want to delete '
            '"${expense.title}"? This action cannot be undone.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await widget.expenseService.deleteExpense(expense.id!);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted successfully')),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete expense')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense History',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            Text(
              'Review and manage your spending',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Expense>>(
        stream: widget.expenseService.getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(context);
          }

          final expenses = snapshot.data ?? [];

          final filteredExpenses = expenses.where((expense) {
            return _matchesCategory(expense) &&
                _matchesDate(expense) &&
                _matchesSearch(expense);
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _buildHeader(context, expenses.length),

              const SizedBox(height: 22),

              _buildFilterCard(context),

              const SizedBox(height: 24),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'All Expenses',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${filteredExpenses.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (expenses.isEmpty)
                _buildEmptyState(context)
              else if (filteredExpenses.isEmpty)
                _buildNoResultsState(context)
              else
                ...filteredExpenses.map(
                  (expense) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildExpenseCard(context, expense),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int totalExpenses) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer,
            scheme.primaryContainer.withValues(alpha: 0.45),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.history_rounded,
              color: scheme.onPrimary,
              size: 27,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Spending History',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalExpenses '
                  '${totalExpenses == 1 ? 'expense' : 'expenses'} recorded',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      key: const Key('history_filter_card'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: scheme.onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'Filter & Search',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),

                if (_filtersActive)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear'),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              key: const Key('expense_search_field'),
              controller: _searchController,
              textInputAction: TextInputAction.search,

              // Important:
              // typing does NOT update
              // _searchQuery.
              onSubmitted: (_) {
                _applySearch();
              },

              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  key: const Key('expense_search_button'),
                  tooltip: 'Search',
                  onPressed: _applySearch,
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ),
            ),

            if (_searchQuery.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.search_rounded, size: 16, color: scheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Searching for: '
                      '"$_searchQuery"',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              key: const Key('category_filter'),
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              key: const Key('date_filter'),
              initialValue: _selectedDateFilter,
              decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Icons.calendar_month_outlined),
              ),
              items: _dateFilters.map((filter) {
                return DropdownMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
              onChanged: (value) async {
                if (value == null) {
                  return;
                }

                if (value == 'Select Date') {
                  await _pickFilterDate();
                  return;
                }

                setState(() {
                  _selectedDateFilter = value;

                  _customDate = null;
                });
              },
            ),

            if (_selectedDateFilter == 'Select Date' &&
                _customDate != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_rounded, size: 18, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Selected: '
                      '${_customDate!.day}/'
                      '${_customDate!.month}/'
                      '${_customDate!.year}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, Expense expense) {
    final scheme = Theme.of(context).colorScheme;

    final categoryColor = _categoryColor(context, expense.category);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          _openEditScreen(context, expense);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _categoryIcon(expense.category),
                  color: categoryColor,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${expense.category} • '
                      '${expense.date.day}/'
                      '${expense.date.month}/'
                      '${expense.date.year}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),

                    if (expense.note != null &&
                        expense.note!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        expense.note!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${expense.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 3),

                  IconButton(
                    tooltip: 'Delete',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.delete_outline,
                      size: 21,
                      color: scheme.error,
                    ),
                    onPressed: () {
                      _deleteExpense(context, expense);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 34,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'No expenses yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          Text(
            'Your expense history will appear here once you add your first expense.',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 58, color: scheme.primary),
          const SizedBox(height: 14),
          const Text(
            'No expenses found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          Text(
            'Try changing your search or filter options.',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 34,
                color: scheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 7),
            Text(
              'We could not load your expenses. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(BuildContext context, String category) {
    final scheme = Theme.of(context).colorScheme;

    switch (category) {
      case 'Food':
        return Colors.orange;

      case 'Transport':
        return Colors.blue;

      case 'Shopping':
        return Colors.purple;

      case 'Bills':
        return Colors.teal;

      case 'Health':
        return Colors.redAccent;

      case 'Entertainment':
        return Colors.pink;

      case 'Education':
        return Colors.indigo;

      default:
        return scheme.primary;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;

      case 'Transport':
        return Icons.directions_bus_rounded;

      case 'Shopping':
        return Icons.shopping_bag_rounded;

      case 'Bills':
        return Icons.receipt_long_rounded;

      case 'Health':
        return Icons.local_hospital_rounded;

      case 'Entertainment':
        return Icons.movie_rounded;

      case 'Education':
        return Icons.school_rounded;

      default:
        return Icons.category_rounded;
    }
  }
}
