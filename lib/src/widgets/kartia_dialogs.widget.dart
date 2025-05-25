import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KartiaDialogs {
  static bool _isIOS(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  static Future<void> showTextDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return _showDialog(
      context,
      title: title,
      content: Text(content),
      actions: [_dialogAction(context, label: 'OK', isDefault: true)],
    );
  }

  static Future<String?> showInputDialog(
    BuildContext context, {
    required String title,
    String? hint,
  }) {
    final controller = TextEditingController();
    return _showDialog<String>(
      context,
      title: title,
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint ?? ''),
      ),
      actions: [
        _dialogAction(context, label: 'Annuler', returnValue: null),
        _dialogAction(
          context,
          label: 'Valider',
          returnValue: () => controller.text,
        ),
      ],
    );
  }

  static Future<void> showImageDialog(
    BuildContext context, {
    required String title,
    required String imageUrl,
  }) {
    return _showDialog(
      context,
      title: title,
      content: Image.network(imageUrl),
      actions: [_dialogAction(context, label: 'Fermer')],
    );
  }

  static Future<String?> showDropdownDialog(
    BuildContext context, {
    required String title,
    required List<String> options,
  }) {
    String? selectedValue = options.first;
    return _showDialog<String>(
      context,
      title: title,
      content: StatefulBuilder(
        builder: (context, setState) {
          return DropdownButton<String>(
            value: selectedValue,
            isExpanded: true,
            onChanged: (value) {
              setState(() => selectedValue = value);
            },
            items:
                options
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
          );
        },
      ),
      actions: [
        _dialogAction(context, label: 'Annuler', returnValue: null),
        _dialogAction(
          context,
          label: 'Choisir',
          returnValue: () => selectedValue!,
        ),
      ],
    );
  }

  static Future<void> showCustomDialog(
    BuildContext context, {
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) {
    if (_isIOS(context)) {
      return showCupertinoDialog<void>(
        context: context,
        builder:
            (_) => CupertinoAlertDialog(
              title: Text(title),
              content: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: content,
              ),
              actions: actions,
            ),
      );
    } else {
      return showDialog<void>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(title),
              content: content,
              actions: actions,
            ),
      );
    }
  }

  // Internal method for standard dialogs
  static Future<T?> _showDialog<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    required List<_KartiaDialogAction<T>> actions,
  }) {
    if (_isIOS(context)) {
      return showCupertinoDialog<T>(
        context: context,
        builder:
            (_) => CupertinoAlertDialog(
              title: Text(title),
              content: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: content,
              ),
              actions:
                  actions
                      .map(
                        (a) => CupertinoDialogAction(
                          onPressed:
                              () => Navigator.of(
                                context,
                              ).pop(a.returnValue?.call()),
                          isDefaultAction: a.isDefault,
                          child: Text(a.label),
                        ),
                      )
                      .toList(),
            ),
      );
    } else {
      return showDialog<T>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(title),
              content: content,
              actions:
                  actions
                      .map(
                        (a) => TextButton(
                          onPressed:
                              () => Navigator.of(
                                context,
                              ).pop(a.returnValue?.call()),
                          child: Text(a.label),
                        ),
                      )
                      .toList(),
            ),
      );
    }
  }

  // Helper for actions
  static _KartiaDialogAction<T> _dialogAction<T>(
    BuildContext context, {
    required String label,
    bool isDefault = false,
    T Function()? returnValue,
  }) {
    return _KartiaDialogAction(
      label: label,
      returnValue: returnValue,
      isDefault: isDefault,
    );
  }
}

class _KartiaDialogAction<T> {
  final String label;
  final T Function()? returnValue;
  final bool isDefault;
  _KartiaDialogAction({
    required this.label,
    this.returnValue,
    this.isDefault = false,
  });
}
