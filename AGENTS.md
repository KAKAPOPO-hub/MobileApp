# PR.md — Refactoring & Refinement App Architecture

## 1. Overview & Objective
Dokumen ini menjadi acuan refactoring besar-besaran untuk menyederhanakan alur kerja aplikasi dan memperjelas pembagian *folder responsibility*:
* **`Serverblogapp/` (Backend Node.js/TypeScript):** Menjadi pusat **seluruh logika bisnis**, autentikasi, manajemen basis data (Drizzle ORM), validasi data, dan integrasi *cloud storage* (Cloudinary).
* **`Frontend/` (Flutter `app_ui`):** Berfokus **murni sebagai *presentation layer*** (tampilan visual, pengolahan *state UI*, dan *HTTP client calls* ke Backend).

---

## 2. Core Constraints & Guiding Principles
1. **Pembersihan Frontend:** Hapus semua logika bisnis berat, kueri database, atau validasi kompleks dari folder frontend. Frontend hanya menerima data siap pakai dari REST API backend.
2. **Backend Minimal Refactor:** Pertahankan struktur controller, route, dan service di `Serverblogapp/` yang sudah ada tanpa melakukan *breaking changes* pada skema basis data utama.
3. **Penyederhanaan & Komponen Reusable (PENTING):**
   * Tampilan Flutter dibuat simpel, *clean*, dan konsisten.
   * **Aturan Reusable Widget:** Jika ada elemen UI/widget yang digunakan lebih dari 1 halaman (contoh: Search Bar di halaman `home.dart` dan `search.dart`, atau `FieldInput`), **WAJIB dibuatkan file tersendiri di dalam folder `lib/widgets/`**. Jangan buat ulang kodingan UI yang sama (*code duplication*).

---

## 3. Component & Structure Rules (`lib/widgets/`)

Setiap elemen UI yang muncul berulang kali di berbagai halaman harus diekstrak menjadi komponen independen:

| Nama Widget | Dipakai di Halaman | Fungsi / Keterangan |
| :--- | :--- | :--- |
| **`search_bar_widget.dart`** | `home.dart`, `search.dart` | Input pencarian postingan universal |
| **`app_bottom_nav_bar.dart`** | Navigation bar utama | Navigasi antar halaman utama |
| **`field_input.dart`** | `login.dart`, `regis.dart`, `create.dart`, `edit_post.dart` | Field input teks standar aplikasi |
| **`post_card_widget.dart`** | `home.dart`, `read.dart`, `profile.dart` | Card preview postingan |

---

## 4. Scope & Feature Requirements

### A. Autentikasi (`/auth`)
* **Register & Login:** User dapat mendaftar dan masuk melalui `regis.dart` dan `login.dart`.
* **Session:** Pengelolaan JWT token disimpan di `auth_session.dart`.

### B. Posting Management (Milik Akun Sendiri)
* **Lihat Detail Posting:** Tampilan detail (`post_detail.dart`) dapat diakses umum atau user terautentikasi.
* **Bikin Post:** User membuat postingan baru di `create.dart` (unggah gambar via Cloudinary).
* **Edit Post:** User mengedit postingan milik akunnya sendiri di `edit_post.dart`.
* **Hapus Post:** User menghapus postingan milik akunnya sendiri dari `profile.dart` atau `post_detail.dart`.

### C. Eksplorasi & Filter
* **Pencarian (Search):** Mencari postingan menggunakan `search_bar_widget` di `search.dart` / `home.dart`.
* **Filter Kategori:** Memfilter daftar postingan berdasarkan kategori di `home.dart` / `read.dart`.

---

## 5. API Endpoints Alignment (`Serverblogapp`)

Berikut pemetaan *route* backend yang dipanggil oleh Flutter:

| Fitur | Method | Endpoint | Auth Required | Keterangan |
| :--- | :--- | :--- | :--- | :--- |
| **Register** | `POST` | `/api/auth/register` | No | Pendaftaran akun baru |
| **Login** | `POST` | `/api/auth/login` | No | Mengembalikan JWT Token |
| **Get All Posts** | `GET` | `/api/posts?search=&category=` | No | Daftar postingan + search & filter |
| **Get Post Detail** | `GET` | `/api/posts/:id` | No | Detail postingan berdasarkan ID |
| **Get My Posts** | `GET` | `/api/posts/me` | **Yes** | Postingan khusus milik user login |
| **Create Post** | `POST` | `/api/posts` | **Yes** | Menambah postingan baru |
| **Update Post** | `PUT` | `/api/posts/:id` | **Yes** | Mengedit postingan milik sendiri |
| **Delete Post** | `DELETE` | `/api/posts/:id` | **Yes** | Menghapus postingan milik sendiri |

---

## 6. Definition of Done (DoD)
* [ ] Komponen UI yang dipakai di >1 halaman sudah dipisah ke folder `lib/widgets/`.
* [ ] Tidak ada duplikasi kode tampilan untuk komponen yang sama (seperti Search Bar).
* [ ] CRUD postingan berjalan lancar dan terintegrasi penuh antara Flutter dan Backend Node.js.
* [ ] User hanya dapat mengedit dan menghapus postingan milik akun sendiri (ownership terverifikasi di backend).