import 'package:flutter/material.dart';

class ToggleDropdown extends StatefulWidget {
  final String title;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const ToggleDropdown({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  State<ToggleDropdown> createState() => _ToggleDropdownState();
}

class _ToggleDropdownState extends State<ToggleDropdown> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),

          // Expanded content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 12),

                  ...widget.options.map((option) {
                    bool isSelected = widget.selectedValue == option;
                    return InkWell(
                      onTap: () {
                        widget.onChanged(option);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.radio_button_on
                                : Icons.radio_button_off_outlined,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                        ],

                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
