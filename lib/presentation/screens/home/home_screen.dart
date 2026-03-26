import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/call_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/pulsing_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9F70D8), Color(0xFFFFB6C1)],
                ),
              ),
            ),
          ),

          // Logout button
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.white, size: 28),
            ),
          ),

          // Main content
          Consumer<CallProvider>(
            builder: (context, callProvider, child) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // WAITING STATE
                      if (callProvider.status != CallStatus.ringing) ...[
                        // Logo
                        Image.asset(
                          'assets/images/logox.png',
                          height: 300,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.favorite,
                            size: 120,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Status text
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Aguardando chamada...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'EVA vai ligar quando precisar falar com voce',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // BOTAO LIGAR PARA EVA
                        SizedBox(
                          width: 280,
                          height: 70,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              callProvider.startOutgoingCall();
                              context.go('/call');
                            },
                            icon: const Icon(Icons.phone, size: 32),
                            label: const Text(
                              'Ligar para EVA',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF9F70D8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                              elevation: 8,
                            ),
                          ),
                        ),
                      ],

                      // RINGING STATE - Pulsing answer button
                      if (callProvider.status == CallStatus.ringing)
                        PulsingButton(
                          imagePath: 'assets/images/oceano_azul.jpg',
                          label: '',
                          size: 400,
                          onTap: () async {
                            context.go('/call');
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );
                            callProvider.acceptCall();
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
