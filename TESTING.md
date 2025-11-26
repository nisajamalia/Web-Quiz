# Product List Application - Testing & Validation Guide

## 📋 Complete Testing Checklist

This guide helps you verify that all requirements are properly implemented.

---

## ✅ A. Backend Requirements Testing (40%)

### 1. API Endpoint Configuration

**Test: Verify API route exists**

```cmd
cd backend
php artisan route:list --path=produk
```

Expected output should show:
```
POST | api/produk/list | App\Http\Controllers\ProdukController@list
```

✅ **Pass if**: Route is listed with POST method

---

### 2. Request Parameter Validation

**Test: Send request with missing required parameters**

```cmd
curl -X POST http://localhost:8000/api/produk/list ^
  -H "Content-Type: application/json" ^
  -d "{}"
```

Expected response:
```json
{
  "error": "Validation failed",
  "messages": {
    "start": ["The start field is required."],
    "limit": ["The limit field is required."]
  }
}
```

✅ **Pass if**: Returns 422 status with validation errors

---

### 3. Keyword Filtering

**Test: Search for "computer"**

```cmd
curl -X POST http://localhost:8000/api/produk/list ^
  -H "Content-Type: application/json" ^
  -d "{\"keyword\":\"computer\",\"start\":0,\"limit\":10}"
```

✅ **Pass if**: 
- Returns products containing "computer" in `nama_produk` OR `kategori`
- `count` reflects filtered total
- `produk` array has max 10 items

---

### 4. Sorting Functionality

**Test: Sort by price descending**

```cmd
curl -X POST http://localhost:8000/api/produk/list ^
  -H "Content-Type: application/json" ^
  -d "{\"sort_by\":\"harga\",\"sort_dir\":\"desc\",\"start\":0,\"limit\":5}"
```

✅ **Pass if**: 
- Products are ordered by highest price first
- First item has higher `harga` than last item

---

### 5. Pagination Logic

**Test: Get page 2 (offset 10, limit 10)**

```cmd
curl -X POST http://localhost:8000/api/produk/list ^
  -H "Content-Type: application/json" ^
  -d "{\"start\":10,\"limit\":10}"
```

**Test: Get page 3 (offset 20, limit 10)**

```cmd
curl -X POST http://localhost:8000/api/produk/list ^
  -H "Content-Type: application/json" ^
  -d "{\"start\":20,\"limit\":10}"
```

✅ **Pass if**: 
- Each request returns different 10 products
- Total `count` is the same in both responses
- Products don't overlap between pages

---

### 6. Response Format

**Test: Verify JSON structure**

```cmd
curl -X POST http://localhost:8000/api/produk/list ^
  -H "Content-Type: application/json" ^
  -d "{\"start\":0,\"limit\":1}"
```

Expected structure:
```json
{
  "count": <number>,
  "produk": [
    {
      "id": <number>,
      "nama_produk": "<string>",
      "kategori": "<string>",
      "harga": <number>,
      "stok": <number>,
      "created_at": "YYYY-MM-DD HH:MM:SS"
    }
  ]
}
```

✅ **Pass if**: All fields present with correct types

---

## ✅ B. Frontend Requirements Testing (40%)

### 1. Component Existence

**Test: Check file exists**

```cmd
dir frontend\src\views\ProdukView.vue
```

✅ **Pass if**: File exists and is named exactly `ProdukView.vue`

---

### 2. Search Functionality

**Manual Test Steps:**

1. Open `http://localhost:3000`
2. Type "programming" in search box
3. Wait 500ms (debounce)
4. Observe table updates

✅ **Pass if**: 
- Table shows only products matching "programming"
- Page resets to 1
- Total count updates
- Typing doesn't trigger immediate API call

---

### 3. Sorting Controls

**Manual Test Steps:**

1. Open browser DevTools → Network tab
2. Select "Price" from "Sort By" dropdown
3. Select "Descending" from "Order" dropdown
4. Observe network request

✅ **Pass if**: 
- Request sent with `sort_by: "harga"` and `sort_dir: "desc"`
- Table updates with highest price first
- Page resets to 1

---

### 4. Continuous Row Numbering

**Manual Test Steps:**

1. Open `http://localhost:3000`
2. Note row numbers on page 1 (should be 1-10)
3. Click "Next" to go to page 2
4. Note row numbers (should be 11-20)
5. Navigate to page 3
6. Note row numbers (should be 21-30)
7. Go back to page 2
8. Verify row numbers are still 11-20

✅ **Pass if**: 
- Page 1: Rows 1-10
- Page 2: Rows 11-20
- Page 3: Rows 21-30
- Numbers never reset to 1 on new pages
- Numbers consistent when navigating back

---

### 5. Pagination Controls

