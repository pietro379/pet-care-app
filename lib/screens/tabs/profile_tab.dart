import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_state.dart';
import '../../services/storage_service.dart';
import '../login_screen.dart';

class _ProfileData {
  const _ProfileData({required this.pet, required this.phone});

  final PetProfile? pet;
  final String? phone;
}

/// Profil sekmesi: evcil hayvan fotoğrafı, kayıt bilgileri, tema anahtarı ve veri silme.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _storage = StorageService();
  final _picker = ImagePicker();
  late Future<_ProfileData> _future = _load();

  Future<_ProfileData> _load() async {
    final pet = await _storage.loadPet();
    final phone = await _storage.loadPhone();
    return _ProfileData(pet: pet, phone: phone);
  }

  Future<void> _setDark(bool isDark) async {
    themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    await _storage.saveIsDarkTheme(isDark);
  }

  /// Galeriden yeni fotoğraf seçip kaydeder; iptal edilirse null döner.
  Future<Uint8List?> _pickAndSavePhoto() async {
    // Küçültüp sıkıştırıyoruz; fotoğraf SharedPreferences içinde saklanıyor.
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 80,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    await _storage.savePetPhoto(bytes);
    petRevisionNotifier.value++;
    if (mounted) {
      setState(() {
        _future = _load();
      });
    }
    return bytes;
  }

  void _openPhotoViewer(PetProfile? pet) {
    showDialog<void>(
      context: context,
      builder: (_) => _PhotoViewerDialog(
        initialBytes: pet?.photoBytes,
        onEdit: _pickAndSavePhoto,
      ),
    );
  }

  Future<void> _confirmAndDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(dialogContext).colorScheme.error,
          size: 36,
        ),
        title: const Text('Tüm verilerin silinsin mi?'),
        content: const Text(
          'Evcil hayvan bilgilerin, fotoğrafın ve tüm ayarların bu cihazdan '
          'kalıcı olarak silinecek. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Evet, Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _storage.clearAll();
    themeModeNotifier.value = ThemeMode.light;
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: FutureBuilder<_ProfileData>(
        future: _future,
        builder: (context, snapshot) {
          // Fotoğraf değişince yeniden yüklenirken sayfa titremesin diye
          // yalnızca ilk yüklemede spinner gösteriyoruz.
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final pet = data.pet;
          final phone = data.phone;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              _PetHeader(pet: pet, onPhotoTap: () => _openPhotoViewer(pet)),
              const SizedBox(height: 28),
              Text(
                'Bilgilerim',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.phone_outlined,
                label: 'Telefon',
                value: phone == null ? '-' : '+90 $phone',
              ),
              _InfoCard(
                icon: Icons.pets,
                label: 'Pet Adı',
                value: pet?.name ?? '-',
              ),
              _InfoCard(
                icon: Icons.cruelty_free_outlined,
                label: 'Tür',
                value: (pet == null || pet.species.isEmpty) ? '-' : pet.species,
              ),
              _InfoCard(
                icon: Icons.cake_outlined,
                label: 'Yaş',
                value: pet == null ? '-' : '${pet.age} yaşında',
              ),
              _InfoCard(
                icon: Icons.category_outlined,
                label: 'Cins',
                value: pet?.breed ?? '-',
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeModeNotifier,
                builder: (context, mode, _) => Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: _cardShape(theme),
                  child: SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Tema Değiştir'),
                    subtitle: Text(
                      mode == ThemeMode.dark ? 'Koyu tema' : 'Açık tema',
                    ),
                    value: mode == ThemeMode.dark,
                    onChanged: _setDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                onPressed: _confirmAndDeleteAll,
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Tüm Verilerimi Sil'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

ShapeBorder _cardShape(ThemeData theme) => RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(18),
  side: BorderSide(color: theme.colorScheme.outlineVariant),
);

/// Evcil hayvanın yuvarlak profil fotoğrafı ve altında özet bilgisi.
/// Fotoğrafa dokununca büyütülmüş görünüm açılır.
class _PetHeader extends StatelessWidget {
  const _PetHeader({required this.pet, required this.onPhotoTap});

  final PetProfile? pet;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photo = pet?.photoBytes;
    final summary = [
      if (pet != null && pet!.species.isNotEmpty) pet!.species,
      if (pet != null) pet!.breed,
      if (pet != null) '${pet!.age} yaşında',
    ].join(' • ');

    return Column(
      children: [
        GestureDetector(
          onTap: onPhotoTap,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary, width: 2),
            ),
            child: CircleAvatar(
              radius: 64,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: photo == null ? null : MemoryImage(photo),
              child: photo == null
                  ? Icon(
                      Icons.pets,
                      size: 52,
                      color: theme.colorScheme.onPrimaryContainer,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          pet?.name ?? 'Profilim',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (summary.isNotEmpty)
          Text(summary, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

/// Büyütülmüş profil fotoğrafı. Sağ üstteki kalemle yeni fotoğraf seçilir.
class _PhotoViewerDialog extends StatefulWidget {
  const _PhotoViewerDialog({required this.initialBytes, required this.onEdit});

  final Uint8List? initialBytes;
  final Future<Uint8List?> Function() onEdit;

  @override
  State<_PhotoViewerDialog> createState() => _PhotoViewerDialogState();
}

class _PhotoViewerDialogState extends State<_PhotoViewerDialog> {
  late Uint8List? _bytes = widget.initialBytes;
  bool _busy = false;

  Future<void> _edit() async {
    setState(() => _busy = true);
    final picked = await widget.onEdit();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (picked != null) _bytes = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bytes = _bytes;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (bytes != null)
              InteractiveViewer(child: Image.memory(bytes, fit: BoxFit.cover))
            else
              ColoredBox(
                color: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.pets,
                  size: 96,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                tooltip: 'Fotoğrafı değiştir',
                onPressed: _busy ? null : _edit,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.edit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: _cardShape(theme),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 22),
        ),
        title: Text(label, style: theme.textTheme.bodySmall),
        subtitle: Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
