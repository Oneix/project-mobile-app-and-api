import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static String getErrorMessage(String errorCode) {
    // If it's an Exception with a message, extract it
    if (errorCode.startsWith('Exception: ')) {
      return errorCode.replaceFirst('Exception: ', '');
    }
    
    switch (errorCode) {
      case 'invalid-email':
        return 'Het emailadres is ongeldig.';
      case 'user-disabled':
        return 'Dit account is uitgeschakeld.';
      case 'user-not-found':
        return 'Geen account gevonden met dit emailadres.';
      case 'wrong-password':
        return 'Het wachtwoord is onjuist.';
      case 'email-already-in-use':
        return 'Dit emailadres is al in gebruik.';
      case 'weak-password':
        return 'Het wachtwoord is te zwak.';
      case 'network-request-failed':
        return 'Netwerkfout. Controleer je internetverbinding.';
      default:
        // Return the actual error message instead of generic one
        return errorCode.contains('SocketException') 
            ? 'Kan geen verbinding maken met de server. Controleer of de backend draait.'
            : errorCode;
    }
  }
}

class ValidationHelper {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-mailadres is verplicht';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Voer een geldig e-mailadres in';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wachtwoord is verplicht';
    }
    if (value.length < 6) {
      return 'Wachtwoord moet minimaal 6 karakters bevatten';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gebruikersnaam is verplicht';
    }
    if (value.length < 3) {
      return 'Gebruikersnaam moet minimaal 3 karakters bevatten';
    }
    return null;
  }
}