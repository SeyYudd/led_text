import 'package:flutter/material.dart';
import 'package:led_text/models/state_cubit.dart';

class HistoryScreen extends StatelessWidget {
  final LEDTextState state;
  final void Function(String text) onChanged;
  final void Function(String text) onDelete;

  const HistoryScreen({
    super.key,
    required this.state,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: 300,
      child: state.textHistory.isEmpty
          ? Center(child: Text('Tidak ada history'))
          : ListView.builder(
              itemCount: state.textHistory.length,
              itemBuilder: (context, index) {
                final text = state.textHistory[index];
                return ListTile(
                  title: Text(text),
                  onTap: () => onChanged(text),
                  trailing: IconButton(
                    onPressed: () => onDelete(text),
                    icon: Icon(Icons.delete),
                  ),
                );
              },
            ),
    );
  }
}
