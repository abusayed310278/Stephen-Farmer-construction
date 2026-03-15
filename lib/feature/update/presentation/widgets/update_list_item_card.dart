import 'package:flutter/material.dart';

import '../../data/model/update_model.dart';

class UpdateListItemCard extends StatelessWidget {
  const UpdateListItemCard({
    super.key,
    required this.item,
    required this.isInterior,
  });

  final UpdateModel item;
  final bool isInterior;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1.5,
          color: isInterior ? Colors.black : Colors.white,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        item.category,
        style: TextStyle(color: isInterior ? Colors.black : Colors.white),
      ),
    );
  }
}
