# Panduan untuk AI Coding Agents

## Gaya Penjelasan

- Jelaskan konsep secara bertahap: mulai dari intuisi atau analogi sederhana, lalu detail teknis, kemudian contoh kode yang relevan.
- Gunakan istilah teknis yang tepat, tetapi jelaskan istilah yang mungkin baru bagi pemula.
- Saat mereview atau memperbaiki kode, jelaskan alasan perubahan, dampak terhadap perilaku, dan trade-off-nya, bukan hanya menunjukkan kesalahan.
- Prioritaskan pemahaman jangka panjang, clean code, konsep dasar yang kuat, dan solusi yang dapat dirawat.

## Cara Bekerja di Workspace

- Baca implementasi, pemanggil, dan test terdekat sebelum mengubah kode. Ikuti pola lokal yang sudah ada dan hindari refactor yang tidak diperlukan.
- Pisahkan tanggung jawab sesuai struktur proyek: Flutter screens berada di `Frontend/app_ui/lib/pages`, widget bersama di `lib/widgets`, API/session di `lib/services`, dan model di `lib/models`.
- Pada server, route hanya memasang endpoint; controller menangani request dan operasi data; middleware menangani auth/upload; validasi berada di `src/validations`; database dan schema berada di `src/config`.
- Pertimbangkan edge case, error jaringan, input tidak valid, status HTTP, lifecycle/session, dan perbedaan platform Flutter sebelum menyimpulkan perubahan sudah selesai.
- Jangan menganggap konfigurasi lokal, database, Cloudinary, atau file `.env` tersedia. Jangan menambahkan secret ke repository.

## Verifikasi

Jalankan pemeriksaan yang paling sempit setelah perubahan, lalu pemeriksaan yang relevan secara keseluruhan:

```powershell
Push-Location Frontend/app_ui
flutter analyze
flutter test
Pop-Location

Push-Location Serverblogapp
npx tsc --noEmit
npm test
Pop-Location
```

- Gunakan `flutter run` untuk menjalankan client dan `npm run dev` untuk menjalankan server saat pemeriksaan manual diperlukan.
- `flutter test` saat ini berisi test template yang tidak mencerminkan aplikasi login/register; jangan menganggap kegagalannya sebagai regresi tanpa memeriksa test tersebut.
- `npm test` saat ini adalah placeholder yang sengaja keluar dengan error; gunakan `npx tsc --noEmit` sebagai pemeriksaan TypeScript sampai test server tersedia.
- URL API Flutter menggunakan `10.0.2.2:5000` untuk Android emulator. Periksa konfigurasi platform sebelum mengubahnya untuk web, iOS, atau perangkat fisik.

## Referensi Utama

- Setup Flutter dan dependency: [Frontend/app_ui/README.md](Frontend/app_ui/README.md) dan [Frontend/app_ui/pubspec.yaml](Frontend/app_ui/pubspec.yaml)
- Entry point dan pemasangan route server: [Serverblogapp/src/index.ts](Serverblogapp/src/index.ts)
- Dependency dan script server: [Serverblogapp/package.json](Serverblogapp/package.json)