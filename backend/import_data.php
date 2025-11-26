<?php

// Read the SQL file
$sqlFile = __DIR__ . '/../produk_database.sql';
$sql = file_get_contents($sqlFile);

// Connect to SQLite database
$db = new PDO('sqlite:' . __DIR__ . '/database/database.sqlite');
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

// Remove backticks (MySQL specific) and split into statements
$sql = str_replace('`', '', $sql);
$statements = array_filter(array_map('trim', explode(';', $sql)));

// Execute each statement
$success = 0;
$errors = 0;

foreach ($statements as $statement) {
    if (empty($statement)) continue;
    
    // Skip CREATE DATABASE and USE statements
    if (stripos($statement, 'CREATE DATABASE') !== false || 
        stripos($statement, 'USE ') !== false) {
        continue;
    }
    
    try {
        $db->exec($statement);
        $success++;
    } catch (PDOException $e) {
        echo "Error: " . $e->getMessage() . "\n";
        echo "Statement: " . substr($statement, 0, 100) . "...\n\n";
        $errors++;
    }
}

echo "\n";
echo "Import complete!\n";
echo "Successful statements: $success\n";
echo "Errors: $errors\n";

// Check how many products were imported
$count = $db->query("SELECT COUNT(*) FROM produk")->fetchColumn();
echo "Total products in database: $count\n";
