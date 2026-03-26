import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:eva_mobile/providers/call_provider.dart';
import 'package:eva_mobile/presentation/widgets/pulsing_button.dart';
import 'package:logger/logger.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<CallProvider>(
        builder: (context, provider, child) {
          final isConnected = provider.status == CallStatus.connected;

          return Stack(
            children: [
              // Background Layer
              Positioned.fill(
                child: isConnected
                    ? Container(color: Colors.white)
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFB6C1),
                              Color(0xFFE0B0FF),
                            ],
                          ),
                        ),
                      ),
              ),

              // Logo Layer (Waiting Only)
              if (!isConnected)
                Center(
                  child: Image.asset(
                    'assets/images/logox.png',
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),

              // EVA Avatar (Connected)
              if (isConnected)
                Center(
                  child: Image.asset(
                    'assets/images/logox.png',
                    width: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.favorite,
                      size: 120,
                      color: Colors.pink,
                    ),
                  ),
                ),

              // UI Layer (Controls)
              SafeArea(child: _buildCallUI(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCallUI(CallProvider provider) {
    switch (provider.status) {
      case CallStatus.idle:
      case CallStatus.connecting:
        return _buildConnectingState();

      case CallStatus.ringing:
        return _buildRingingState(provider);

      case CallStatus.connected:
        return _buildConnectedState(provider);

      case CallStatus.error:
        return _buildErrorState(provider);

      case CallStatus.ended:
      case CallStatus.ending:
        return _buildEndedState(provider);
    }
  }

  Widget _buildRingingState(CallProvider provider) {
    return Center(
      child: PulsingButton(
        imagePath: 'assets/images/oceano_azul.jpg',
        label: '',
        size: 280,
        onTap: () async {
          try {
            provider.acceptCall();
          } catch (e) {
            _logger.e('Error accepting call: $e');
          }
        },
      ),
    );
  }

  Widget _buildConnectingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 30),
          Text(
            'Conectando...',
            style: TextStyle(
              fontSize: 24,
              color: Colors.pink.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedState(CallProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _build3DButton(
                icon: provider.isMuted ? Icons.mic_off : Icons.mic,
                label: provider.isMuted ? 'Mudo' : 'Microfone',
                colors: [const Color(0xFFE0B0FF), const Color(0xFF9F70D8)],
                onTap: () => provider.toggleMute(),
              ),
              _build3DButton(
                icon: Icons.call_end,
                label: 'Desligar',
                isCritical: true,
                colors: [const Color(0xFFFF6B6B), const Color(0xFFC92A2A)],
                onTap: () => provider.endCall(),
              ),
              _build3DButton(
                icon: provider.isSpeakerOn ? Icons.volume_up : Icons.hearing,
                label: provider.isSpeakerOn ? 'Alto-falante' : 'Fone',
                colors: [const Color(0xFFFFB6C1), const Color(0xFFFF69B4)],
                onTap: () => provider.toggleSpeaker(),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildErrorState(CallProvider provider) {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) context.go('/home');
    });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 20),
          Text(
            'Erro na chamada',
            style: TextStyle(
              fontSize: 24,
              color: Colors.red.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              provider.errorMessage ?? 'Reiniciando sistema...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndedState(CallProvider provider) {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/home');
    });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.call_end, size: 80, color: Colors.pink.shade300),
          const SizedBox(height: 20),
          Text(
            'Chamada Encerrada',
            style: TextStyle(
              fontSize: 24,
              color: Colors.pink.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DButton({
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
    bool isCritical = false,
  }) {
    final size = isCritical ? 100.0 : 80.0;
    final iconSize = isCritical ? 50.0 : 40.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(size / 2),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.last.withValues(alpha: 0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(-4, -4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: iconSize,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.pink.shade900,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
