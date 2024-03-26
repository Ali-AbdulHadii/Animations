import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Heart Animation')),
      body: HeartAnimation(),
    ),
  ));
}

class HeartAnimation extends StatefulWidget {
  @override
  _HeartAnimationState createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<HeartAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<double> _topPositions;
  late List<double> _leftPositions;
  late double _targetX;
  late double _targetY;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _animations = [];
    _topPositions = [];
    _leftPositions = [];
    _targetX = 0;
    _targetY = 0;
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      RenderBox renderBox = context.findRenderObject() as RenderBox;
      Offset targetOffset = renderBox.localToGlobal(Offset.zero);
      _targetX = targetOffset.dx + 20; // Adjust for the padding of the text box
      _targetY = targetOffset.dy;
      _addHeart(details.localPosition.dx, details.localPosition.dy);
    });
  }

  void _addHeart(double startX, double startY) {
    final controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          final index = _controllers.indexOf(controller);
          _controllers.removeAt(index);
          _animations.removeAt(index);
          _topPositions.removeAt(index);
          _leftPositions.removeAt(index);
        });
        controller.dispose();
      }
    });

    _controllers.add(controller);
    _animations.add(animation);
    _topPositions.add(_targetY - 25);
    _leftPositions.add(_targetX - 25);

    controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          color: Colors.grey.withOpacity(0.5),
          child: Text(
            'roomname',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTapDown: _handleTapDown,
            child: Container(
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  for (var i = 0; i < _controllers.length; i++)
                    AnimatedBuilder(
                      animation: _animations[i],
                      builder: (context, child) {
                        return Positioned(
                          top: _topPositions[i] +
                              (MediaQuery.of(context).size.height *
                                  (1 - _animations[i].value)),
                          left: _leftPositions[i] +
                              (MediaQuery.of(context).size.width *
                                  (1 - _animations[i].value)),
                          child: Image.asset('images/heart.png',
                              width: 50, height: 50),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
