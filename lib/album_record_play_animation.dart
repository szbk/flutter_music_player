import 'dart:ui';
import 'package:align_positioned/align_positioned.dart';
import 'package:flutter/material.dart';

class AlbumRecordPlayAnimation extends StatefulWidget {
  @override
  _AlbumRecordPlayAnimationState createState() =>
      _AlbumRecordPlayAnimationState();
  final bool animated;
  final bool minimized;

  AlbumRecordPlayAnimation({this.animated, this.minimized});
}

class _AlbumRecordPlayAnimationState extends State<AlbumRecordPlayAnimation>
    with TickerProviderStateMixin {
  AnimationController _recordController,
      _albumAndVinylController,
      _minimizedController;
  Animation _albumAnimation,
      _vinylAnimation,
      _minimizedAnimation,
      _borderRadiusAnimation;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    double _screenHeight = MediaQueryData.fromWindow(window).size.height;
    double _roundContainerHeightSize = _screenHeight * 0.095;
    double _albumCoverHeigtSize = (_roundContainerHeightSize * 0.99);


    _minimizedController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _recordController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..addListener(
        () {
          setState(() {});
        },
      );
    // Animation Controller
    _albumAndVinylController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    // Album Cover Animation
    _albumAnimation =
        AlignmentTween(begin: Alignment(0.0, 0.0), end: Alignment(-0.5, 0.0))
            .animate(
      CurvedAnimation(
          parent: _albumAndVinylController, curve: Curves.easeOutQuad),
    )..addListener(() {
                setState(() {});
              });
    // Vinyl Animation
    _vinylAnimation =
        AlignmentTween(begin: Alignment(0.0, 0.0), end: Alignment(0.725, 0))
            .animate(_albumAndVinylController)
              ..addListener(() {
                setState(() {});
              });
    // Album Cover Minimized Size
    _minimizedAnimation = Tween<double>(begin: 216, end: _albumCoverHeigtSize).animate(
        CurvedAnimation(
            parent: _minimizedController,
            curve: Curves.decelerate)) // Curves.decelerate
      ..addListener(() {
        setState(() {});
      });

    _borderRadiusAnimation = BorderRadiusTween(
            begin: BorderRadius.circular(10.0),
            end: BorderRadius.circular(100.0))
        .animate(_minimizedController)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _recordController.dispose();
    _albumAndVinylController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Vinyl Record animation start/stop
    if (widget.animated) {
      _albumAndVinylController.forward();
      _albumAnimation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _recordController.repeat();
        }
      });
    } else {
      _albumAndVinylController.reverse();
    }

    if (widget.minimized) {
      _minimizedController.forward();
    } else {
      _minimizedController.reverse();
    }

    // Screen and Album/Vinyl size seeting
    double screenWidthSize = MediaQuery.of(context).size.width;
    double relativeSize = (screenWidthSize * 3) / 5;
  

    return Container(
      width: screenWidthSize,
      height: (relativeSize + 20),
      child: Stack(
        children: <Widget>[
          // Vinyl Record Area
          AlignPositioned(
            alignment:
                widget.minimized ? Alignment(0.0, 0.0) : _vinylAnimation.value,
            child: Transform.rotate(
              angle: _recordController.value * 6.3,
              child: Opacity(
                opacity: _opacity,
                child: Container(
                  width: _minimizedAnimation.value,
                  height: _minimizedAnimation.value,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/vinyl.png'),
                        fit: BoxFit.fill),
                  ),
                ),
              ),
            ),
          ),
          // Album Cover Area
          AlignPositioned(
            alignment:
                widget.minimized ? Alignment(0.0, 0.0) : _albumAnimation.value,
            child: Container(
              width: _minimizedAnimation.value,
              height: _minimizedAnimation.value,
              decoration: BoxDecoration(
                borderRadius: _borderRadiusAnimation.value,
                boxShadow: [
                  widget.minimized
                      ? BoxShadow()
                      : BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(-10, 10),
                          blurRadius: 12,
                          spreadRadius: 1.0,
                        ),
                ],
                image: DecorationImage(
                  image: AssetImage('assets/cover.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: AnimatedOpacity(
                duration: Duration(microseconds: 500),
                opacity: widget.minimized ? 1.0 : 0.0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: 12,
                    height: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
