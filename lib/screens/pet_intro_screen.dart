import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/storage_service.dart';
import 'home_screen.dart';

/// 'Evcil Hayvanını Tanıt' ekranı: ad, yaş, cins ve profil fotoğrafı.
class PetIntroScreen extends StatefulWidget {
  const PetIntroScreen({super.key});

  @override
  State<PetIntroScreen> createState() => _PetIntroScreenState();
}

class _PetIntroScreenState extends State<PetIntroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _breedController = TextEditingController();
  final _otherSpeciesController = TextEditingController();
  final _storage = StorageService();
  final _picker = ImagePicker();

  static const _otherSpecies = 'Diğer';
  static const _speciesOptions = [
    'Kedi',
    'Köpek',
    'Kuş',
    'Tavşan',
    'Hamster',
    'Balık',
    _otherSpecies,
  ];

  Uint8List? _photoBytes;
  String? _species;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    _otherSpeciesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    // Küçültüp sıkıştırıyoruz; fotoğraf SharedPreferences içinde saklanıyor.
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _photoBytes = bytes);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final species = _species == _otherSpecies
        ? _otherSpeciesController.text.trim()
        : _species!;
    await _storage.savePet(
      PetProfile(
        name: _nameController.text.trim(),
        age: _ageController.text.trim(),
        species: species,
        breed: _breedController.text.trim(),
        photoBytes: _photoBytes,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  String? _required(String? value, String message) =>
      (value == null || value.trim().isEmpty) ? message : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Evcil Hayvanını Tanıt')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickPhoto,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          backgroundImage: _photoBytes == null
                              ? null
                              : MemoryImage(_photoBytes!),
                          child: _photoBytes == null
                              ? Icon(
                                  Icons.pets,
                                  size: 48,
                                  color: theme.colorScheme.outline,
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: theme.colorScheme.primary,
                            child: Icon(
                              Icons.photo_library,
                              size: 18,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Galeriden fotoğraf seç',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Adı'),
                  validator: (v) => _required(v, 'Lütfen bir ad gir'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Yaşı'),
                  validator: (v) => _required(v, 'Lütfen yaş gir'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _species,
                  decoration: const InputDecoration(
                    labelText: 'Türü',
                    hintText: 'Kedi, köpek, kuş...',
                  ),
                  items: [
                    for (final option in _speciesOptions)
                      DropdownMenuItem(value: option, child: Text(option)),
                  ],
                  onChanged: (value) => setState(() => _species = value),
                  validator: (v) =>
                      v == null ? 'Lütfen hayvan türünü seç' : null,
                ),
                if (_species == _otherSpecies) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _otherSpeciesController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Hangi tür?'),
                    validator: (v) => _required(v, 'Lütfen türü yaz'),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _breedController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Cinsi'),
                  validator: (v) => _required(v, 'Lütfen cins gir'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _save,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Kaydet'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
