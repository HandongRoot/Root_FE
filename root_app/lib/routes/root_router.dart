import 'package:flutter/material.dart';
import 'package:root_app/modals/login/terms_modal.dart';
import 'package:root_app/navbar.dart';
import 'package:root_app/screens/login/login.dart';
import 'package:root_app/services/api_services.dart';
import 'package:root_app/theme/theme.dart';

class RootRouter extends StatelessWidget {
  final bool isLoggedIn;

  const RootRouter({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return const Login();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: ApiService.getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(
              color: AppTheme.secondaryColor,
            )),
          );
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
              builder: (_) => TermsModal(),
            );
          });
          return const Login();
        }

        return const NavBar();
      },
    );
  }
}
