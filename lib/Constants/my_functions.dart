import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';




var appBarHeight = AppBar().preferredSize.height;

callNext(var className, var context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => className),
  );
}
callNextReplacement(var className, var context){
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => className),
  );
}
void pushAndRemoveUntil(var className, BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => className),
        (Route<dynamic> route) => false,
  );
}

void showSnackBarMessage(BuildContext context,String text) {
  final overlay = Overlay.of(context); // Get the overlay from the context
  final snackBar = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: MediaQuery.of(context).padding.top , // Position the SnackBar just below the AppBar
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            color: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(color: Colors.white,fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  // Insert the SnackBar into the overlay
  overlay.insert(snackBar);

  // Remove the SnackBar after 2 seconds
  Future.delayed(Duration(seconds: 3), () {
    snackBar.remove();
  });
}

back(var context) {
  Navigator.pop(context);
}
finish(context) {
  Navigator.pop(context);
}
void hideKeyboard(context) {
  FocusScope.of(context).requestFocus(FocusNode());
}
Color hexStringToHexInt(String hex) {
  hex = hex.replaceFirst('#', '');
  hex = hex.length == 6 ? 'ff' + hex : hex;
  int val = int.parse(hex, radix: 16);
  return Color(val);
}
Color colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}

Widget textWidPopins(String text, Color colors, double textsize, FontWeight fontWeight ) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: textsize, // Ensure textsize is a double
      color: colors,
      fontWeight: fontWeight,
    ),
  );
}
void showSnackBarAtTop(BuildContext context,String text) {
  final overlay = Overlay.of(context); // Get the overlay from the context
  final snackBar = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: MediaQuery.of(context).padding.top , // Position the SnackBar just below the AppBar
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            color: Colors.red,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(color: Colors.white,fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  // Insert the SnackBar into the overlay
  overlay.insert(snackBar);

  // Remove the SnackBar after 2 seconds
  Future.delayed(Duration(seconds: 3), () {
    snackBar.remove();
  });
}


