<template>
  <div class="produk-container">
    <div class="header">
      <h1>Product List</h1>
    </div>

    <!-- Search and Filter Controls -->
    <div class="controls">
      <div class="search-box">
        <label>Search:</label>
        <input 
          type="text" 
          v-model="keyword" 
          @input="onSearchChange"
          placeholder="Search by product name or category..."
          class="form-input"
        />
      </div>

      <div class="sort-controls">
        <div class="sort-by">
          <label>Sort By:</label>
          <select v-model="sortBy" @change="onSortChange" class="form-select">
            <option value="">Default</option>
            <option value="nama_produk">Product Name</option>
            <option value="harga">Price</option>
            <option value="stok">Stock</option>
          </select>
        </div>

        <div class="sort-dir">
          <label>Order:</label>
          <select v-model="sortDir" @change="onSortChange" class="form-select">
            <option value="asc">Ascending</option>
            <option value="desc">Descending</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading">
      Loading products...
    </div>

    <!-- Error State -->
    <div v-if="error" class="error">
      {{ error }}
    </div>

    <!-- Products Table -->
    <div v-if="!loading && !error" class="table-container">
      <table class="produk-table">
        <thead>
          <tr>
            <th>No</th>
            <th>Product</th>
            <th>Category</th>
            <th>Price</th>
            <th>Stock</th>
            <th>Created at</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, index) in produk" :key="item.id">
            <td>{{ getRowNumber(index) }}</td>
            <td>{{ item.nama_produk }}</td>
            <td>{{ item.kategori }}</td>
            <td>Rp {{ formatPrice(item.harga) }}</td>
            <td>{{ item.stok }}</td>
            <td>{{ item.created_at }}</td>
          </tr>
        </tbody>
      </table>

      <!-- No Results Message -->
      <div v-if="produk.length === 0" class="no-results">
        No products found.
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="!loading && produk.length > 0" class="pagination">
      <div class="pagination-info">
        Showing {{ (currentPage - 1) * limit + 1 }} to {{ Math.min(currentPage * limit, totalCount) }} of {{ totalCount }} products
      </div>
      
      <div class="pagination-controls">
        <button 
          @click="goToPage(1)" 
          :disabled="currentPage === 1"
          class="btn btn-page"
        >
          First
        </button>
        
        <button 
          @click="goToPage(currentPage - 1)" 
          :disabled="currentPage === 1"
          class="btn btn-page"
        >
          Previous
        </button>

        <span class="page-numbers">
          <button
            v-for="page in visiblePages"
            :key="page"
            @click="goToPage(page)"
            :class="['btn', 'btn-page', { active: page === currentPage }]"
          >
            {{ page }}
          </button>
        </span>

        <button 
          @click="goToPage(currentPage + 1)" 
          :disabled="currentPage === totalPages"
          class="btn btn-page"
        >
          Next
        </button>

        <button 
          @click="goToPage(totalPages)" 
          :disabled="currentPage === totalPages"
          class="btn btn-page"
        >
          Last
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'ProdukView',
  
  data() {
    return {
      // Product data
      produk: [],
      totalCount: 0,
      
      // Pagination
      currentPage: 1,
      limit: 10,
      
      // Filtering and Sorting
      keyword: '',
      sortBy: '',
      sortDir: 'asc',
      
      // UI State
      loading: false,
      error: null,
      
      // Debounce timer for search
      searchTimer: null
    };
  },
  
  computed: {
    /**
     * Calculate total number of pages
     */
    totalPages() {
      return Math.ceil(this.totalCount / this.limit);
    },
    
    /**
     * Generate visible page numbers for pagination
     */
    visiblePages() {
      const pages = [];
      const maxVisible = 5;
      let start = Math.max(1, this.currentPage - Math.floor(maxVisible / 2));
      let end = Math.min(this.totalPages, start + maxVisible - 1);
      
      // Adjust start if we're near the end
      if (end - start < maxVisible - 1) {
        start = Math.max(1, end - maxVisible + 1);
      }
      
      for (let i = start; i <= end; i++) {
        pages.push(i);
      }
      
      return pages;
    }
  },
  
  methods: {
    /**
     * Fetch products from API
     */
    async fetchProduk() {
      this.loading = true;
      this.error = null;
      
      try {
        // Use relative URL so Vite dev server proxy forwards to Laravel backend
        const response = await axios.post('/api/produk/list', {
          keyword: this.keyword,
          sort_by: this.sortBy,
          sort_dir: this.sortDir,
          start: (this.currentPage - 1) * this.limit,
          limit: this.limit
        });
        
        this.produk = response.data.produk;
        this.totalCount = response.data.count;
      } catch (err) {
        this.error = 'Failed to load products. Please try again.';
        console.error('Error fetching products:', err);
      } finally {
        this.loading = false;
      }
    },
    
    /**
     * Handle search input with debounce
     */
    onSearchChange() {
      // Clear existing timer
      if (this.searchTimer) {
        clearTimeout(this.searchTimer);
      }
      
      // Set new timer for debounce (500ms delay)
      this.searchTimer = setTimeout(() => {
        this.currentPage = 1; // Reset to first page on new search
        this.fetchProduk();
      }, 500);
    },
    
    /**
     * Handle sort change
     */
    onSortChange() {
      this.currentPage = 1; // Reset to first page on sort change
      this.fetchProduk();
    },
    
    /**
     * Navigate to specific page
     */
    goToPage(page) {
      if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
        this.currentPage = page;
        this.fetchProduk();
      }
    },
    
    /**
     * Calculate continuous row number across pages
     */
    getRowNumber(index) {
      return (this.currentPage - 1) * this.limit + index + 1;
    },
    
    /**
     * Format price with thousand separator
     */
    formatPrice(price) {
      return price.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    }
  },
  
  /**
   * Load products when component is mounted
   */
  mounted() {
    this.fetchProduk();
  }
};
</script>

