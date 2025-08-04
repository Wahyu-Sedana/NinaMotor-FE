import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/utils/colors.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/authentication/presentations/bloc/authentication_bloc.dart';
import 'package:frontend/features/authentication/presentations/bloc/event/authentication_event.dart';
import 'package:frontend/features/authentication/presentations/bloc/state/authentication_state.dart';
import 'package:frontend/features/profile/presentations/bloc/event/profile_event.dart';
import 'package:frontend/features/profile/presentations/bloc/profile_bloc.dart';
import 'package:frontend/features/profile/presentations/bloc/state/profile_state.dart';
import 'package:frontend/features/profile/presentations/screens/profile_edit_screen.dart';
import 'package:frontend/features/profile/presentations/widgets/profile_item_widget.dart';
import 'package:frontend/features/routes/route.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final session = locator<Session>();

    return BlocProvider(
      create: (_) => locator<ProfileBloc>()..add(GetProfileEvent()),
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
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
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProfileLoadSuccess) {
                  final profile = state.profile;

                  logger(profile.nama);

                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Profile",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 100,
                        backgroundImage: profile.profile != null
                            ? NetworkImage(profile.profile!)
                            : null,
                        child: profile.profile == null
                            ? const Icon(
                                Icons.person,
                                size: 80,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.nama,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        profile.role,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          children: [
                            buildProfileItem(
                              icon: Icons.person,
                              label: "Edit Profile",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileEditScreen(
                                      profile: profile,
                                    ),
                                  ),
                                );
                              },
                            ),
                            buildProfileItem(
                              icon: Icons.build,
                              label: "History Service",
                              onTap: () {},
                            ),
                            buildProfileItem(
                              icon: Icons.shopping_bag,
                              label: "History Transaksi",
                              onTap: () {
                                Navigator.pushNamed(context,
                                    RouteService.historyPembyaranRoute);
                              },
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .read<AuthenticationBloc>()
                                    .add(LogoutEvent());
                              },
                              icon: const Icon(Icons.logout, color: white),
                              label: const Text(
                                "Sign Out",
                                style: TextStyle(color: white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                }

                if (state is ProfileError) {
                  return Center(child: Text(state.failure.message));
                }

                return const SizedBox(); // default
              },
            ),
          ),
        ),
      ),
    );
  }
}
