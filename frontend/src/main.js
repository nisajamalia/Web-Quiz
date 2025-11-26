import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import ProdukView from './views/ProdukView.vue'

// Create router
const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'produk',
      component: ProdukView
    }
  ]
})

// Create and mount app
const app = createApp(App)
app.use(router)
app.mount('#app')
