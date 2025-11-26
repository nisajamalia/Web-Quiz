# ⚡ Quick Start Guide - 5 Minutes to Running Application

## 🎯 Goal
Get the Product List application running in 5 minutes or less!

---

## ✅ Prerequisites Check (1 minute)

Open Command Prompt and verify:

```cmd
php --version
```
✅ Should show: PHP 8.1 or higher

```cmd
composer --version
```
✅ Should show: Composer 2.x

```cmd
node --version
```
✅ Should show: Node 16 or higher

```cmd
mysql --version
```
✅ Should show: MySQL 5.7 or higher

**If any are missing**: Stop and install them first!

---

## 🚀 Backend Setup (3 minutes)

### Step 1: Navigate to backend folder

```cmd
cd C:\Users\Nadhifa\Downloads\Website\backend
```

### Step 2: Install dependencies

```cmd
composer install
```

⏱️ **Wait time: ~1 minute**

### Step 3: Setup environment

```cmd
copy .env.example .env
php artisan key:generate
```

### Step 4: Configure database

Open `.env` file in notepad:

```cmd
notepad .env
```

Update these lines:
```env
DB_DATABASE=produk
DB_USERNAME=root
DB_PASSWORD=YOUR_MYSQL_PASSWORD
```

Save and close.

### Step 5: Create database

```cmd
mysql -u root -p -e "CREATE DATABASE produk;"
```

Enter your MySQL password when prompted.

### Step 6: Run migration

```cmd
php artisan migrate
```

### Step 7: Import sample data

```cmd
cd ..
mysql -u root -p produk < produk_database.sql
cd backend
```

Enter MySQL password again.

### Step 8: Start Laravel server

```cmd
php artisan serve
```

✅ **You should see**: `Server running on http://127.0.0.1:8000`

**Keep this terminal open!**

---

## 🎨 Frontend Setup (1 minute)

### Step 1: Open NEW terminal

Press `Win + R`, type `cmd`, press Enter

### Step 2: Navigate to frontend folder

```cmd
cd C:\Users\Nadhifa\Downloads\Website\frontend
```

### Step 3: Install dependencies

```cmd
npm install
```

⏱️ **Wait time: ~30 seconds**

### Step 4: Start dev server

```cmd
npm run dev
```

✅ **You should see**: `Local: http://localhost:3000/`

**Keep this terminal open too!**

---

## 🌐 Open Application (30 seconds)

1. Open your browser
2. Go to: `http://localhost:3000`

✅ **You should see**: Product List page with search, sort, and table!

---

## 🧪 Quick Test (30 seconds)

1. **Type "computer" in search box**
   - Wait 500ms
   - Table should filter

2. **Select "Price" from Sort By dropdown**
   - Table should reorder

3. **Click "Next" button**
   - Should go to page 2
   - Row numbers should be 11-20 (not 1-10!)

✅ **If all work**: SUCCESS! 🎉

---

## ❌ Troubleshooting

### Error: "Address already in use" (Backend)

**Solution**:
```cmd
php artisan serve --port=8001
```

Then update `frontend/src/views/ProdukView.vue`:
Change `http://localhost:8000` to `http://localhost:8001`

---

### Error: "Port 3000 is already in use" (Frontend)

**Solution**:
```cmd
npm run dev -- --port=3001
```

Then open: `http://localhost:3001`

---

### Error: "CORS policy blocked"

**Solution**:
```cmd
cd backend
composer require fruitcake/laravel-cors
php artisan serve
```

---

### Error: "Database connection failed"

**Solution**:

1. Check MySQL is running:
```cmd
mysql -u root -p
```

2. Verify database exists:
```sql
SHOW DATABASES;
```
Should see `produk` in list.

3. Check `.env` credentials match.

---

### Error: "Table not found"

**Solution**:
```cmd
cd backend
php artisan migrate:fresh
cd ..
mysql -u root -p produk < produk_database.sql
```

---

## 📊 What You Should See

### Browser (http://localhost:3000)

