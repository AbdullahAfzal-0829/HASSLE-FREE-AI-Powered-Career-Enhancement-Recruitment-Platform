import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

Widget buildGoogleSignInButton({required VoidCallback onPressed}) {
  // On the web, we MUST use Google's official rendered button due to Identity Services rules.
  // The official button intercepts clicks, handles the popup securely, and triggers state updates.
  return SizedBox(
    height: 52,
    child: web.renderButton(),
  );
}
