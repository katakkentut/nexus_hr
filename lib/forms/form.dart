import 'package:flutter/material.dart';

class FormWidget  {
  static Widget buildInput(
    String label,
    TextEditingController controller,
    FocusNode? focusNode,
    TextInputType inputType, {
    bool isObscure = false,
    String? prefixText,
    String? Function(String?)? validator,
    bool isDisabled = false,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        0,
        9,
        0,
        9,
      ),
      child: Container(
        width: 900,
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
        ),
      ),
    );
  }
}