```
╔═══════════════════════════════════════════════════════╗
║                  Product List                         ║
╠═══════════════════════════════════════════════════════╣
║                                                       ║
║  Search: [____________________]                       ║
║  Sort By: [nama_produk ▼]  Order: [asc ▼]           ║
║                                                       ║
╠═══════════════════════════════════════════════════════╣
║ No │ Product          │ Category │ Price │ Stock │ Date║
║────┼──────────────────┼──────────┼───────┼───────┼────║
║  1 │ Product Name 1   │ Cat 1    │ 50000 │  10   │... ║
║  2 │ Product Name 2   │ Cat 2    │ 75000 │  15   │... ║
║  3 │ Product Name 3   │ Cat 3    │ 30000 │  20   │... ║
║ ...                                                    ║
╠═══════════════════════════════════════════════════════╣
║  Showing 1 to 10 of 100                              ║
║  [First] [Previous] [1] [2] [3] [Next] [Last]       ║
╚═══════════════════════════════════════════════════════╝
```

### Backend Terminal

```
INFO  Server running on [http://127.0.0.1:8000].

Press Ctrl+C to stop the server
```

### Frontend Terminal

```
VITE v4.4.9  ready in 500 ms

➜  Local:   http://localhost:3000/
➜  Network: use --host to expose
➜  press h to show help
```

---

## 🎯 Next Steps

### 1. Test Features

- [x] Search functionality
- [x] Sort by name, price, stock
- [x] Pagination
- [x] Row numbering continues across pages

### 2. Read Documentation

- **SUMMARY.md** - Quick overview
- **ARCHITECTURE.md** - How it works
- **TESTING.md** - Full test guide

### 3. Customize

- Add more products to database
- Modify table columns
- Add new features

---

## 📞 Need Help?

### Check These Files:

1. **README.md** - Complete setup guide
2. **TESTING.md** - Troubleshooting section
3. **INDEX.md** - Navigation hub

### Common Commands:

**Restart Backend**:
```cmd
# In backend terminal: Press Ctrl+C
php artisan serve
```

**Restart Frontend**:
```cmd
# In frontend terminal: Press Ctrl+C
npm run dev
```

**Clear Laravel Cache**:
```cmd
php artisan config:clear
php artisan route:clear
php artisan cache:clear
```

**Reinstall Frontend**:
```cmd
cd frontend
rd /s /q node_modules
npm install
```

---

## ⏱️ Time Breakdown

| Task | Time | Cumulative |
|------|------|------------|
| Prerequisites check | 1 min | 1 min |
| Backend install | 1 min | 2 min |
| Backend config | 30 sec | 2.5 min |
| Database setup | 30 sec | 3 min |
| Frontend install | 30 sec | 3.5 min |
| Frontend start | 10 sec | 3.6 min |
| Open browser | 10 sec | 3.7 min |
| Quick test | 30 sec | 4.2 min |

**Total: ~4-5 minutes** ✅

---

## 🎉 Success Checklist

- [ ] ✅ Backend terminal shows "Server running"
- [ ] ✅ Frontend terminal shows "Local: http://localhost:3000"
- [ ] ✅ Browser shows Product List page
- [ ] ✅ Search box exists
- [ ] ✅ Sort dropdowns exist
- [ ] ✅ Table shows products
- [ ] ✅ Pagination buttons exist
- [ ] ✅ Can navigate to page 2
- [ ] ✅ Row numbers are 11-20 on page 2
- [ ] ✅ No errors in browser console

**All checked?** YOU'RE DONE! 🎊

---

## 🚀 One-Liner Setup (Advanced)

For experienced users who have everything configured:

```cmd
cd backend && composer install && copy .env.example .env && php artisan key:generate && php artisan migrate && cd .. && mysql -u root -p produk < produk_database.sql && cd backend && start php artisan serve && cd ..\frontend && npm install && npm run dev
```

⚠️ **Note**: Still need to manually update `.env` and create database!

---

## 📱 Mobile Testing

After setup, test on mobile:

1. Find your local IP:
```cmd
ipconfig
```
Look for "IPv4 Address"

2. Update frontend axios URL in `ProdukView.vue`:
```javascript
axios.post('http://YOUR_IP:8000/api/produk/list', ...)
```

3. Access from phone:
```
http://YOUR_IP:3000
```

---

## 🎓 Learning Mode

Want to understand while you setup?

### Read comments in these files:

1. **ProdukController.php** - Backend logic explained
2. **ProdukView.vue** - Frontend component explained
3. **ARCHITECTURE.md** - Overall design explained

---

## ✅ Final Check

Both terminals running? ✅
Browser showing app? ✅
Features working? ✅

**CONGRATULATIONS! 🎉**

You've successfully set up a complete full-stack application!

---

**⏱️ Total Time: 5 minutes**
**Status: RUNNING** ✅

**Ready to explore!** Open `INDEX.md` for full documentation.
