@echo off
echo ========================================
echo Product List Application - Quick Setup
echo ========================================
echo.

echo [1/5] Setting up Backend...
cd backend
if not exist vendor (
    echo Installing Composer dependencies...
    call composer install
) else (
    echo Composer dependencies already installed.
)

if not exist .env (
    echo Creating .env file...
    copy .env.example .env
    echo.
    echo Please update .env with your database credentials:
    echo DB_DATABASE=produk
    echo DB_USERNAME=root
    echo DB_PASSWORD=your_password
    echo.
    pause
)

echo Generating application key...
call php artisan key:generate

echo.
echo [2/5] Please create database 'produk' in MySQL
echo Run this command in MySQL:
echo CREATE DATABASE produk;
echo.
pause

echo Running migrations...
call php artisan migrate

echo.
echo [3/5] Import sample data...
echo Option 1: Run seeder
echo   php artisan db:seed --class=ProdukSeeder
echo.
echo Option 2: Import SQL file
echo   mysql -u root -p produk ^< ..\produk_database.sql
echo.
pause

cd ..

echo.
echo [4/5] Setting up Frontend...
cd frontend
if not exist node_modules (
    echo Installing npm dependencies...
    call npm install
) else (
    echo npm dependencies already installed.
)

cd ..

echo.
echo [5/5] Setup Complete!
echo.
echo ========================================
echo To start the application:
echo ========================================
echo.
echo Terminal 1 - Backend:
echo   cd backend
echo   php artisan serve
echo.
echo Terminal 2 - Frontend:
echo   cd frontend
echo   npm run dev
echo.
echo Then open: http://localhost:3000
echo.
echo ========================================
pause
