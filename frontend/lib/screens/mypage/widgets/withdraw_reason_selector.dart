import 'package:flutter/material.dart';

class WithdrawReasonSelector extends StatelessWidget {
  final List<String> reasons;
  final int? selected;
  final ValueChanged<int> onChanged;
  const WithdrawReasonSelector({
    super.key,
    required this.reasons,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        reasons.length,
        (idx) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Radio<int>(
                value: idx,
                groupValue: selected,
                onChanged: (val) {
                  if (val != null) onChanged(val);
                },
                activeColor: Colors.black,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(reasons[idx], style: const TextStyle(fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
