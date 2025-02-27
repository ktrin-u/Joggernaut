import 'package:flutter/material.dart';

Future showFormBottomSheet({
  required BuildContext context,
  required double maxHeight,
  required Widget form,
  required VoidCallback? onClose,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    barrierColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return  ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * maxHeight, 
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: form,
          )
        )
      );
    },
  ).whenComplete(onClose!);
}