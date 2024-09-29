import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webjason/utils/extensions.dart';

import '../../../domain/tab_model.dart';
import '../../widgets/widgets.dart';

typedef BuilderItem = Widget Function(dynamic it, int index);

class TabHome extends StatelessWidget {
  const TabHome(
      {this.items = const [],
      this.selected,
      this.onSelect,
      this.onRemove,
      this.onAdd,
      required this.onReorder,
      super.key});

  final List items;
  final Function(TabModel m)? onSelect;
  final Function(TabModel m)? onRemove;
  final VoidCallback? onAdd;
  final ReorderCallback onReorder;
  final TabModel? selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            // child: SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Row(
            //     children: [
            //       for (final it in items)
            //         ItemTab(
            //           item: it,
            //           selected: selected,
            //           callback: () => onSelect?.call(it),
            //           onRemove: () => onRemove?.call(it),
            //         ),
            //     ],
            //   ),
            // ),
            child: SizedBox(
                height: 20,
                child: DraggableTabs(
                  items: items,
                  onSelect: onSelect,
                  onRemove: onRemove,
                  onReorder: onReorder,
                  builder: (it, i) {
                    return ItemTab(
                      item: it,
                      selected: selected,
                      callback: () => onSelect?.call(it),
                      onRemove: () => onRemove?.call(it),
                    );
                  },
                )),
          ),
          InkWell(onTap: onAdd, child: const Icon(Icons.add))
        ],
      ),
    );
  }
}

class DraggableTabs extends StatefulWidget {
  const DraggableTabs(
      {this.items = const [],
      this.selected,
      this.onSelect,
      this.onRemove,
      required this.onReorder,
      required this.builder,
      super.key});

  final List items;
  final TabModel? selected;
  final Function(TabModel m)? onSelect;
  final Function(TabModel m)? onRemove;
  final ReorderCallback onReorder;
  final BuilderItem builder;

  @override
  State<DraggableTabs> createState() => _DraggableTabsState();
}

class _DraggableTabsState extends State<DraggableTabs> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      proxyDecorator: (child, index, anim) {
        return child;
      },
      buildDefaultDragHandles: false,
      scrollDirection: Axis.horizontal,
      itemCount: widget.items.length,
      onReorder: widget.onReorder,
      itemBuilder: (context, i) => ReorderableDragStartListener(
        key: ValueKey(i),
        index: i,
        child: GestureDetector(
          onSecondaryTap: null,
          child: widget.builder(widget.items[i], i),
        ),
      ),
    );
  }
}

class ItemTab extends StatelessWidget {
  const ItemTab(
      {required this.item,
      this.selected,
      this.callback,
      this.onRemove,
      super.key});

  final TabModel item;
  final TabModel? selected;

  final VoidCallback? callback;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selected?.id == item.id;
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: Hoverable(
        hoverColor: Colors.indigoAccent.shade100,
        corner: 5.0,
        callback: () => callback?.call(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigoAccent : null,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5.0), topRight: Radius.circular(5)),
            border: const Border(
                right: BorderSide(width: 1, color: Colors.black45)),
          ),
          child: Row(
            children: [
              SvgPicture.asset("assets/svg/json.svg",
                  width: 18,
                  colorFilter: ColorFilter.mode(
                    isSelected ? Colors.white : Colors.black38,
                    BlendMode.srcIn,
                  )),
              2.0.spaceX,
              Text(
                "Tab ${item.name}",
                style: TextStyle(color: isSelected ? Colors.white : null),
              ),
              selected?.id != item.id
                  ? Container()
                  : InkWell(
                      onTap: onRemove,
                      child: Row(
                        children: [
                          2.0.spaceX,
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.close,
                              size: 10,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
