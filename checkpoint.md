# CHECKPOINT - EVA-Mobile
**Data:** 2026-02-19
**Status:** ~65% funcional - core voice call funciona, muitas features sao stubs

---

## O QUE E O PROJETO
App Flutter Android para idosos - assistente virtual com chamadas de voz IA via WebSocket (PCM streaming), video chamada WebRTC, push notifications Firebase.

**Tech Stack:** Flutter 3.x, Provider, GoRouter, Firebase FCM, sound_stream (PCM16), flutter_webrtc, flutter_callkit_incoming

---

## O QUE FUNCIONA
- Login por CPF + validacao backend
- Chamadas de voz saindo/entrando via WebSocket PCM (16kHz in / 24kHz out)
- Push notifications Firebase (background + foreground)
- CallKit overlay nativo
- Video call WebRTC com signaling WebSocket
- FCM token sync + rotacao
- Envio de logs de erro para backend
- Armazenamento seguro (flutter_secure_storage)
- API completa para medicamentos, sinais vitais, agendamentos (service layer pronto)

---

## O QUE FALTA / INCOMPLETO
1. **Mute VISUAL ONLY** - toggleMute() so muda icone, NAO para captura de audio
2. **Speaker VISUAL ONLY** - toggleSpeaker() so muda boolean, nao roteia audio
3. **CallKit events todos TODO** - 12+ handlers sao stubs com logger
4. **Nenhuma tela de medicamentos** apesar de API service completo
5. **Nenhuma tela de sinais vitais** apesar de API service completo
6. **AuthProvider.initialize() nunca chamado** - sem validacao de sessao no restart
7. **iOS nao configurado** - pasta ios/ nao existe
8. **Zero testes**
9. **Health Connect permissoes** declaradas no Manifest mas ZERO codigo Dart
10. **Whisper.cpp compilado mas NUNCA carregado** (libwhisper.so morta)

---

## BUGS CRITICOS
1. **HTTP/WS em producao** - .env usa http:// e ws:// mas network_security_config bloqueia cleartext (app CRASHA)
2. **Future.delayed dentro de build()** - error/ended states criam timers a cada rebuild
3. **Firebase callback registrado 2x** (construtor + main)
4. **CPF em plaintext** SharedPreferences (deveria ser SecureStorage)
5. **BackendSelector** nao seleciona nada (fallback = mesmo servidor)

---

## DEAD CODE
- call_controls.dart, audio_visualizer.dart (widgets nunca importados)
- custom_button.dart, loading_indicator.dart (wrappers triviais nunca usados)
- AppLogger, AppPermissions, AppTheme, AppAssets (nunca usados)
- colors.dart + material.dart (2 AppColors conflitantes)
- Whisper.cpp + ggml.c (compilam mas nao carregam)
- winhoff.mp3 (nao referenciado)
- API methods polling antigos (sendIceCandidate, getVideoAnswer)

---

## .md PARA DELETAR
- assets/sounds/README.md (documenta sons que nao existem)
