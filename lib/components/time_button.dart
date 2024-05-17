import 'package:flutter/material.dart';

class TimeButton extends StatefulWidget {
  final Function(TimeOfDay) onTimePicked;
  final String buttonText;
  final TimeOfDay? initialTime;

  const TimeButton({super.key, 
    required this.onTimePicked,
    required this.buttonText,
    this.initialTime,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TimeButtonState createState() => _TimeButtonState();
}

class _TimeButtonState extends State<TimeButton> {
  String? _buttonText;

  @override
  void initState() {
    super.initState();
    _buttonText = widget.initialTime != null
        ? widget.initialTime!.format(context)
        : widget.buttonText;
  }

  void _updateButtonText(TimeOfDay time) {
    setState(() {
      _buttonText = time.format(context);
    });
  }

  @override
Widget build(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 50),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    ),
    width: 150,
    height: 50,
    child: ElevatedButton(
      onPressed: () async {
        TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: widget.initialTime ?? TimeOfDay.now(),
        );
        if (picked != null) {
          widget.onTimePicked(picked);
          _updateButtonText(picked);
        }
      },
      style: ElevatedButton.styleFrom(
        shadowColor: Colors.transparent,
        backgroundColor: const Color(0xff114232),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        _buttonText ?? widget.buttonText,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'ReadexPro',
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    ),
  );
}
}