**Manual Test Steps:**

1. Click "First" button → Should go to page 1
2. Click "Next" button → Should increment page
3. Click "Previous" button → Should decrement page
4. Click "Last" button → Should go to last page
5. Click page number directly → Should jump to that page
6. Try clicking "Previous" on page 1 → Should be disabled
7. Try clicking "Next" on last page → Should be disabled

✅ **Pass if**: All navigation works correctly

---

### 6. Table Display

**Manual Test Steps:**

1. Verify table has these columns in order:
   - No
   - Product (Produk)
   - Category (Kategori)
   - Price (Harga)
   - Stock (Stok)
   - Created at

2. Verify data is displayed correctly:
   - Numbers are formatted (e.g., Rp 250.000)
   - Dates are readable
   - No undefined/null values

✅ **Pass if**: All columns display correctly

---

### 7. State Management

**Developer Test: Check Vue DevTools**

1. Install Vue DevTools extension
2. Open DevTools → Vue tab
3. Select ProdukView component
4. Observe data properties:
   - keyword
   - sortBy
   - sortDir
   - currentPage
   - limit
   - produk
   - totalCount

✅ **Pass if**: All reactive properties exist and update on user actions

---

### 8. Axios Integration

**Test: Check network requests**

1. Open DevTools → Network tab
2. Perform a search
3. Inspect the request to `/api/produk/list`

Verify request payload:
```json
{
  "keyword": "...",
  "sort_by": "...",
  "sort_dir": "...",
  "start": <number>,
  "limit": 10
}
```

✅ **Pass if**: Request format matches specification

---

## ✅ C. Architecture Documentation Testing (20%)

### 1. Request-Response Flow Section

**Check: ARCHITECTURE.md contains detailed explanation**

Open `ARCHITECTURE.md` and verify section "1. Request-Response Flow" includes:

- How Vue component sends POST request via Axios
- How Laravel API receives, processes, and returns JSON
- How Vue updates UI based on response

✅ **Pass if**: 3-5 paragraphs explaining complete flow

---

### 2. Backend Handling Section

**Check: ARCHITECTURE.md contains implementation details**

Verify section "2. Backend Handling" includes:

- Filtering uses `LIKE %keyword%` on nama_produk AND kategori
- Sorting applies `orderBy(sort_by, sort_dir)`
- Pagination uses `offset(start)->limit(limit)`
- Count calculated after filter, before limit

✅ **Pass if**: 3-5 paragraphs with technical details

---

### 3. Frontend State & Row Numbering Section

**Check: ARCHITECTURE.md contains formula explanation**

Verify section "3. Frontend State & Row Numbering" includes:

- Frontend stores user inputs
- currentPage controls pagination offset
- Row number formula: `(currentPage - 1) * limit + index + 1`
- Examples showing continuous numbering

✅ **Pass if**: 3-5 paragraphs with formula and examples

---

## ✅ D. Integration Testing

### Test 1: Complete User Flow

**Scenario: Search, sort, and paginate**

1. Open `http://localhost:3000`
2. Search for "computer"
3. Sort by price (descending)
4. Navigate to page 2
5. Verify rows show 11-20
6. Change sort to ascending
7. Verify page resets to 1 and data reorders

✅ **Pass if**: All steps work seamlessly without errors

---

### Test 2: Empty Search Results

**Scenario: Search for non-existent keyword**

1. Search for "xyz123abc"
2. Observe result

✅ **Pass if**: 
- Table shows "No products found" message
- Pagination hidden
- No JavaScript errors

---

### Test 3: Rapid Input Changes

**Scenario: Test debounce**

