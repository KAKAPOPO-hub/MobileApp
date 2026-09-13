# Panduan Discovery dan Post

## Perubahan yang dibuat

1. Tombol floating action dihapus dari halaman Home.
2. Tab kedua navbar sekarang menjadi **Discovery** dengan ikon explore.
3. Discovery mengambil daftar post dari endpoint:

   `GET /api/v1/posts`

4. Discovery menampilkan:
   - kolom pencarian post atau akun,
   - judul dan isi post,
   - gambar post jika tersedia,
   - username akun pembuat post.
5. API posts sekarang mengirim data akun pembuat melalui properti `author`.
6. Pada controller posts, data `users.id` dan `users.username` diambil sebagai
  field datar `authorId` dan `authorUsername`, kemudian dibentuk menjadi objek
  `author` sebelum response dikirim. Cara ini memastikan username tetap muncul
  pada response runtime Drizzle.

## Response API

Endpoint `GET /api/v1/posts` sekarang mengembalikan bentuk data seperti berikut:

```json
{
  "success": true,
  "data": {
    "posts": [
      {
        "id": 1,
        "userId": 2,
        "title": "Judul post",
        "content": "Isi post",
        "imageUrl": null,
        "status": "published",
        "author": {
          "id": 2,
          "username": "namaakun"
        }
      }
    ]
  }
}
```

Data `author` berasal dari tabel `users` melalui relasi `posts.userId = users.id`. Password tidak dikirim oleh endpoint ini.

## Hasil pengujian username

Endpoint sudah diuji langsung setelah proses server lama pada port `5000`
dihentikan dan server dijalankan ulang dari source terbaru. Hasil dari database:

| Post user ID | Username dari tabel `users` |
| --- | --- |
| `4` | `IGortest1` |
| `3` | `vino` |

Contoh response aktual:

```json
{
  "userId": 4,
  "author": {
    "id": 4,
    "username": "IGortest1"
  }
}
```

## File penting

- `Frontend/app_ui/lib/pages/search.dart`
  - Tampilan Discovery.
  - Mengambil data melalui `PostService`.
  - Filter pencarian berdasarkan judul, isi, dan username.
- `Frontend/app_ui/lib/models/post.dart`
  - Model `PostAuthor` untuk membaca data `author` dari API.
- `Frontend/app_ui/lib/services/post_service.dart`
  - Request daftar post ke server.
- `Frontend/app_ui/lib/pages/home.dart`
  - Daftar tab navbar dan card post Home.
  - FAB sudah dihapus.
- `Frontend/app_ui/lib/widgets/app_bottom_nav_bar.dart`
  - Navbar reusable tanpa slot FAB.
- `Serverblogapp/src/controllers/posts/posts.controller.ts`
  - Endpoint posts melakukan join ke tabel users.
  - Mengubah hasil join menjadi properti `author` berisi `id` dan `username`.

## Menjalankan aplikasi

### Server

```powershell
Push-Location Serverblogapp
npm install
npx tsc --noEmit
npm run dev
Pop-Location
```

Pastikan database dan file environment server sudah dikonfigurasi.

### Flutter

```powershell
Push-Location Frontend/app_ui
flutter pub get
flutter analyze
flutter run
Pop-Location
```

Untuk Android emulator, pastikan base URL API menggunakan `10.0.2.2` jika server berjalan di komputer lokal.

## Jika post tidak muncul

1. Pastikan server sedang berjalan.
2. Pastikan database berisi post dengan status `published`.
3. Pastikan data post memiliki `userId` yang cocok dengan `users.id`.
4. Periksa base URL pada `Frontend/app_ui/lib/config/api_config.dart`.
5. Jalankan ulang aplikasi setelah server dan database siap.

## Pengembangan berikutnya

Jika ingin menambahkan avatar asli, tambahkan kolom avatar pada tabel users, kirim field tersebut di properti `author`, lalu tampilkan dengan `Image.network` di kartu Discovery.

## Letak Perubahan untuk Pemula

Bagian ini menjelaskan file, class, dan lokasi kode yang diubah.

### 1. Halaman Discovery

File: `Frontend/app_ui/lib/pages/search.dart`

- Class `SearchPage` berada di bagian awal file. Class ini adalah halaman utama Discovery.
- Class `_SearchPageState` mengatur proses mengambil data post, pencarian, loading, error, dan refresh.
- Method `_matches` digunakan untuk mencocokkan kata pencarian dengan judul, isi, atau username.
- Teks `Hasil post orang` berada di bagian tampilan utama Discovery.
- Class `_DiscoveryPostCard` digunakan untuk menampilkan satu card post.
- Username pembuat post ditampilkan di dalam class `_DiscoveryPostCard` melalui `post.author.username`.

### 2. Model akun pembuat post

File: `Frontend/app_ui/lib/models/post.dart`

- Class `PostAuthor` digunakan untuk menyimpan `id` dan `username` akun pembuat post.
- Class `Post` digunakan untuk menyimpan data post, termasuk properti `author`.
- Method `Post.fromJson` mengubah response JSON dari API menjadi object Dart.

### 3. Controller API posts

File: `Serverblogapp/src/controllers/posts/posts.controller.ts`

- Class `PostsController` berisi controller untuk endpoint post.
- Method `getPosts` mengambil data post dari database.
- Query pada method tersebut melakukan join dari `posts.userId` ke `users.id`.
- `users.username` diambil sebagai `authorUsername`.
- Setelah query selesai, data tersebut dibentuk menjadi object `author` yang berisi `id` dan `username`.

### 4. Daftar navigasi Home

File: `Frontend/app_ui/lib/pages/home.dart`

- Class `Home` berisi daftar tab navigasi aplikasi.
- Tab kedua menggunakan ikon `Icons.explore_rounded` dan membuka `SearchPage` sebagai Discovery.
- Class `_HomeContent` berisi tampilan Home dan daftar post.
- Floating button sudah dihapus dari halaman Home.

### 5. Navbar reusable

File: `Frontend/app_ui/lib/widgets/app_bottom_nav_bar.dart`

- Class `NavItem` adalah model untuk setiap item navbar.
- Class `AppBottomNavBar` adalah widget navbar yang digunakan oleh aplikasi.
- Navbar sekarang tidak lagi memiliki slot floating button.

### Ringkasan alur data

1. Database menyimpan `posts.userId`.
2. Controller `getPosts` mencocokkan `posts.userId` dengan `users.id`.
3. Controller mengambil `users.username`.
4. API mengirim username melalui properti `author`.
5. Model `PostAuthor` membaca data tersebut di Flutter.
6. `_DiscoveryPostCard` menampilkan username pada card Discovery.
