import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistics_express/src/common_widgets/form/form_header.dart';
import 'package:logistics_express/src/features/screens/login/login_screen.dart';
import 'package:logistics_express/src/features/screens/user_screen/user_home_screen.dart';
import '../../../authentication/auth_service.dart';

class VerifyEmail extends ConsumerWidget {
  const VerifyEmail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<bool>(
          //check this work or not
          future: authService.checkEmailVerified(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && snapshot.data == true) {
              // If email is verified, navigate to the next screen
              Future.delayed(Duration.zero, () {
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserHomeScreen()),
                  );
                }
              });
              return const Center(child: Text("Email is verified!"));
            }

            return Column(
              children: [
                const Expanded(
                  flex: 2,
                  child: FormHeader(
                    currentLogo: 'logo',
                    imageSize: 110,
                    text: 'Verifying... Email',
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                          ),
                          // Modify text to include user's email
                          Text(
                            'Verification email link sent to ${authService.getCurrentUserEmail()}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 50),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserHomeScreen(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('Continue'),
                                SizedBox(width: 5),
                                Icon(Icons.arrow_circle_right_outlined),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () async {
                              // Trigger resend email logic
                              await authService.sendEmailVerification();
                            },
                            child: const Text(
                              'Resend Email Link',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.arrow_circle_left,
                              color: Colors.blue,
                            ),
                            label: const Text(
                              'Back to login',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
