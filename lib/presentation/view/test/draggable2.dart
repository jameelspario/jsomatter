import 'package:flutter/material.dart';

class DraggableRow extends StatefulWidget {
  @override
  _DraggableRowState createState() => _DraggableRowState();
}

class _DraggableRowState extends State<DraggableRow> {
  List<String> items = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];
  String? selected;

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      final movedItem = items.removeAt(oldIndex);
      items.insert(newIndex, movedItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < items.length; i++)
                  DraggableItem(
                    item: items[i],
                    index: i,
                    onReorder: onReorder,
                  ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            // Add new item logic
          },
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class DraggableItem extends StatefulWidget {
  final String item;
  final int index;
  final Function(int oldIndex, int newIndex) onReorder;

  const DraggableItem({
    required this.item,
    required this.index,
    required this.onReorder,
  });

  @override
  State<DraggableItem> createState() => _DraggableItemState();
}

class _DraggableItemState extends State<DraggableItem> {
  Offset position = Offset(100, 200); // Initial position

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      // onAccept: (oldIndex) {
      //   onReorder(oldIndex, index);
      // },
      // onWillAccept: (oldIndex) => true, // Accept the drag
      onAcceptWithDetails: (details) {
        final oldIndex = details.data; // Get the index from Draggable
        if (oldIndex != widget.index) {
          widget.onReorder(
              oldIndex, widget.index); // Reorder if the index is different
        }
      },
      builder: (context, candidateData, rejectedData) {
        // return LongPressDraggable<int>(
        //   data: index,
        //   feedback: Material(
        //     child: ItemTab(item: item), // Feedback widget during drag
        //   ),
        //   // childWhenDragging: const SizedBox(), // Make item invisible when dragging
        //   childWhenDragging: ItemTab(item: item), // Make item invisible when dragging
        //   child: ItemTab(item: item), // Actual item tab widget
        // );

        return Positioned(
          left: position.dx,
          top: 100,
          child: Draggable<int>(
            data: widget.index,
            feedback: Material(
              child: ItemTab(item: widget.item), // Feedback widget during drag
            ),
            // childWhenDragging: const SizedBox(), // Make item invisible when dragging
            childWhenDragging: ItemTab(item: widget.item),
            // Make item invisible when dragging
            child: ItemTab(item: widget.item),
            onDragUpdate: (details) {
              position = Offset(position.dx + details.delta.dx,
                  position.dy); // Only change X-axis
              setState(() {});
            },
            onDragEnd: (details) {
              position = Offset(
                  position.dx, position.dy); // Ensure Y-axis doesn't change
              setState(() {});
            }, // Actual item tab widget
          ),
        );
      },
    );
  }
}

class ItemTab extends StatelessWidget {
  final String item;

  const ItemTab({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(item),
    );
  }
}
