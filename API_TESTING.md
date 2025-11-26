# API Testing Guide

## Test API Endpoint menggunakan curl

### 1. Basic Request (No Filter)
```bash
curl -X POST http://localhost:8000/api/produk/list \
  -H "Content-Type: application/json" \
  -d '{
    "start": 0,
    "limit": 10
  }'
```

### 2. Search by Keyword
```bash
curl -X POST http://localhost:8000/api/produk/list \
  -H "Content-Type: application/json" \
  -d '{
    "keyword": "laptop",
    "start": 0,
    "limit": 10
  }'
```

### 3. Sort by Price (Ascending)
```bash
curl -X POST http://localhost:8000/api/produk/list \
  -H "Content-Type: application/json" \
  -d '{
    "sort_by": "harga",
    "sort_dir": "asc",
    "start": 0,
    "limit": 10
  }'
```

### 4. Sort by Stock (Descending)
```bash
curl -X POST http://localhost:8000/api/produk/list \
  -H "Content-Type: application/json" \
  -d '{
    "sort_by": "stok",
    "sort_dir": "desc",
    "start": 0,
    "limit": 10
  }'
```

### 5. Combined Filter + Sort + Pagination
```bash
curl -X POST http://localhost:8000/api/produk/list \
  -H "Content-Type: application/json" \
  -d '{
    "keyword": "elektronik",
    "sort_by": "nama_produk",
    "sort_dir": "asc",
    "start": 20,
    "limit": 10
  }'
```

### 6. Pagination (Page 2)
```bash
curl -X POST http://localhost:8000/api/produk/list \
  -H "Content-Type: application/json" \
  -d '{
    "start": 10,
    "limit": 10
  }'
```

## Expected Response Format

```json
{
  "count": 150,
  "produk": [
    {
      "id": 1,
      "nama_produk": "Laptop ASUS ROG",
      "kategori": "Electronics",
      "harga": 15000000,
      "stok": 5,
      "created_at": "2025-11-01 10:30:00"
    },
    {
      "id": 2,
      "nama_produk": "Mouse Gaming",
      "kategori": "Accessories",
      "harga": 250000,
      "stok": 50,
      "created_at": "2025-11-02 14:20:00"
    }
  ]
}
```

## Test dengan Postman

### Setup
1. Buka Postman
2. Create New Request
3. Method: **POST**
4. URL: `http://localhost:8000/api/produk/list`
5. Headers: `Content-Type: application/json`

### Body (raw JSON)
```json
{
  "keyword": "laptop",
  "sort_by": "harga",
  "sort_dir": "desc",
  "start": 0,
  "limit": 10
}
```

## Test Cases

### ✅ Test Case 1: Empty Keyword
- **Input**: `keyword: ""`
- **Expected**: Semua produk ditampilkan

### ✅ Test Case 2: Search "laptop"
- **Input**: `keyword: "laptop"`
- **Expected**: Hanya produk dengan nama/kategori mengandung "laptop"

### ✅ Test Case 3: Sort by Price ASC
- **Input**: `sort_by: "harga", sort_dir: "asc"`
- **Expected**: Produk terurut dari harga termurah

### ✅ Test Case 4: Sort by Price DESC
- **Input**: `sort_by: "harga", sort_dir: "desc"`
- **Expected**: Produk terurut dari harga termahal

### ✅ Test Case 5: Sort by Stock
- **Input**: `sort_by: "stok", sort_dir: "desc"`
- **Expected**: Produk terurut dari stok terbanyak

### ✅ Test Case 6: Pagination Page 1
- **Input**: `start: 0, limit: 10`
- **Expected**: Data produk 1-10

### ✅ Test Case 7: Pagination Page 2
- **Input**: `start: 10, limit: 10`
- **Expected**: Data produk 11-20

### ✅ Test Case 8: Search + Sort + Pagination
- **Input**: All parameters combined
- **Expected**: Filtered, sorted, dan paginated data

## Validation Tests

### ❌ Invalid sort_by
```json
{
  "sort_by": "invalid_field",
  "start": 0,
  "limit": 10
}
```
**Expected**: Validation error

### ❌ Invalid sort_dir
```json
{
  "sort_dir": "invalid_direction",
  "start": 0,
  "limit": 10
}
```
**Expected**: Validation error

### ❌ Negative start
```json
{
  "start": -1,
  "limit": 10
}
```
**Expected**: Validation error

### ❌ Limit too large
```json
{
  "start": 0,
  "limit": 1000
}
```
**Expected**: Validation error (max 100)

## Performance Test

Test dengan large dataset:
```bash
# Request dengan limit maksimal
curl -X POST http://localhost:8000/api/produk/list \
  -H "Content-Type: application/json" \
  -d '{
    "start": 0,
    "limit": 100
  }' \
  -w "\nTime: %{time_total}s\n"
```

## Frontend Integration Test

1. Buka browser: http://localhost:5173
2. Buka Developer Console (F12)
3. Go to Network tab
4. Test setiap interaction:
   - Type in search box → Check XHR request
   - Change sorting → Check XHR request
   - Click pagination → Check XHR request
5. Verify request payload dan response

---

**Note**: Pastikan backend Laravel sudah running di `http://localhost:8000`
