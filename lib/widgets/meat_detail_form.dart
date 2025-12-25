import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/meat_item.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/currency_formatter.dart';

class MeatDetailForm extends StatefulWidget {
  final List<MeatItem> items;
  final Function(List<MeatItem>) onItemsChanged;
  final String categoryLabel;

  const MeatDetailForm({
    Key? key,
    required this.items,
    required this.onItemsChanged,
    required this.categoryLabel,
  }) : super(key: key);

  @override
  State<MeatDetailForm> createState() => _MeatDetailFormState();
}

class _MeatDetailFormState extends State<MeatDetailForm> {
  void _addItem() {
    final newItems = [...widget.items, MeatItem(type: 'Daging')];
    widget.onItemsChanged(newItems);
  }

  void _removeItem(int index) {
    final newItems = List<MeatItem>.from(widget.items);
    newItems.removeAt(index);
    widget.onItemsChanged(newItems);
  }

  void _updateItem(int index, MeatItem item) {
    final newItems = List<MeatItem>.from(widget.items);
    newItems[index] = item;
    widget.onItemsChanged(newItems);
  }

  double get totalAmount {
    return widget.items.fold(0.0, (sum, item) => sum + item.total);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Detail ${widget.categoryLabel}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            TextButton.icon(
              onPressed: _addItem,
              icon: Icon(Icons.add, size: 18),
              label: Text('Tambah Potongan'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ...widget.items.asMap().entries.map((entry) {
          return _buildMeatItemCard(entry.key, entry.value);
        }).toList(),
        if (widget.items.isNotEmpty) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Keseluruhan',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  CurrencyFormatter.format(totalAmount),
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMeatItemCard(int index, MeatItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Potongan ${index + 1}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              if (widget.items.length > 1)
                IconButton(
                  onPressed: () => _removeItem(index),
                  icon: Icon(Icons.delete_outline, color: AppTheme.errorColor),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: 12),

          // Jenis Potongan
          DropdownButtonFormField<String>(
            value: item.type,
            decoration: InputDecoration(
              labelText: 'Jenis Potongan',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: AppConstants.meatTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                _updateItem(index, item.copyWith(type: value, customType: null));
              }
            },
          ),

          // Custom Type jika pilih "Lainnya"
          if (item.type == 'Lainnya') ...[
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nama Potongan',
                hintText: 'Contoh: Iga Sapi',
              ),
              onChanged: (value) {
                _updateItem(index, item.copyWith(customType: value));
              },
            ),
          ],

          SizedBox(height: 12),

          // Berat & Harga
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Berat (kg)',
                    hintText: '0',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  onChanged: (value) {
                    final weight = double.tryParse(value) ?? 0;
                    _updateItem(index, item.copyWith(weight: weight));
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Harga/kg',
                    hintText: 'Rp 0',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    final price = double.tryParse(value) ?? 0;
                    _updateItem(index, item.copyWith(pricePerKg: price));
                  },
                ),
              ),
            ],
          ),

          // Total per item
          if (item.isValid) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    CurrencyFormatter.format(item.total),
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}