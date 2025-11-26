# Product List Application - Complete Setup Guide

## Project Structure
```
Website/
├── backend/           # Laravel API
│   ├── app/
│   ├── database/
│   ├── routes/
│   └── ...
├── frontend/          # Vue.js Application
│   ├── src/
│   ├── package.json
│   └── ...
├── ARCHITECTURE.md    # Architecture documentation
└── README.md          # This file
```

---

## Prerequisites

Before starting, ensure you have the following installed:

- **PHP 8.1+** with extensions: mbstring, xml, pdo, mysql
- **Composer** (PHP package manager)
- **Node.js 16+** and **npm**
- **MySQL 5.7+** or **MariaDB**
- **Git** (optional)

### Verify Installations

```cmd
php --version
composer --version
node --version
npm --version
mysql --version
```

---

## Part A: Backend Setup (Laravel)

### Step 1: Install Laravel Dependencies

Navigate to the backend directory and install dependencies:

```cmd
cd backend
composer install
```

### Step 2: Configure Environment

Create a `.env` file from the example:

```cmd
copy .env.example .env
```

Generate application key:

```cmd
php artisan key:generate
```

### Step 3: Configure Database

Open `.env` file and update database credentials:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=produk
DB_USERNAME=root
DB_PASSWORD=your_password_here
```

### Step 4: Create Database

Open MySQL command line or phpMyAdmin and create the database:

```sql
CREATE DATABASE produk CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Or use command line:

```cmd
mysql -u root -p -e "CREATE DATABASE produk;"
```

### Step 5: Run Migrations

Execute the migration to create the `produk` table:

```cmd
php artisan migrate
```

### Step 6: Import Sample Data

You have two options to populate the database:

**Option A: Using Laravel Seeder**

```cmd
php artisan db:seed --class=ProdukSeeder
```

**Option B: Import SQL Directly**

Create a file `buku_data.sql` with your provided SQL data and import:

```cmd
mysql -u root -p produk < buku_data.sql
```

Or manually run the INSERT statements in your MySQL client.

### Step 7: Configure CORS

Install CORS package (if not already installed):

```cmd
composer require fruitcake/laravel-cors
```

Open `config/cors.php` and ensure these settings:

```php
'paths' => ['api/*'],
'allowed_origins' => ['http://localhost:3000'],
'allowed_methods' => ['*'],
'allowed_headers' => ['*'],
```

### Step 8: Start Laravel Development Server

```cmd
php artisan serve
```

The API will be available at: `http://localhost:8000`

### Step 9: Test the API

Test the endpoint using curl or Postman:

```cmd
curl -X POST http://localhost:8000/api/produk/list -H "Content-Type: application/json" -d "{\"start\": 0, \"limit\": 10}"
```

Expected response:
```json
{
  "count": 500,
  "produk": [...]
}
```

---

## Part B: Frontend Setup (Vue.js)

### Step 1: Install Node Dependencies

Navigate to the frontend directory:

```cmd
cd ..\frontend
npm install
```

This will install:
- Vue 3
- Vue Router
- Axios
- Vite

### Step 2: Configure API Endpoint

The API endpoint is already configured in `ProdukView.vue`:

```javascript
axios.post('http://localhost:8000/api/produk/list', {
  // request data
})
```

If your Laravel API runs on a different port, update this URL.

### Step 3: Start Development Server

```cmd
npm run dev
```

The application will be available at: `http://localhost:3000`

### Step 4: Access the Application

Open your browser and navigate to:

```
http://localhost:3000
```

You should see the Product List interface with:
- Search box
- Sort controls
- Product table
- Pagination

---

## Part C: Testing the Application

### Test Search Functionality

1. Type a keyword in the search box (e.g., "computer")
2. Wait 500ms (debounce delay)
3. Table should update with filtered results

### Test Sorting

1. Select "Price" from Sort By dropdown
2. Select "Descending" from Order dropdown
3. Table should reorder by price (highest first)

### Test Pagination

1. Click "Next" button
2. Row numbers should continue (e.g., 11-20 on page 2)
3. Navigate using page numbers or First/Last buttons

### Test Continuous Row Numbering

Verify that:
- Page 1: Rows 1-10
- Page 2: Rows 11-20
- Page 3: Rows 21-30

Numbers should never reset to 1 on new pages.

---

## Part D: Common Issues & Solutions

### Issue 1: CORS Error

**Error**: "Access to XMLHttpRequest has been blocked by CORS policy"

