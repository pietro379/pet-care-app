import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/storage_service.dart';
import 'pet_intro_screen.dart';

/// SMS doğrulama ekranı. Demo aşamasında geçerli kod: 123456.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _demoCode = '123456';

  final _codeController = TextEditingController();
  final _storage = StorageService();
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_codeController.text != _demoCode) {
      setState(() => _error = 'Kod hatalı, tekrar dene');
      return;
    }
    await _storage.saveLoggedInPhone(widget.phone);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PetIntroScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Doğrulama')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '+90 ${widget.phone} numarasına gönderilen 6 haneli kodu gir.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: theme.textTheme.headlineSmall?.copyWith(
                  letterSpacing: 8,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '123456',
                  errorText: _error,
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: (_) => _verify(),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _verify,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Doğrula'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
