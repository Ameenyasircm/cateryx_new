import 'package:url_launcher/url_launcher.dart';

void callNumber(String phone) async {
  final Uri url = Uri(scheme: "tel", path: phone);
  await launchUrl(url);
}

void openWhatsApp(String phone) async {
  final Uri url = Uri.parse("https://wa.me/$phone");
  await launchUrl(url, mode: LaunchMode.externalApplication);
}
