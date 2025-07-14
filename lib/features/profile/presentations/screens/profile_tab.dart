import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/utils/colors.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/authentication/presentations/bloc/authentication_bloc.dart';
import 'package:frontend/features/authentication/presentations/bloc/event/authentication_event.dart';
import 'package:frontend/features/authentication/presentations/bloc/state/authentication_state.dart';
import 'package:frontend/features/profile/presentations/widgets/profile_item_widget.dart';
import 'package:frontend/features/routes/route.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final session = locator<Session>();
    return BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationLogoutLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is AuthenticationLogoutSuccess) {
            session.clearSession();
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, RouteService.loginRoute);
          }

          if (state is AuthenticationLogoutError) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Profile",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/men/1.jpg',
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 20,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.edit,
                            size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Albert Florest",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Buyer",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      buildProfileItem(
                        icon: Icons.person,
                        label: "Edit Profile",
                        onTap: () {},
                      ),
                      buildProfileItem(
                        icon: Icons.build,
                        label: "History Service",
                        onTap: () {},
                      ),
                      buildProfileItem(
                        icon: Icons.shopping_bag,
                        label: "History Transaksi",
                        onTap: () {},
                      ),
                      buildProfileItem(
                        icon: Icons.lock,
                        label: "Change Password",
                        onTap: () {},
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<AuthenticationBloc>().add(LogoutEvent());
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: white,
                        ),
                        label: const Text(
                          "Sign Out",
                          style: TextStyle(color: white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
