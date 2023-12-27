import 'package:flutter/material.dart';

const mainUrl = 'https://sea-turtle-app-qpyzd.ondigitalocean.app';

void showErrorMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red, // Customize the background color
      duration: const Duration(seconds: 3), // Adjust the duration as needed
    ),
  );
}

void showSendMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green, // Customize the background color
      duration: const Duration(seconds: 3), // Adjust the duration as needed
    ),
  );
}

