import 'package:flutter/material.dart';

class HorizontalDraggableList extends StatefulWidget {
  @override
  _HorizontalDraggableListState createState() =>
      _HorizontalDraggableListState();
}

class _HorizontalDraggableListState extends State<HorizontalDraggableList> {
  List<String> items = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // Height of the list
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Horizontal direction
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Draggable<String>(
            data: items[index],
            feedback: Material(
              child: Container(
                padding: EdgeInsets.all(20),
                color: Colors.blueAccent,
                child:
                    Text(items[index], style: TextStyle(color: Colors.white)),
              ),
            ),
            child: DragTarget<String>(
              onAccept: (receivedItem) {
                setState(() {
                  var currentIndex = items.indexOf(receivedItem);
                  var draggedItem = items.removeAt(currentIndex);
                  items.insert(index, draggedItem);
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Card(
                  key: ValueKey(items[index]),
                  color: Colors.blue,
                  child: Container(
                    width: 100,
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(8),
                    child: Text(
                      items[index],
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class HorizontalConstrainedDraggableList extends StatefulWidget {
  @override
  _HorizontalConstrainedDraggableListState createState() =>
      _HorizontalConstrainedDraggableListState();
}

class _HorizontalConstrainedDraggableListState
    extends State<HorizontalConstrainedDraggableList> {
  List<String> items = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Draggable<String>(
            data: items[index],
            axis: Axis.horizontal, // Restrict drag to horizontal axis
            feedback: Material(
              child: Container(
                padding: EdgeInsets.all(20),
                color: Colors.blueAccent,
                child:
                    Text(items[index], style: TextStyle(color: Colors.white)),
              ),
            ),
            childWhenDragging: Container(
              width: 100,
              margin: EdgeInsets.all(8),
              color: Colors.grey, // Grey out the original item while dragging
            ),
            child: DragTarget<String>(
              onAccept: (receivedItem) {
                setState(() {
                  var currentIndex = items.indexOf(receivedItem);
                  var draggedItem = items.removeAt(currentIndex);
                  items.insert(index, draggedItem);
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Card(
                  key: ValueKey(items[index]),
                  color: Colors.blue,
                  child: Container(
                    width: 100,
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(8),
                    child: Text(
                      items[index],
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}



class ChromeTabDraggable extends StatefulWidget {
  @override
  _ChromeTabDraggableState createState() => _ChromeTabDraggableState();
}

class _ChromeTabDraggableState extends State<ChromeTabDraggable> {
  List<String> items = ['Tab 1', 'Tab 2', 'Tab 3', 'Tab 4', 'Tab 5'];
  double _draggingIndex = -1; // The index of the currently dragged item
  double _currentDragOffset = 0;

  // Swap the positions of two items based on drag position
  void _onDragUpdate(DragUpdateDetails details, int index) {
    setState(() {
      _currentDragOffset += details.delta.dx;

      // Check for position swap logic based on horizontal drag distance
      if (_currentDragOffset > 100 && index < items.length - 1) {
        // Move item to the right
        final temp = items[index];
        items[index] = items[index + 1];
        items[index + 1] = temp;
        _currentDragOffset = 0; // Reset offset
      } else if (_currentDragOffset < -100 && index > 0) {
        // Move item to the left
        final temp = items[index];
        items[index] = items[index - 1];
        items[index - 1] = temp;
        _currentDragOffset = 0; // Reset offset
      }
    });
  }

  // Stop dragging when the drag is completed
  void _onDragEnd() {
    setState(() {
      _draggingIndex = -1;
      _currentDragOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onHorizontalDragStart: (_) {
              setState(() {
                _draggingIndex = index.toDouble();
              });
            },
            onHorizontalDragUpdate: (details) => _onDragUpdate(details, index),
            onHorizontalDragEnd: (_) => _onDragEnd(),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _draggingIndex == index
                  ? 130
                  : 100, // Expand slightly while dragging
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                items[index],
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
