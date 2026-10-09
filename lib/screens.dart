import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';
import 'ui.dart';

class SplashScreen extends StatefulWidget {
  final ReplioStore store;

  const SplashScreen({super.key, required this.store});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    while (!widget.store.ready) {
      await Future.delayed(const Duration(milliseconds: 40));
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(store: widget.store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReplioLogo(size: 100),
            SizedBox(height: 22),
            Text(
              'REPLIO',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'RESTOCK BEFORE YOU RUN OUT',
              style: TextStyle(
                color: replioGreen,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final ReplioStore store;

  const HomeScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final urgent = store.refillList.take(4).toList();
        final favorites =
            store.items.where((item) => item.favorite).take(4).toList();

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('ADD ITEM'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
              children: [
                Row(
                  children: [
                    const ReplioLogo(size: 54),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REPLIO',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                          Text(
                            'HOME REFILL TRACKER',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Know what needs\nrestocking.',
                  style: TextStyle(
                    fontSize: 31,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track everyday supplies before they run out.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        value: '${store.lowCount}',
                        label: 'RUNNING LOW',
                        icon: Icons.warning_amber_rounded,
                        color: replioOrange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SummaryCard(
                        value: '${store.stockedCount}',
                        label: 'STOCKED',
                        icon: Icons.check_circle_outline_rounded,
                        color: replioGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SummaryCard(
                  value: '${store.refilledThisWeek}',
                  label: 'REFILLED THIS WEEK',
                  icon: Icons.refresh_rounded,
                  color: replioMint,
                ),
                const SizedBox(height: 24),
                _QuickMenu(store: store),
                const SizedBox(height: 26),
                _SectionHeader(
                  title: 'Need attention',
                  actionLabel: 'VIEW ALL',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RefillListScreen(store: store),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (urgent.isEmpty)
                  const _EmptyCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Everything looks stocked',
                    text: 'Items that get low will appear here.',
                  )
                else
                  ...urgent.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ItemCard(
                        item: item,
                        store: store,
                        onTap: () => _openEditor(context, item: item),
                      ),
                    ),
                  ),
                if (favorites.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const _SectionHeader(
                    title: 'Favorites',
                  ),
                  const SizedBox(height: 10),
                  ...favorites.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ItemCard(
                        item: item,
                        store: store,
                        onTap: () => _openEditor(context, item: item),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openEditor(
    BuildContext context, {
    RefillItem? item,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemEditorScreen(
          store: store,
          item: item,
        ),
      ),
    );
  }
}

class _QuickMenu extends StatelessWidget {
  final ReplioStore store;

  const _QuickMenu({required this.store});

  @override
  Widget build(BuildContext context) {
    final entries = [
      (
        'My Items',
        Icons.inventory_2_outlined,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemsScreen(store: store),
              ),
            ),
      ),
      (
        'Refill List',
        Icons.shopping_basket_outlined,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RefillListScreen(store: store),
              ),
            ),
      ),
      (
        'History',
        Icons.history_rounded,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistoryScreen(store: store),
              ),
            ),
      ),
      (
        'Statistics',
        Icons.bar_chart_rounded,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StatisticsScreen(store: store),
              ),
            ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.75,
      ),
      itemBuilder: (context, index) {
        final entry = entries[index];

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: entry.$3,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(entry.$2, color: replioGreen),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onTap,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(icon, color: replioMint, size: 38),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ItemCard extends StatelessWidget {
  final RefillItem item;
  final ReplioStore store;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: replioGreen.withOpacity(.08),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  categoryIcon(item.category),
                  color: replioGreen,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (item.favorite)
                          const Icon(
                            Icons.star_rounded,
                            color: replioGold,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.category} • ${numberText(item.quantity)} ${item.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StatusChip(status: item.status),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  IconButton(
                    tooltip: 'Use one',
                    onPressed: item.quantity <= 0
                        ? null
                        : () => store.useOne(item.id),
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  IconButton(
                    tooltip: 'Refill',
                    onPressed: () => showRefillDialog(
                      context,
                      store: store,
                      item: item,
                    ),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: replioOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemsScreen extends StatefulWidget {
  final ReplioStore store;

  const ItemsScreen({super.key, required this.store});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  String query = '';
  String category = 'All';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final filtered = widget.store.items.where((item) {
          final matchesQuery = item.name.toLowerCase().contains(
                query.trim().toLowerCase(),
              );
          final matchesCategory =
              category == 'All' || item.category == category;
          return matchesQuery && matchesCategory;
        }).toList()
          ..sort((a, b) {
            if (a.favorite != b.favorite) {
              return a.favorite ? -1 : 1;
            }
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

        return Scaffold(
          appBar: AppBar(
            title: const Text('MY ITEMS'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemEditorScreen(store: widget.store),
              ),
            ),
            child: const Icon(Icons.add_rounded),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            children: [
              TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: const InputDecoration(
                  hintText: 'Search items',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final value in ['All', ...replioCategories])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(value),
                          selected: category == value,
                          onSelected: (_) {
                            setState(() => category = value);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${filtered.length} items',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (filtered.isEmpty)
                const _EmptyCard(
                  icon: Icons.search_off_rounded,
                  title: 'No items found',
                  text: 'Try another search or add a new household item.',
                )
              else
                ...filtered.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ItemCard(
                      item: item,
                      store: widget.store,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemEditorScreen(
                            store: widget.store,
                            item: item,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class RefillListScreen extends StatelessWidget {
  final ReplioStore store;

  const RefillListScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final items = store.refillList;

        return Scaffold(
          appBar: AppBar(
            title: const Text('REFILL LIST'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
            children: [
              Text(
                'Items that are low, at their minimum, or out of stock.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const _EmptyCard(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Nothing to refill',
                  text: 'Your tracked supplies are currently in good shape.',
                )
              else
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ItemCard(
                      item: item,
                      store: store,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemEditorScreen(
                            store: store,
                            item: item,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> showRefillDialog(
  BuildContext context, {
  required ReplioStore store,
  required RefillItem item,
}) async {
  String amountText = '1';

  final amount = await showDialog<double>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('Refill ${item.name}'),
        content: TextFormField(
          initialValue: '1',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Quantity to add (${item.unit})',
          ),
          onChanged: (value) => amountText = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(amountText.trim());
              if (parsed == null || parsed <= 0) return;
              Navigator.pop(dialogContext, parsed);
            },
            child: const Text('REFILLED'),
          ),
        ],
      );
    },
  );

  if (amount != null) {
    await store.refillItem(
      id: item.id,
      amount: amount,
    );
  }
}


class HistoryScreen extends StatelessWidget {
  final ReplioStore store;

  const HistoryScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final events = store.history;

        return Scaffold(
          appBar: AppBar(
            title: const Text('REFILL HISTORY'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
            children: [
              Text(
                'A local history of refill actions.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (events.isEmpty)
                const _EmptyCard(
                  icon: Icons.history_rounded,
                  title: 'No refill history yet',
                  text: 'Use the Refilled action and your history will appear here.',
                )
              else
                ...events.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        leading: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: replioMint.withOpacity(.12),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            color: replioGreen,
                          ),
                        ),
                        title: Text(
                          event.itemName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        subtitle: Text(
                          '+${numberText(event.addedQuantity)} ${event.unit} • ${shortDate(event.date)}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Delete history entry',
                          onPressed: () => store.removeHistoryEvent(event.id),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class StatisticsScreen extends StatelessWidget {
  final ReplioStore store;

  const StatisticsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final categoryCounts = <String, int>{
          for (final category in replioCategories)
            category: store.items.where((item) => item.category == category).length,
        };

        final refillCounts = <String, int>{};
        for (final event in store.history) {
          refillCounts[event.itemName] =
              (refillCounts[event.itemName] ?? 0) + 1;
        }

        final popular = refillCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Scaffold(
          appBar: AppBar(
            title: const Text('STATISTICS'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
            children: [
              const Text(
                'Your home stock overview',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      value: '${store.items.length}',
                      label: 'TOTAL ITEMS',
                      icon: Icons.inventory_2_outlined,
                      color: replioGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SummaryCard(
                      value: '${store.lowCount}',
                      label: 'NEED ATTENTION',
                      icon: Icons.warning_amber_rounded,
                      color: replioOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      value: '${store.history.length}',
                      label: 'TOTAL REFILLS',
                      icon: Icons.refresh_rounded,
                      color: replioMint,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SummaryCard(
                      value: '${store.refilledThisWeek}',
                      label: 'THIS WEEK',
                      icon: Icons.calendar_view_week_outlined,
                      color: replioGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const _SectionHeader(title: 'Items by category'),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      for (final entry in categoryCounts.entries)
                        if (entry.value > 0)
                          ListTile(
                            leading: Icon(
                              categoryIcon(entry.key),
                              color: replioGreen,
                            ),
                            title: Text(entry.key),
                            trailing: Text(
                              '${entry.value}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      if (categoryCounts.values.every((value) => value == 0))
                        const Padding(
                          padding: EdgeInsets.all(18),
                          child: Text('Add items to see category statistics.'),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const _SectionHeader(title: 'Most frequently refilled'),
              const SizedBox(height: 10),
              if (popular.isEmpty)
                const _EmptyCard(
                  icon: Icons.insights_outlined,
                  title: 'Not enough history yet',
                  text: 'Your most frequently refilled items will appear here.',
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        for (final entry in popular.take(5))
                          ListTile(
                            leading: const Icon(
                              Icons.local_fire_department_outlined,
                              color: replioOrange,
                            ),
                            title: Text(entry.key),
                            trailing: Text(
                              '${entry.value} refills',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class ItemEditorScreen extends StatefulWidget {
  final ReplioStore store;
  final RefillItem? item;

  const ItemEditorScreen({
    super.key,
    required this.store,
    this.item,
  });

  @override
  State<ItemEditorScreen> createState() => _ItemEditorScreenState();
}

class _ItemEditorScreenState extends State<ItemEditorScreen> {
  final formKey = GlobalKey<FormState>();

  late String name;
  late String category;
  late String quantityText;
  late String minimumText;
  late String unit;
  late String notes;
  late bool favorite;

  bool get editing => widget.item != null;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    name = item?.name ?? '';
    category = item?.category ?? replioCategories.first;
    quantityText = item == null ? '1' : numberText(item.quantity);
    minimumText = item == null ? '1' : numberText(item.minimumQuantity);
    unit = item?.unit ?? replioUnits.first;
    notes = item?.notes ?? '';
    favorite = item?.favorite ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'EDIT ITEM' : 'ADD ITEM'),
        actions: [
          if (editing)
            IconButton(
              tooltip: 'Delete item',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
          children: [
            TextFormField(
              initialValue: name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Item name',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter an item name';
                }
                return null;
              },
              onChanged: (value) => name = value,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                for (final value in replioCategories)
                  DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => category = value);
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: quantityText,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Current quantity',
                    ),
                    validator: _numberValidator,
                    onChanged: (value) => quantityText = value,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: minimumText,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Minimum',
                    ),
                    validator: _numberValidator,
                    onChanged: (value) => minimumText = value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: unit,
              decoration: const InputDecoration(
                labelText: 'Unit',
                prefixIcon: Icon(Icons.straighten_rounded),
              ),
              items: [
                for (final value in replioUnits)
                  DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => unit = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: notes,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              onChanged: (value) => notes = value,
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                value: favorite,
                onChanged: (value) => setState(() => favorite = value),
                secondary: const Icon(
                  Icons.star_outline_rounded,
                  color: replioGold,
                ),
                title: const Text(
                  'Favorite',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Show this item on the home screen.'),
              ),
            ),
            if (editing) ...[
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.event_available_outlined,
                    color: replioGreen,
                  ),
                  title: const Text('Last refill'),
                  subtitle: Text(
                    shortDate(widget.item!.lastRefillDate),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(editing ? 'SAVE CHANGES' : 'ADD ITEM'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _numberValidator(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) {
      return 'Enter 0 or more';
    }
    return null;
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final quantity = double.parse(quantityText.trim());
    final minimum = double.parse(minimumText.trim());
    final now = DateTime.now();

    final item = RefillItem(
      id: widget.item?.id ?? '${now.microsecondsSinceEpoch}',
      name: name.trim(),
      category: category,
      quantity: quantity,
      minimumQuantity: minimum,
      unit: unit,
      lastRefillDate: widget.item?.lastRefillDate ?? now,
      notes: notes.trim(),
      favorite: favorite,
    );

    if (editing) {
      await widget.store.updateItem(item);
    } else {
      await widget.store.addItem(item);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    final item = widget.item;
    if (item == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text(
          'Remove "${item.name}" from REPLIO? Existing refill history will stay available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.store.deleteItem(item.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}


class CategoriesScreen extends StatelessWidget {
  final ReplioStore store;

  const CategoriesScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('CATEGORIES')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
            children: [
              Text(
                'Built-in categories for organizing household supplies.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ...replioCategories.map((category) {
                final count = store.items
                    .where((item) => item.category == category)
                    .length;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: replioGreen.withOpacity(.08),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          categoryIcon(category),
                          color: replioGreen,
                        ),
                      ),
                      title: Text(
                        category,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      trailing: Text(
                        '$count',
                        style: const TextStyle(
                          color: replioOrange,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final ReplioStore store;

  const SettingsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('SETTINGS')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: SwitchListTile(
                  value: store.darkMode,
                  onChanged: store.setDarkMode,
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text(
                    'Dark mode',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.category_outlined),
                      title: const Text('Categories'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoriesScreen(store: store),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: 'Privacy Policy',
                            body: privacyText,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Terms & Conditions'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: 'Terms & Conditions',
                            body: termsText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  textColor: replioRed,
                  iconColor: replioRed,
                  leading: const Icon(Icons.delete_sweep_outlined),
                  title: const Text('Reset all data'),
                  subtitle: const Text(
                    'Delete all items and refill history from this device.',
                  ),
                  onTap: () => _reset(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset REPLIO?'),
        content: const Text(
          'All tracked items and refill history will be permanently removed from local app storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('RESET'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await store.resetAll();
    }
  }
}

class LegalScreen extends StatelessWidget {
  final String title;
  final String body;

  const LegalScreen({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SelectableText(
            body,
            style: const TextStyle(height: 1.7),
          ),
        ],
      ),
    );
  }
}

const privacyText = '''REPLIO PRIVACY POLICY

REPLIO is an offline-first home refill and household stock tracking application.

The current core version does not require an account, login, Firebase, backend services, advertising, analytics, or cloud synchronization.

Information you enter into REPLIO, including item names, categories, quantities, minimum quantities, units, notes, favorite status, refill dates, and refill history, is stored locally on your device.

The current core version does not require access to your precise location, camera, microphone, contacts, phone, SMS, calendar, photos, media library, or payment information.

REPLIO does not intentionally sell or rent the locally stored information described above and does not use it for personalized advertising.

You can delete individual items, remove refill-history entries, or reset all app data from Settings. Clearing application storage or uninstalling the app may also remove locally stored information, subject to operating-system backup and restore behavior.

If future versions add online services, accounts, cloud sync, analytics, crash reporting, advertising, purchases, or additional permissions, this policy should be reviewed and updated before release.''';

const termsText = '''REPLIO TERMS & CONDITIONS

REPLIO is a household refill and stock organization tool intended for personal organization.

The app helps you record quantities, minimum levels, categories, notes, and refill history. Status labels such as Good, Low, Refill Now, and Out are calculated from the values you enter.

REPLIO does not guarantee that stored quantities reflect your real-world stock unless you keep them updated.

The current core version stores app data locally on your device. We do not guarantee recovery after uninstalling the app, clearing app data, device loss, storage failure, or operating-system changes.

REPLIO is not a professional inventory, medical, safety, financial, or emergency-management system.

REPLIO is provided on an "as available" basis to the extent permitted by applicable law. Features may be changed, improved, added, or removed in future versions.''';
