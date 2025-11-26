# Product List Feature - Architecture Documentation

## Overview
This full-stack application implements a Product List Feature with Filtering, Sorting, and Pagination using Laravel (Backend API) and Vue.js (Frontend). The system allows users to search products, sort by multiple fields, and navigate through paginated results with continuous row numbering.

---

## 1. Request-Response Flow

### Complete Communication Cycle

The application follows a client-server architecture where the Vue.js frontend communicates with the Laravel backend through HTTP POST requests:

1. **User Interaction**: When a user performs any action (search, sort, or page change), the Vue component captures the event and updates its reactive state (`keyword`, `sortBy`, `sortDir`, `currentPage`).

2. **API Request**: The Vue component triggers the `fetchProduk()` method which uses Axios to send a POST request to `http://localhost:8000/api/produk/list`. The request payload includes:
   - `keyword`: Search term for filtering
   - `sort_by`: Field name for sorting (nama_produk, harga, or stok)
   - `sort_dir`: Sort direction (asc or desc)
   - `start`: Calculated offset for pagination `(currentPage - 1) * limit`
   - `limit`: Number of items per page (default: 10)

3. **Backend Processing**: Laravel receives the request in `ProdukController@list`, validates the input parameters, processes the query with filters and sorting, and returns a JSON response containing the filtered product count and the paginated product array.

4. **Frontend Update**: Vue receives the response and updates the reactive data properties (`produk` and `totalCount`). The component automatically re-renders the table with new data, maintaining the continuous row numbering across pages.

5. **User Feedback**: The UI displays the updated product list, pagination controls, and shows the current range of displayed items (e.g., "Showing 11 to 20 of 150 products").

---

## 2. Backend Handling (Laravel API)

### Request Validation and Processing

The Laravel backend implements robust request handling with the following key features:

**Input Validation**: The `ProdukController@list` method validates all incoming parameters using Laravel's Validator. It ensures `start` and `limit` are valid integers, `sort_by` only accepts allowed fields (nama_produk, harga, stok), and `sort_dir` only accepts asc or desc. Invalid requests return a 422 status code with error details.

**Filtering Logic**: When a `keyword` is provided, the controller applies a WHERE clause with LIKE pattern matching on both `nama_produk` and `kategori` fields using an OR condition. This allows users to search products by either name or category. The pattern uses wildcards (`%keyword%`) for partial matching, enabling flexible search queries.

**Sorting Implementation**: The backend applies dynamic sorting using Laravel's `orderBy()` method. If `sort_by` and `sort_dir` are specified, the query builder adds an ORDER BY clause to the SQL query. If no sorting is specified, products are returned in their default order (by ID).

**Pagination Strategy**: After filtering and before applying pagination, the controller counts the total matching records using `count()`. This total is essential for frontend pagination calculation. Then, it applies `offset(start)` and `limit(limit)` to fetch only the required page of results. This approach is efficient because it retrieves only the necessary records from the database.

**Response Format**: The API returns a consistent JSON structure with two keys: `count` (total filtered records) and `produk` (array of product objects). Each product object includes formatted timestamps using `format('Y-m-d H:i:s')` to ensure consistent date formatting across the application.

---

## 3. Frontend State Management & Row Numbering

### Vue.js Reactive State

The Vue component manages application state using the Composition API's `data()` function, which creates reactive properties that automatically trigger UI updates when changed:

**Search State**: The `keyword` property is bound to the search input using `v-model`. When the user types, the `onSearchChange()` method implements a debounce mechanism with a 500ms delay using `setTimeout()`. This prevents excessive API calls while the user is still typing, improving performance and reducing server load.

**Sorting State**: Two reactive properties control sorting: `sortBy` (the field name) and `sortDir` (asc/desc). These are bound to dropdown selects with `v-model` and trigger immediate API calls through the `onSortChange()` method. When sorting changes, the component resets to page 1 to show results from the beginning.

**Pagination State**: The component tracks `currentPage`, `limit`, `totalCount`, and computed `totalPages`. The `goToPage()` method handles page navigation, validates the target page is within bounds, and prevents redundant requests if the user clicks the current page.

### Continuous Row Numbering Algorithm

The most critical feature for user experience is maintaining continuous row numbers across paginated pages. This is achieved through the `getRowNumber(index)` method:

**Calculation Formula**: `(this.currentPage - 1) * this.limit + index + 1`

**How It Works**:
- `(this.currentPage - 1) * this.limit` calculates the offset (how many items came before this page)
- `index` is the zero-based position within the current page's array
- Adding `1` converts from zero-based to one-based numbering

**Example Scenarios**:
- Page 1, Item 0: `(1-1) * 10 + 0 + 1 = 1`
- Page 1, Item 9: `(1-1) * 10 + 9 + 1 = 10`
- Page 2, Item 0: `(2-1) * 10 + 0 + 1 = 11`
- Page 3, Item 5: `(3-1) * 10 + 5 + 1 = 26`

This ensures that users see sequential numbering (1, 2, 3...) across all pages, making it easy to reference specific products by their row number regardless of which page they're viewing.

---

## 4. Technical Implementation Details

### Database Query Optimization

The Laravel query builder constructs efficient SQL queries:
```sql
SELECT * FROM produk 
WHERE (nama_produk LIKE '%keyword%' OR kategori LIKE '%keyword%')
ORDER BY harga ASC
LIMIT 10 OFFSET 20
```

### HTTP Request Example

```javascript
axios.post('http://localhost:8000/api/produk/list', {
  keyword: 'computer',
  sort_by: 'harga',
  sort_dir: 'asc',
  start: 20,
  limit: 10
})
```

### Response Example

```json
{
  "count": 145,
  "produk": [
    {
      "id": 21,
      "nama_produk": "Computer Security",
      "kategori": "Ben Rothke,Cissp",
      "harga": 50000,
      "stok": 25,
      "created_at": "2025-11-20 10:00:00"
    }
  ]
}
```

---

## 5. User Experience Features

### Debounced Search
Prevents API overload by waiting 500ms after the last keystroke before sending a search request.

### Smart Pagination
Shows up to 5 page numbers at a time, with First/Previous/Next/Last buttons for easy navigation.

### Responsive Design
The UI adapts to mobile and tablet screens with flexible layouts and responsive tables.

### Loading States
Displays loading indicator during API requests and error messages if requests fail.

---

## 6. Security Considerations

- **Input Validation**: All user inputs are validated both on frontend and backend
- **SQL Injection Prevention**: Laravel's query builder uses parameterized queries
- **CORS Configuration**: Laravel must have CORS enabled for frontend communication
- **Rate Limiting**: Can be implemented in Laravel routes to prevent abuse

---

## Technology Stack Summary

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Backend | Laravel 10+ | REST API, Database ORM |
| Frontend | Vue.js 3 | Reactive UI Components |
| HTTP Client | Axios | API Communication |
| Database | MySQL | Data Persistence |
| Styling | Scoped CSS | Component Styling |

---

This architecture ensures a maintainable, scalable, and user-friendly product listing system with professional-grade features for filtering, sorting, and pagination.
