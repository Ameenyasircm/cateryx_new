import 'package:url_launcher/url_launcher.dart';

void callNumber(String phone) async {
  final Uri url = Uri(scheme: "tel", path: phone);
  await launchUrl(url);
}

void openWhatsApp(String phone) async {
  final Uri url = Uri.parse("https://wa.me/$phone");
  await launchUrl(url, mode: LaunchMode.externalApplication);
}
Future<void> launchWebsite() async {
  final uri = Uri.parse(
    'https://codematessolutions.netlify.app',
  );
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch website';
  }
}

Future<void> launchEmail() async {
  final uri = Uri(
    scheme: 'mailto',
    path: 'codematessolution@gmail.com',
    query: 'subject=Support Request',
  );
  await launchUrl(uri);
}

Future<void> launchPhone() async {
  final uri = Uri(
    scheme: 'tel',
    path: '+918086783125',
  );
  await launchUrl(uri);
}