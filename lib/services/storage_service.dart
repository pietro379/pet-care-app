import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

/// Evcil hayvan bilgisini temsil eden basit model.
class PetProfile {
  const PetProfile({
    required this.name,
    required this.age,
    required this.species,
    required this.breed,
    this.photoBytes,
  });

  final String name;
  final String age;

  /// Hayvanın türü: kedi, köpek, kuş vb.
  final String species;
  final String breed;
  final Uint8List? photoBytes;
}

/// Cihaz hafızasına (SharedPreferences) erişimi tek yerde toplar.
class StorageService {
  static const _kPhone = 'user_phone';
  static const _kPetName = 'pet_name';
  static const _kPetAge = 'pet_age';
  static const _kPetSpecies = 'pet_species';
  static const _kPetBreed = 'pet_breed';
  static const _kMyVetId = 'my_vet_id';
  static const _kPetPhoto = 'pet_photo_base64';
  static const _kDarkTheme = 'dark_theme';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveLoggedInPhone(String phone) async {
    final prefs = await _prefs;
    await prefs.setString(_kPhone, phone);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getString(_kPhone) != null;
  }

  Future<void> savePet(PetProfile pet) async {
    final prefs = await _prefs;
    await prefs.setString(_kPetName, pet.name);
    await prefs.setString(_kPetAge, pet.age);
    await prefs.setString(_kPetSpecies, pet.species);
    await prefs.setString(_kPetBreed, pet.breed);
    if (pet.photoBytes != null) {
      await prefs.setString(_kPetPhoto, base64Encode(pet.photoBytes!));
    } else {
      await prefs.remove(_kPetPhoto);
    }
  }

  /// Yalnızca evcil hayvanın profil fotoğrafını günceller.
  Future<void> savePetPhoto(Uint8List bytes) async {
    final prefs = await _prefs;
    await prefs.setString(_kPetPhoto, base64Encode(bytes));
  }

  /// Kullanıcının "kendi veterinerim" olarak seçtiği kliniğin kimliği.
  Future<String?> loadMyVetId() async {
    final prefs = await _prefs;
    return prefs.getString(_kMyVetId);
  }

  Future<void> saveMyVetId(String? id) async {
    final prefs = await _prefs;
    if (id == null) {
      await prefs.remove(_kMyVetId);
    } else {
      await prefs.setString(_kMyVetId, id);
    }
  }

  Future<PetProfile?> loadPet() async {
    final prefs = await _prefs;
    final name = prefs.getString(_kPetName);
    if (name == null) return null;
    final photo = prefs.getString(_kPetPhoto);
    return PetProfile(
      name: name,
      age: prefs.getString(_kPetAge) ?? '',
      // Tür alanı eklenmeden önce kaydedilmiş veriler için boş kalabilir.
      species: prefs.getString(_kPetSpecies) ?? '',
      breed: prefs.getString(_kPetBreed) ?? '',
      photoBytes: photo == null ? null : base64Decode(photo),
    );
  }

  Future<String?> loadPhone() async {
    final prefs = await _prefs;
    return prefs.getString(_kPhone);
  }

  Future<bool> loadIsDarkTheme() async {
    final prefs = await _prefs;
    return prefs.getBool(_kDarkTheme) ?? false;
  }

  Future<void> saveIsDarkTheme(bool isDark) async {
    final prefs = await _prefs;
    await prefs.setBool(_kDarkTheme, isDark);
  }

  /// Cihazdaki tüm kayıtlı verileri (giriş, evcil hayvan, tema) siler.
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
