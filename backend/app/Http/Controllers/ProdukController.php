<?php

namespace App\Http\Controllers;

use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ProdukController extends Controller
{
    public function list(Request $request)
    {
        // Validate input
        $validator = Validator::make($request->all(), [
            'keyword' => 'nullable|string',
            'sort_by' => 'nullable|string|in:nama_produk,harga,stok,id,',
            'sort_dir' => 'nullable|string|in:asc,desc',
            'start' => 'required|integer|min:0',
            'limit' => 'required|integer|min:1|max:100'
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->errors()], 400);
        }

        // Get parameters with defaults
        $keyword = $request->input('keyword', '');
        $sortBy = $request->input('sort_by', 'id');
        $sortBy = empty($sortBy) ? 'id' : $sortBy;
        $sortDir = $request->input('sort_dir', 'asc');
        $start = $request->input('start', 0);
        $limit = $request->input('limit', 10);

        // Build query
        $query = Produk::query();

        // Apply search filter
        if (!empty($keyword)) {
            $query->where(function($q) use ($keyword) {
                $q->where('nama_produk', 'LIKE', "%{$keyword}%")
                  ->orWhere('kategori', 'LIKE', "%{$keyword}%");
            });
        }

        // Get total count before pagination
        $count = $query->count();

        // Apply sorting
        $query->orderBy($sortBy, $sortDir);

        // Apply pagination
        $produk = $query->offset($start)->limit($limit)->get();

        return response()->json([
            'count' => $count,
            'produk' => $produk
        ]);
    }
}