**Solution**:
1. Ensure `fruitcake/laravel-cors` is installed
2. Check `config/cors.php` includes your frontend URL
3. Restart Laravel server

### Issue 2: Database Connection Failed

**Error**: "SQLSTATE[HY000] [2002] No connection could be made"

**Solution**:
1. Verify MySQL is running: `mysql -u root -p`
2. Check `.env` credentials match your MySQL setup
3. Ensure database `produk` exists

### Issue 3: 404 Not Found on API

**Error**: "POST http://localhost:8000/api/produk/list 404"

**Solution**:
1. Verify `routes/api.php` has the route defined
2. Check Laravel server is running on port 8000
3. Clear route cache: `php artisan route:clear`

### Issue 4: Blank Page in Vue

**Error**: Nothing displays in browser

**Solution**:
1. Check browser console for JavaScript errors
2. Verify Vite dev server is running
3. Check `http://localhost:3000` in browser console

### Issue 5: Port Already in Use

**Error**: "Port 8000 is already in use"

**Solution**:
```cmd
# For Laravel (use different port)
php artisan serve --port=8001

# For Vue (update vite.config.js or use different port)
npm run dev -- --port 3001
```

---

## Part E: Production Build

### Build Frontend for Production

```cmd
cd frontend
npm run build
```

This creates optimized files in `frontend/dist/`

### Configure Laravel for Production

```cmd
cd backend
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

Set `.env`:
```env
APP_ENV=production
APP_DEBUG=false
```

---

## Part F: Project File Structure

### Backend Files Created

```
backend/
├── app/
│   ├── Http/
│   │   └── Controllers/
│   │       └── ProdukController.php
│   └── Models/
│       └── Produk.php
├── database/
│   ├── migrations/
│   │   └── 2025_11_26_000001_create_produk_table.php
│   └── seeders/
│       └── ProdukSeeder.php
├── routes/
│   └── api.php
└── .env.example
```

### Frontend Files Created

```
frontend/
├── src/
│   ├── views/
│   │   └── ProdukView.vue
│   ├── App.vue
│   └── main.js
├── index.html
├── package.json
└── vite.config.js
```

---

## Part G: API Endpoint Specification

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

**Response (Success - 200):**
```json
{
  "count": 500,
  "produk": [
    {
      "id": 1,
      "nama_produk": "Product Name",
      "kategori": "Category",
      "harga": 50000,
      "stok": 25,
      "created_at": "2025-11-20 10:00:00"
    }
  ]
}
```

**Response (Error - 422):**
```json
{
  "error": "Validation failed",
  "messages": {
    "start": ["The start field is required."]
  }
}
```

---

## Part H: Development Tips

### Running Both Servers Simultaneously

**Terminal 1 (Backend):**
```cmd
cd backend
php artisan serve
```

**Terminal 2 (Frontend):**
```cmd
cd frontend
npm run dev
```

### Watching Laravel Logs

```cmd
cd backend
php artisan tail
```

Or check `storage/logs/laravel.log`

### Vue DevTools

Install Vue DevTools browser extension for debugging:
- Chrome: https://chrome.google.com/webstore (search "Vue.js devtools")
- Firefox: https://addons.mozilla.org/firefox (search "Vue.js devtools")

### Database Management

**View all products:**
```cmd
mysql -u root -p produk -e "SELECT * FROM produk LIMIT 10;"
```

**Count total products:**
```cmd
mysql -u root -p produk -e "SELECT COUNT(*) FROM produk;"
```

---

## Part I: Quick Start Summary

For experienced developers, here's the quick start:

```cmd
# Backend
cd backend
composer install
copy .env.example .env
php artisan key:generate
# Update .env with database credentials
mysql -u root -p -e "CREATE DATABASE produk;"
php artisan migrate
php artisan db:seed --class=ProdukSeeder
php artisan serve

# Frontend (new terminal)
cd frontend
npm install
npm run dev
```

Access: `http://localhost:3000`

---

## Part J: Additional Resources

- **Laravel Documentation**: https://laravel.com/docs
- **Vue.js Guide**: https://vuejs.org/guide
- **Axios Documentation**: https://axios-http.com/docs
- **Vite Guide**: https://vitejs.dev/guide

---

## Support

If you encounter issues:

1. Check `storage/logs/laravel.log` for backend errors
2. Check browser console for frontend errors
3. Verify all prerequisites are installed
4. Ensure ports 8000 and 3000 are available
5. Review ARCHITECTURE.md for system design details

---

**Project Complete! You now have a fully functional Product List application with filtering, sorting, and pagination.**
