# Arsitektur Sistem Product List - Laravel & Vue.js

## Deskripsi Arsitektur

### 1. Alur Request-Response antara Vue.js dan Laravel

Aplikasi ini menggunakan arsitektur **Client-Server** dengan pemisahan yang jelas antara frontend (Vue.js) dan backend (Laravel). Komunikasi dilakukan melalui **RESTful API** menggunakan protokol HTTP/HTTPS dengan format data JSON.

Ketika pengguna berinteraksi dengan halaman web (mengubah keyword pencarian, mengganti urutan sorting, atau berpindah halaman), komponen Vue.js `ProdukView.vue` akan mendeteksi perubahan tersebut melalui event listeners (`@input`, `@change`, `@click`). Setiap perubahan akan memicu method `fetchProduk()` yang menggunakan library **Axios** untuk mengirim HTTP POST request ke endpoint Laravel `http://localhost:8000/api/produk/list`. Request ini membawa payload JSON berisi parameter: `keyword`, `sort_by`, `sort_dir`, `start`, dan `limit`.

Laravel menerima request melalui routing yang didefinisikan di `routes/api.php` yang mengarahkan ke `ProdukController@list`. Controller memproses request, menjalankan query database, dan mengembalikan response JSON berisi dua key utama: `count` (total data setelah filter) dan `produk` (array data hasil pagination). Vue.js menerima response ini, melakukan update pada reactive state, dan otomatis me-render ulang tampilan tabel dan pagination tanpa reload halaman (Single Page Application).

### 2. Backend: Menangani Filter, Sorting, dan Pagination

Di sisi backend, `ProdukController` menggunakan **Eloquent Query Builder** untuk membangun query SQL secara dinamis dan efisien. Proses dimulai dengan validasi input menggunakan Laravel Validator untuk memastikan parameter yang diterima sesuai dengan aturan (misalnya `sort_by` hanya boleh berisi `nama_produk`, `harga`, atau `stok`).

Untuk filtering, jika parameter `keyword` tidak kosong, query akan menambahkan kondisi `WHERE` dengan operator `LIKE` yang mencari di dua kolom sekaligus: `nama_produk` dan `kategori`. Penggunaan closure `where(function($q))` memastikan kondisi OR terbungkus dalam parentheses di query SQL, mencegah konflik dengan kondisi WHERE lainnya.

Sebelum menerapkan pagination, sistem menghitung total records dengan method `count()` untuk mendapatkan jumlah data setelah filtering. Hasil count ini dikirim ke frontend untuk menghitung total halaman. Kemudian query menerapkan sorting dengan `orderBy($sortBy, $sortDir)` dan pagination menggunakan `offset($start)->limit($limit)`. Penggunaan `offset` dan `limit` menghasilkan query SQL dengan klausa `LIMIT` dan `OFFSET` yang efisien untuk database MySQL.

Semua proses ini dilakukan dalam satu query pipeline yang optimal, menghindari multiple query atau N+1 problem. Response JSON dikembalikan dengan structure yang konsisten memudahkan parsing di frontend.

### 3. Frontend: State Management, Pagination, dan Penomoran

Komponen `ProdukView.vue` menggunakan **Vue 3 Composition API** dengan `data()` untuk mengelola reactive state. State utama meliputi: `produk` (array data), `totalCount` (total records), `currentPage` (halaman aktif), `limit` (items per page), `keyword`, `sortBy`, `sortDir`, `loading` (status loading), dan `error` (error message).

Untuk user experience yang baik, pencarian menggunakan **debouncing technique** dengan timer 500ms. Ketika user mengetik di search box, timer akan direset setiap keystroke. Request baru ke backend hanya dikirim setelah user berhenti mengetik selama 500ms, mengurangi jumlah request dan beban server. Saat sorting atau pagination berubah, system langsung fetch data tanpa delay karena tidak ada ambiguitas dari user input.

State `currentPage` di-reset ke halaman 1 setiap kali terjadi perubahan keyword atau sorting untuk menghindari kondisi dimana user berada di halaman yang tidak exist setelah filter baru. Computed property `totalPages` menghitung jumlah total halaman dengan formula `Math.ceil(totalCount / limit)`. Computed property `visiblePages` menghasilkan array nomor halaman yang ditampilkan (maksimal 5 halaman) dengan logika untuk menampilkan range yang dinamis mengikuti posisi `currentPage`.

Penomoran row tabel dihitung dengan method `getRowNumber(index)` menggunakan formula: `(currentPage - 1) * limit + index + 1`. Ini memastikan nomor urut berkelanjutan di semua halaman. Misalnya dengan `limit=10`, halaman 1 menampilkan nomor 1-10, halaman 2 menampilkan 11-20, dan seterusnya. Method ini dipanggil di template untuk setiap row dalam loop `v-for`, menghasilkan nomor urut yang konsisten tanpa bergantung pada ID database.

Semua perubahan state secara otomatis memicu re-render komponen berkat Vue's reactivity system, memberikan pengalaman real-time yang smooth kepada pengguna tanpa perlu manual DOM manipulation.

---

## Teknologi yang Digunakan

### Backend
- **Laravel 11** - PHP Framework
- **MySQL** - Database
- **Eloquent ORM** - Database Query Builder

### Frontend
- **Vue.js 3** - JavaScript Framework
- **Axios** - HTTP Client
- **Vue Router** - Client-side Routing
- **Vite** - Build Tool

### API Communication
- **RESTful API** - Architectural Style
- **JSON** - Data Format
- **HTTP POST** - Request Method

---

## Struktur Endpoint API

### POST /api/produk/list

**Request Body:**
```json
{
  "keyword": "string (optional)",
  "sort_by": "nama_produk|harga|stok (optional)",
  "sort_dir": "asc|desc (optional)",
  "start": "integer (required)",
  "limit": "integer (required)"
}
```

**Response:**
```json
{
  "count": 150,
  "produk": [
    {
      "id": 1,
      "nama_produk": "Laptop ASUS",
      "kategori": "Electronics",
      "harga": 8500000,
      "stok": 15,
      "created_at": "2025-11-01 10:30:00"
    }
  ]
}
```

---

## Flow Diagram

```
User Action (Search/Sort/Paginate)
           ↓
Vue Component detects change
           ↓
Axios POST → http://localhost:8000/api/produk/list
           ↓
Laravel Router → ProdukController@list
           ↓
Validate Request Parameters
           ↓
Build Query (Filter + Sort + Pagination)
           ↓
Execute Query → MySQL Database
           ↓
Return JSON Response
           ↓
Vue receives data → Update State
           ↓
Re-render Table & Pagination
```

---

**Dokumentasi ini menjelaskan arsitektur lengkap sistem Product List dengan filtering, sorting, dan pagination menggunakan Laravel dan Vue.js.**
