import 'package:dio_request_inspector/src/common/extensions.dart';
import 'package:flutter/material.dart';

class ItemRow extends StatelessWidget {
  final String name;
  final String? value;
  final bool useHeaderFormat;

  const ItemRow(
      {required this.name,
      this.value,
      super.key,
      this.useHeaderFormat = false});

  @override
  Widget build(BuildContext context) {
    return useHeaderFormat ? _itemRowHeaderFormat() : _itemRow();
  }

  Widget _itemRowHeaderFormat() {
    if (value == 'N/A' || value == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          "Headers:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8),
        ),
        ...value
            .toString()
            .toMap()
            .entries
            .map((e) => getListRow(e.key, e.value)),
      ],
    );
  }

  Row _itemRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 5),
        ),
        Flexible(
          child: value != null
              ? Text(
                  value!,
                )
              : const SizedBox(),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 18),
        ),
      ],
    );
  }

  Widget getListRow(String name, var value) {
    return Container(
      padding: const EdgeInsets.only(left: 16),
      alignment: Alignment.centerLeft,
      child: SelectableText.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: '• ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '$name: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value.toString(),
            ),
          ],
        ),
      ),
    );
  }
}
