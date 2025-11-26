## Product List Web App

Full‑stack product listing app built with **Laravel** (backend API) and **Vue 3 + Vite** (frontend).  
Features: search, sorting, pagination, and continuous row numbering.

---

### Project structure

```text
ProductList/
├── backend/      # Laravel API
├── frontend/     # Vue 3 app
├── produk_database.sql
└── docs: ARCHITECTURE.md, INDEX.md, QUICKSTART.md, ...
```

---

### Requirements

- PHP 8.1+, Composer  
- Node.js 16+, npm  
- MySQL server (running locally)  
- Git (optional)

Check quickly:

```bash
php --version
composer --version
node --version
npm --version
mysql --version
```

---

### 1. Backend setup (Laravel)

From the project root:

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
```

Edit `.env` and set your MySQL credentials:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=produk
DB_USERNAME=root      # or your user
DB_PASSWORD=          # password (leave empty if none)
```

Create the database and import data (from project root, adjust user/password if needed):

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS produk CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p produk < produk_database.sql
```

Run migrations (will be basically no‑op if table already exists with same schema):

```bash
cd backend
php artisan migrate
```

Start the Laravel dev server:

```bash
php artisan serve --host=localhost --port=8000
```

API base URL: **`http://localhost:8000`**

---

### 2. Frontend setup (Vue 3 + Vite)

In a new terminal, from project root:

```bash
cd frontend
npm install
npm run dev -- --port=3000
```

Frontend URL: **`http://localhost:3000`**

The Vite dev server is configured to proxy `/api` to Laravel (`http://localhost:8000`) via `vite.config.js`, and the Vue app calls the API using a relative URL (`/api/produk/list`).

Open the app in a browser: `http://localhost:3000`

---

### 3. API endpoints

Base URL for Postman / curl: `http://localhost:8000`

- **POST `/api/produk/list`** – main endpoint used by the frontend  
- **GET `/api/produk/list`** – same behavior, parameters via query string

#### POST example (JSON body)

```json
{
  "keyword": "",
  "sort_by": "",
  "sort_dir": "asc",
  "start": 0,
  "limit": 10
}
```

Typical response:

```json
{
  "count": 123,
  "produk": [
    {
      "id": 1,
      "nama_produk": "Product Name",
      "kategori": "Category",
      "harga": 125000,
      "stok": 10,
      "created_at": "2024-01-15T10:00:00.000000Z"
    }
  ]
}
```

#### GET example (query string)

```text
http://localhost:8000/api/produk/list?keyword=Programming&sort_by=harga&sort_dir=desc&start=0&limit=10
```

In Postman:

- Method: **GET**  
- URL: `http://localhost:8000/api/produk/list`  
- Tab **Params**: add `keyword`, `sort_by`, `sort_dir`, `start`, `limit`.

---

### 4. Using Postman (quick guide)

**POST request**

- Method: **POST**  
- URL: `http://localhost:8000/api/produk/list`  
- Headers: `Content-Type: application/json`  
- Body → raw → JSON:

```json
{
  "keyword": "",
  "sort_by": "",
  "sort_dir": "asc",
  "start": 0,
  "limit": 10
}
```

**GET request**

- Method: **GET**  
- URL + query:  
  `http://localhost:8000/api/produk/list?keyword=&sort_by=&sort_dir=asc&start=0&limit=10`

---

### 5. Common issues

- **Database connection error (SQLSTATE 1045/1049)**  
  - Check MySQL is running and that `.env` has correct `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`.  
  - Ensure database `produk` exists (`SHOW DATABASES;`).

- **Frontend shows no data**  
  - Verify Laravel server is running on port 8000.  
  - In browser DevTools → Network, confirm `/api/produk/list` returns status 200 with JSON.  
  - Check `backend/storage/logs/laravel.log` for backend errors.

---

### 6. Where to learn more

- `QUICKSTART.md` – very fast step‑by‑step setup  
- `ARCHITECTURE.md` – details about request flow and design  
- `INDEX.md` – index of all documentation files

This README is focused on the setup that you are actually using on macOS with MySQL and Postman.
