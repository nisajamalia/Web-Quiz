<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Produk extends Model
{
    protected $table = 'produk';
    public $timestamps = false;

    protected $fillable = [
        'nama_produk',
        'kategori',
        'harga',
        'stok',
        'created_at'
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'harga' => 'integer',
        'stok' => 'integer'
    ];
}
