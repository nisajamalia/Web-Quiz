<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ProdukSeeder extends Seeder
{
    public function run()
    {
        $categories = ['Elektronik', 'Fashion', 'Makanan', 'Buku', 'Furniture', 'Olahraga', 'Kecantikan', 'Mainan'];
        $products = [];

        // Generate 500 sample products
        for ($i = 1; $i <= 500; $i++) {
            $category = $categories[array_rand($categories)];
            $products[] = [
                'nama_produk' => "Product $i - " . $category,
                'kategori' => $category,
                'harga' => rand(10000, 1000000),
                'stok' => rand(0, 100),
                'created_at' => now(),
                'updated_at' => now(),
            ];

            // Insert in batches of 100
            if (count($products) === 100) {
                DB::table('produk')->insert($products);
                $products = [];
            }
        }

        // Insert remaining products
        if (!empty($products)) {
            DB::table('produk')->insert($products);
        }

        $this->command->info('500 products seeded successfully!');
    }
}
