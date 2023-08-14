import 'package:flutter/cupertino.dart';

class LoginBackground extends StatelessWidget {
  final Widget child;
  const LoginBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SizedBox(
      // contaner convert to sizedBox
      width: double.infinity,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                'images/main_top.png',
                width: size.width * 0.4,
              )),
          Positioned(
              bottom: 0,
              right: 0,
              child: Image.asset(
                'images/bottom.png',
                width: size.width * 0.4,
              )),
          child,
        ],
      ),
    );
  }
}
