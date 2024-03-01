import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormWidget {
  static Widget buildInput(
    BuildContext context,
    String label,
    TextEditingController controller,
    FocusNode? focusNode,
    TextInputType inputType, {
    bool isObscure = false,
    String? prefixText,
    String? Function(String?)? validator,
    bool isDisabled = false,
    void Function(String)? onChanged, // Add this parameter
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        0,
        9,
        0,
        9,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: 370,
              child: Focus(
                child: IgnorePointer(
                  ignoring: isDisabled,
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: false,
                    obscureText: isObscure,
                    decoration: InputDecoration(
                      labelText: label,
                      prefixText: prefixText,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    keyboardType: inputType,
                    validator: validator,
                    onChanged: onChanged,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(DateTime.now().year + 100),
              );
              if (date != null) {
                final formattedDate = DateFormat('d MMM yyyy').format(date);
                controller.text = formattedDate;
                if (onChanged != null) {
                  onChanged(formattedDate);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
