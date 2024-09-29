import 'package:flutter/material.dart';


class ReorderList extends StatefulWidget {
  const ReorderList({super.key});

  @override
  State<ReorderList> createState() => _ReorderListState();
}

class _ReorderListState extends State<ReorderList> {
  List<String> items = ['Test', 'Bad', 'Good', 'Something'];
  void onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex); // Remove the item from the old position
    items.insert(newIndex, item);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      proxyDecorator: (child, index, animation) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.white10,
              width: 2.0,
            ),
          ),
          child: SizedBox(
            width: 100,
            child: child,
          ),
        );
      },
      buildDefaultDragHandles: false,
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      onReorder:onReorder,
      itemBuilder: (context, i) => ReorderableDragStartListener(
        key: ValueKey(i),
        index: i,
        child: GestureDetector(
          onSecondaryTap: null,
          child: SizedBox(
            width: 100,
            child: TextButton(
              onPressed: null,
              child: Row(
                children: [
                  Text(
                    items[i],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
