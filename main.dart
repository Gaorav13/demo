import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: MacStyleDockNavigationBar()));
}

class MacStyleDockNavigationBar extends StatefulWidget {
  @override
  _MacStyleDockNavigationBarState createState() =>
      _MacStyleDockNavigationBarState();
}

class _MacStyleDockNavigationBarState extends State<MacStyleDockNavigationBar>
    with SingleTickerProviderStateMixin {
  List<IconData> icons = [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.photo,
  ];

  // List of gradients for each icon container
  List<List<Color>> gradients = [
    [Colors.purple, Colors.blue], // Gradient 1
    [Colors.orange, Colors.yellow], // Gradient 2
    [Colors.teal, Colors.green], // Gradient 3
    [Colors.red, Colors.pink.shade50], // Gradient 4
    [Colors.indigo, Colors.lightBlue], // Gradient 5
  ];

  double _hoveredIndex = -1; // Keep track of the index being hovered
  int? _draggingIndex; // Index of the currently dragged item

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade200,
                  Colors.blue.shade200,
                  Colors.orange.shade200,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Bottom Navigation Bar with draggable icons
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(icons.length, (index) {
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                          child: DragTarget<int>(
                            onWillAccept: (fromIndex) => fromIndex != index,
                            onAccept: (fromIndex) {
                              setState(() {
                                // Swap the icons and their corresponding gradients
                                final tempIcon = icons[fromIndex];
                                final tempGradient = gradients[fromIndex];

                                icons[fromIndex] = icons[index];
                                icons[index] = tempIcon;

                                gradients[fromIndex] = gradients[index];
                                gradients[index] = tempGradient;
                              });
                            },
                            builder:
                                (context, candidateData, rejectedData) {
                              return MouseRegion(
                                onEnter: (_) => _onHover(index),
                                onExit: (_) =>
                                    _onHover(-1), // Reset when not hovering
                                child: LongPressDraggable<int>(
                                  data: index,
                                  axis: Axis.horizontal,
                                  feedback: _buildIcon(index,
                                      true), // Show larger icon on drag with color
                                  onDragStarted: () =>
                                      _draggingIndex = index,
                                  onDragCompleted: () =>
                                      _draggingIndex = null,
                                  onDraggableCanceled: (_, __) =>
                                      setState(() => _draggingIndex = null),
                                  childWhenDragging: Opacity(
                                    opacity: 0.3,
                                    child: _buildIcon(index, false),
                                  ),
                                  child: _buildIcon(index,
                                      false), // The full container is draggable
                                ),
                              );
                            },
                          ),
                        );
                      })),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onHover(int index) {
    setState(() {
      _hoveredIndex = index.toDouble();
    });
  }

  Widget _buildIcon(int index, bool isDragging) {
    // Calculate scale based only on hover status of this specific icon
    double scale = 1.0;
    if (_hoveredIndex == index) {
      scale = 1.2; // Larger when hovering over the icon
    }

    return AnimatedScale(
      scale: isDragging ? 1.6 : scale,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutExpo, // Smooth easing curve for macOS-like effect
      child: Card(
        elevation: 8, // Elevated to give it a floating look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradients[index], // Apply the gradient for each icon
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(2, 4), // Create a soft shadow for realism
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icons[index],
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
