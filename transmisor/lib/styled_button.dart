import 'package:flutter/material.dart';

mixin MaterialStatePropertyMixin {
  MaterialStateProperty<T> getProperty<T>(T property) {
    return MaterialStateProperty.resolveWith((states) => property);
  }
}

class StyledButton extends StatelessWidget with MaterialStatePropertyMixin {
  const StyledButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            fixedSize: getProperty(const Size(150, 50)),
            backgroundColor: getProperty(Colors.deepOrangeAccent),
            shape: getProperty(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
                side: const BorderSide(color: Colors.deepOrange, width: 1.1))),
            shadowColor: getProperty(Colors.orange)),
        onPressed: () {},
        child: const Text('I am a button!'));
  }
}
