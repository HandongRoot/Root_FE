import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:root_app/modals/login/terms_modal.dart';
import 'package:root_app/navbar.dart';
import 'package:root_app/screens/login/login.dart';
import 'package:root_app/services/api_services.dart';
import 'package:root_app/theme/theme.dart';

class RootRouter extends StatelessWidget {
  final bool isLoggedIn;

  const RootRouter({super.key, required this.isLoggedIn});

  Future<void> _clearTokens() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return const Login();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: ApiService.getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.secondaryColor,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          // Token likely invalid - clear and redirect
          _clearTokens();
          return const Login();
        }

        final user = snapshot.data!;
        final agreed = user['termsOfServiceAgrmnt'] == true &&
            user['privacyPolicyAgrmnt'] == true;

        if (!agreed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const TermsModal(),
            );
          });
          return const Login();
        }

        return const NavBar();
      },
    );
  }
}