<style scoped>
.produk-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.header {
  margin-bottom: 30px;
}

.header h1 {
  color: #333;
  font-size: 28px;
  font-weight: 600;
}

/* Controls Section */
.controls {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  align-items: flex-end;
}

.search-box {
  flex: 1;
  min-width: 250px;
}

.sort-controls {
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

.sort-by,
.sort-dir {
  display: flex;
  flex-direction: column;
}

label {
  font-weight: 500;
  margin-bottom: 5px;
  color: #555;
  font-size: 14px;
}

.form-input,
.form-select {
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  transition: border-color 0.3s;
}

.form-input {
  width: 100%;
}

.form-select {
  min-width: 150px;
  background-color: white;
  cursor: pointer;
}

.form-input:focus,
.form-select:focus {
  outline: none;
  border-color: #4CAF50;
}

/* Loading and Error States */
.loading,
.error {
  text-align: center;
  padding: 40px;
  font-size: 16px;
}

.loading {
  color: #666;
}

.error {
  color: #d32f2f;
  background: #ffebee;
  border-radius: 4px;
}

/* Table Styles */
.table-container {
  overflow-x: auto;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.produk-table {
  width: 100%;
  border-collapse: collapse;
}

.produk-table thead {
  background: #4CAF50;
  color: white;
}

.produk-table th {
  padding: 15px;
  text-align: left;
  font-weight: 600;
  font-size: 14px;
  text-transform: uppercase;
}

.produk-table tbody tr {
  border-bottom: 1px solid #e0e0e0;
  transition: background-color 0.2s;
}

.produk-table tbody tr:hover {
  background-color: #f5f5f5;
}

.produk-table td {
  padding: 12px 15px;
  font-size: 14px;
  color: #333;
}

.produk-table td:first-child {
  font-weight: 600;
  color: #666;
}

.no-results {
  text-align: center;
  padding: 40px;
  color: #999;
  font-size: 16px;
}

/* Pagination Styles */
.pagination {
  margin-top: 30px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 15px;
}

.pagination-info {
  color: #666;
  font-size: 14px;
}

.pagination-controls {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.page-numbers {
  display: flex;
  gap: 5px;
}

.btn {
  padding: 8px 16px;
  border: 1px solid #ddd;
  background: white;
  color: #333;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s;
}

.btn:hover:not(:disabled) {
  background: #4CAF50;
  color: white;
  border-color: #4CAF50;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn.active {
  background: #4CAF50;
  color: white;
  border-color: #4CAF50;
  font-weight: 600;
}

/* Responsive Design */
@media (max-width: 768px) {
  .controls {
    flex-direction: column;
  }
  
  .sort-controls {
    width: 100%;
  }
  
  .sort-by,
  .sort-dir {
    flex: 1;
  }
  
  .pagination {
    flex-direction: column;
    text-align: center;
  }
  
  .produk-table {
    font-size: 12px;
  }
  
  .produk-table th,
  .produk-table td {
    padding: 8px 10px;
  }
}
</style>
