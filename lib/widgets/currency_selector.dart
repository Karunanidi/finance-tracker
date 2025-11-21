import 'package:finance_tracker/core/currency/currency_cubit.dart';
import 'package:finance_tracker/core/models/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Currency selector dialog
class CurrencySelector extends StatelessWidget {
  const CurrencySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Currency'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: Currency.values.map((currency) {
          return BlocBuilder<CurrencyCubit, Currency>(
            builder: (context, selectedCurrency) {
              final isSelected = selectedCurrency == currency;

              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? const Color(0xFF6366F1) : null,
                ),
                title: Text(currency.name),
                subtitle: Text('${currency.code} (${currency.symbol})'),
                onTap: () {
                  context.read<CurrencyCubit>().changeCurrency(currency);
                  Navigator.pop(context);
                },
              );
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
