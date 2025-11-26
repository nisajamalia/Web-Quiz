# Product List Application - System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          USER BROWSER                                    │
│                      http://localhost:3000                              │
└──────────────────────────────┬──────────────────────────────────────────┘
                               │
                               │ User Interaction
                               │ (Search, Sort, Paginate)
                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     VUE.JS FRONTEND (Port 3000)                         │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │                    ProdukView.vue                              │    │
│  ├────────────────────────────────────────────────────────────────┤    │
│  │  Reactive State:                                               │    │
│  │  • keyword (search term)                                       │    │
│  │  • sortBy (nama_produk | harga | stok)                         │    │
│  │  • sortDir (asc | desc)                                        │    │
│  │  • currentPage (1, 2, 3, ...)                                  │    │
│  │  • limit (10 items per page)                                   │    │
│  │  • produk[] (product array)                                    │    │
│  │  • totalCount (filtered count)                                 │    │
│  ├────────────────────────────────────────────────────────────────┤    │
│  │  UI Components:                                                │    │
│  │  • Search Input (debounced 500ms)                              │    │
│  │  • Sort Dropdowns                                              │    │
│  │  • Product Table                                               │    │
│  │  • Pagination Controls                                         │    │
│  └─────────────────┬──────────────────────────────────────────────┘    │
│                    │                                                    │
│                    │ Axios.post()                                       │
│                    │ Request Payload:                                   │
│                    │ {                                                  │
│                    │   keyword, sort_by, sort_dir,                      │
│                    │   start: (page-1)*limit,                           │
│                    │   limit: 10                                        │
│                    │ }                                                  │
└────────────────────┼────────────────────────────────────────────────────┘
                     │
                     │ HTTP POST
                     │ http://localhost:8000/api/produk/list
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                   LARAVEL BACKEND (Port 8000)                           │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │                     routes/api.php                             │    │
│  │  Route::post('/produk/list', [ProdukController, 'list'])       │    │
│  └─────────────────┬──────────────────────────────────────────────┘    │
│                    │                                                    │
│                    ▼                                                    │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │            ProdukController@list                               │    │
│  ├────────────────────────────────────────────────────────────────┤    │
│  │  1. Validate Request:                                          │    │
│  │     • keyword: nullable|string                                 │    │
│  │     • sort_by: in:nama_produk,harga,stok                       │    │
│  │     • sort_dir: in:asc,desc                                    │    │
│  │     • start: required|integer                                  │    │
│  │     • limit: required|integer                                  │    │
│  │                                                                │    │
│  │  2. Build Query:                                               │    │
│  │     $query = Produk::query();                                  │    │
│  │                                                                │    │
│  │  3. Apply Filtering (if keyword exists):                       │    │
│  │     WHERE (nama_produk LIKE %keyword%                          │    │
│  │            OR kategori LIKE %keyword%)                         │    │
│  │                                                                │    │
│  │  4. Count Total:                                               │    │
│  │     $count = $query->count();                                  │    │
│  │                                                                │    │
│  │  5. Apply Sorting:                                             │    │
│  │     ORDER BY sort_by sort_dir                                  │    │
│  │                                                                │    │
│  │  6. Apply Pagination:                                          │    │
│  │     OFFSET start LIMIT limit                                   │    │
│  │                                                                │    │
│  │  7. Return JSON:                                               │    │
│  │     {                                                          │    │
│  │       "count": 150,                                            │    │
│  │       "produk": [...]                                          │    │
│  │     }                                                          │    │
│  └─────────────────┬──────────────────────────────────────────────┘    │
│                    │                                                    │
│                    ▼                                                    │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │                    Produk Model                                │    │
│  │  • Table: produk                                               │    │
│  │  • Eloquent ORM                                                │    │
│  └─────────────────┬──────────────────────────────────────────────┘    │
└────────────────────┼────────────────────────────────────────────────────┘
                     │
                     │ SQL Query
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        MySQL DATABASE                                   │
├─────────────────────────────────────────────────────────────────────────┤
│  Database: produk                                                       │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │  Table: produk                                                 │    │
│  ├────────────────────────────────────────────────────────────────┤    │
│  │  Columns:                                                      │    │
│  │  • id (INT, PRIMARY KEY, AUTO_INCREMENT)                       │    │
│  │  • nama_produk (VARCHAR 100)                                   │    │
│  │  • kategori (VARCHAR 100)                                      │    │
│  │  • harga (INT)                                                 │    │
│  │  • stok (INT)                                                  │    │
│  │  • created_at (TIMESTAMP)                                      │    │
│  │                                                                │    │
│  │  Sample Data: ~100 product records                             │    │
│  └────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════
                         DATA FLOW DIAGRAM
═══════════════════════════════════════════════════════════════════════════