1. Rapidly type "comp" in search box (don't pause)
2. Observe Network tab

✅ **Pass if**: 
- Only ONE API request sent (after 500ms of inactivity)
- Not multiple requests for each keystroke

---

### Test 4: Large Dataset Performance

**Scenario: Handle many results**

1. Clear search (show all products)
2. Navigate through multiple pages
3. Observe loading times

✅ **Pass if**: 
- Page loads remain fast (< 1 second)
- No UI freezing
- Smooth pagination

---

## ✅ E. Code Quality Checks

### 1. Backend Code Quality

**Check: ProdukController.php**

- [ ] Has input validation
- [ ] Uses try-catch for error handling
- [ ] Returns consistent JSON format
- [ ] Comments explain logic
- [ ] No hardcoded values
- [ ] Uses Eloquent query builder

---

### 2. Frontend Code Quality

**Check: ProdukView.vue**

- [ ] Component is properly structured (template, script, style)
- [ ] Uses reactive data properties
- [ ] Methods are clearly named
- [ ] Has computed properties for calculations
- [ ] Implements debounce for search
- [ ] Comments explain complex logic
- [ ] Scoped CSS prevents style leaks

---

### 3. Security Checks

- [ ] Laravel uses parameterized queries (prevents SQL injection)
- [ ] Input validation on backend
- [ ] No sensitive data exposed in API
- [ ] CORS properly configured
- [ ] No eval() or dangerous functions

---

## ✅ F. Browser Compatibility Testing

Test in multiple browsers:

| Browser | Version | Status |
|---------|---------|--------|
| Chrome | Latest | ⬜ |
| Firefox | Latest | ⬜ |
| Edge | Latest | ⬜ |
| Safari | Latest | ⬜ |

✅ **Pass if**: Works in all modern browsers

---

## ✅ G. Responsive Design Testing

Test on different screen sizes:

1. Desktop (1920x1080)
2. Laptop (1366x768)
3. Tablet (768x1024)
4. Mobile (375x667)

✅ **Pass if**: 
- Layout adapts gracefully
- No horizontal scrolling
- All controls remain accessible
- Table is readable on mobile

---

## ✅ H. Performance Testing

### Metric 1: API Response Time

```cmd
curl -w "Time: %{time_total}s\n" ^
  -X POST http://localhost:8000/api/produk/list ^
  -H "Content-Type: application/json" ^
  -d "{\"start\":0,\"limit\":10}"
```

✅ **Pass if**: Response time < 500ms

---

### Metric 2: Frontend Initial Load

Open DevTools → Performance tab
Record page load

✅ **Pass if**: 
- Time to Interactive < 3 seconds
- No excessive JavaScript execution

---

## ✅ I. Documentation Completeness

Check all files exist:

- [ ] `backend/app/Models/Produk.php`
- [ ] `backend/app/Http/Controllers/ProdukController.php`
- [ ] `backend/database/migrations/*_create_produk_table.php`
- [ ] `backend/routes/api.php`
- [ ] `frontend/src/views/ProdukView.vue`
- [ ] `ARCHITECTURE.md`
- [ ] `README.md`
- [ ] `SUMMARY.md`
- [ ] `DIAGRAM.md`

---

## 📊 Final Checklist

### Backend (40%)
- [ ] ✅ Migration creates correct schema
- [ ] ✅ Model properly configured
- [ ] ✅ Controller handles all parameters
- [ ] ✅ Filtering works correctly
- [ ] ✅ Sorting works for all fields
- [ ] ✅ Pagination uses offset/limit
- [ ] ✅ Count calculated correctly
- [ ] ✅ JSON response format correct

### Frontend (40%)
- [ ] ✅ ProdukView.vue exists
- [ ] ✅ Search with debounce works
- [ ] ✅ Sort controls functional
- [ ] ✅ Table displays correctly
- [ ] ✅ Pagination controls work
- [ ] ✅ Row numbering continuous
- [ ] ✅ Axios integration correct
- [ ] ✅ Responsive design

### Architecture (20%)
- [ ] ✅ Request-Response Flow (3-5 paragraphs)
- [ ] ✅ Backend Handling (3-5 paragraphs)
- [ ] ✅ Frontend State & Row Numbering (3-5 paragraphs)

---

## 🎯 Test Results Summary

**Date**: ___________

**Tester**: ___________

**Overall Score**: _____ / 100%

| Category | Score | Notes |
|----------|-------|-------|
| Backend | ___ /40 | |
| Frontend | ___ /40 | |
| Architecture | ___ /20 | |

---

## 🐛 Common Issues & Debugging

### Issue: API returns 404

**Debug Steps:**
```cmd
cd backend
php artisan route:clear
php artisan route:cache
php artisan serve
```

---

### Issue: CORS error

**Debug Steps:**
Check `backend/config/cors.php`:
```php
'allowed_origins' => ['http://localhost:3000'],
```

---

### Issue: Database connection failed

**Debug Steps:**
```cmd
cd backend
php artisan config:clear
# Update .env with correct credentials
php artisan migrate
```

---

### Issue: Frontend not updating

**Debug Steps:**
1. Open Browser Console
2. Check for JavaScript errors
3. Verify API endpoint URL
4. Check Network tab for failed requests

---

## ✅ Acceptance Criteria

Project is complete when:

1. ✅ Backend API responds correctly to all parameter combinations
2. ✅ Frontend displays products with proper filtering/sorting
3. ✅ Pagination maintains continuous row numbers
4. ✅ Architecture documentation is comprehensive
5. ✅ Setup instructions work for a fresh install
6. ✅ No console errors in browser
7. ✅ No PHP errors in Laravel logs
8. ✅ Code is clean and well-commented

---

**Testing Complete!** 🎉

If all checks pass, the project meets all requirements and is ready for deployment.
