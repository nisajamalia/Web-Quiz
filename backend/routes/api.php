<?php

use App\Http\Controllers\ProdukController;
use Illuminate\Support\Facades\Route;

Route::post('/produk/list', [ProdukController::class, 'list']);
Route::get('/produk/list', [ProdukController::class, 'list']);