USER TYPES "computer" IN SEARCH BOX
  │
  ├──→ Vue detects input change
  │
  ├──→ Debounce timer starts (500ms)
  │
  ├──→ After 500ms: fetchProduk() called
  │
  ├──→ Axios.post() sends request:
  │     {
  │       keyword: "computer",
  │       sort_by: "harga",
  │       sort_dir: "asc",
  │       start: 0,
  │       limit: 10
  │     }
  │
  ├──→ Laravel validates input
  │
  ├──→ Builds SQL query:
  │     SELECT * FROM produk
  │     WHERE (nama_produk LIKE '%computer%'
  │            OR kategori LIKE '%computer%')
  │     ORDER BY harga ASC
  │     LIMIT 10 OFFSET 0
  │
  ├──→ MySQL executes query, returns 10 records
  │
  ├──→ Laravel counts total matches (e.g., 45)
  │
  ├──→ Laravel returns JSON:
  │     {
  │       "count": 45,
  │       "produk": [10 product objects]
  │     }
  │
  ├──→ Vue receives response
  │
  ├──→ Updates reactive data:
  │     • produk = [10 items]
  │     • totalCount = 45
  │     • totalPages = Math.ceil(45/10) = 5
  │
  └──→ Vue re-renders table with new data


═══════════════════════════════════════════════════════════════════════════
                    ROW NUMBERING CALCULATION
═══════════════════════════════════════════════════════════════════════════

Formula: getRowNumber(index) = (currentPage - 1) × limit + index + 1

Examples:

PAGE 1 (currentPage = 1, limit = 10)
  Index 0: (1-1) × 10 + 0 + 1 = 1   ← Row 1
  Index 1: (1-1) × 10 + 1 + 1 = 2   ← Row 2
  ...
  Index 9: (1-1) × 10 + 9 + 1 = 10  ← Row 10

PAGE 2 (currentPage = 2, limit = 10)
  Index 0: (2-1) × 10 + 0 + 1 = 11  ← Row 11
  Index 1: (2-1) × 10 + 1 + 1 = 12  ← Row 12
  ...
  Index 9: (2-1) × 10 + 9 + 1 = 20  ← Row 20

PAGE 3 (currentPage = 3, limit = 10)
  Index 0: (3-1) × 10 + 0 + 1 = 21  ← Row 21
  Index 5: (3-1) × 10 + 5 + 1 = 26  ← Row 26
  ...
  Index 9: (3-1) × 10 + 9 + 1 = 30  ← Row 30


═══════════════════════════════════════════════════════════════════════════
                      TECHNOLOGY STACK
═══════════════════════════════════════════════════════════════════════════

┌─────────────────┐
│   Vue.js 3.3+   │  → Reactive UI, Component-based
└────────┬────────┘
         │
         ├──→ Vue Router 4.2+  → Client-side routing
         │
         └──→ Axios 1.5+       → HTTP requests

┌─────────────────┐
│   Laravel 10+   │  → REST API, MVC architecture
└────────┬────────┘
         │
         ├──→ Eloquent ORM     → Database abstraction
         │
         └──→ Validation       → Input security

┌─────────────────┐
│   MySQL 8.0+    │  → Relational database
└─────────────────┘

┌─────────────────┐
│   Vite 4.4+     │  → Fast build tool & dev server
└─────────────────┘


═══════════════════════════════════════════════════════════════════════════
                         FILE ORGANIZATION
═══════════════════════════════════════════════════════════════════════════

Website/
│
├── backend/                    # Laravel API
│   ├── app/
│   │   ├── Http/Controllers/
│   │   │   └── ProdukController.php     ← API logic
│   │   └── Models/
│   │       └── Produk.php               ← Database model
│   ├── database/
│   │   ├── migrations/
│   │   │   └── create_produk_table.php  ← Schema
│   │   └── seeders/
│   │       └── ProdukSeeder.php         ← Sample data
│   └── routes/
│       └── api.php                      ← Endpoint definition
│
├── frontend/                   # Vue.js App
│   ├── src/
│   │   ├── views/
│   │   │   └── ProdukView.vue           ← Main component
│   │   ├── App.vue                      ← Root component
│   │   └── main.js                      ← Entry point
│   ├── package.json                     ← Dependencies
│   └── vite.config.js                   ← Build config
│
├── ARCHITECTURE.md             ← System design docs (20%)
├── README.md                   ← Setup instructions
├── SUMMARY.md                  ← Quick reference
├── DIAGRAM.md                  ← This file
└── produk_database.sql         ← Database import


═══════════════════════════════════════════════════════════════════════════
                    API REQUEST/RESPONSE EXAMPLES
═══════════════════════════════════════════════════════════════════════════

REQUEST (Search "computer", Sort by price asc, Page 2):
---------------------------------------------------------------
POST http://localhost:8000/api/produk/list
Content-Type: application/json

{
  "keyword": "computer",
  "sort_by": "harga",
  "sort_dir": "asc",
  "start": 10,
  "limit": 10
}

RESPONSE (Success):
---------------------------------------------------------------
HTTP/1.1 200 OK
Content-Type: application/json

{
  "count": 45,
  "produk": [
    {
      "id": 21,
      "nama_produk": "Computer Security",
      "kategori": "Security",
      "harga": 275000,
      "stok": 18,
      "created_at": "2024-05-12 16:45:00"
    },
    ...9 more items
  ]
}

RESPONSE (Validation Error):
---------------------------------------------------------------
HTTP/1.1 422 Unprocessable Entity
Content-Type: application/json

{
  "error": "Validation failed",
  "messages": {
    "start": ["The start field is required."],
    "sort_by": ["The selected sort by is invalid."]
  }
}


═══════════════════════════════════════════════════════════════════════════
                         END OF DIAGRAM
═══════════════════════════════════════════════════════════════════════════
```
