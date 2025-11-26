# Product List Application - Automated Installation Script
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Product List Application Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if temp-backend exists and is complete
if (Test-Path "temp-backend\artisan") {
    Write-Host "[1/8] Copying Laravel files to backend..." -ForegroundColor Yellow
    
    # Copy Laravel framework files to backend
    $itemsToCopy = @(
        "bootstrap", "config", "public", "resources", "storage", "tests",
        "artisan", "composer.json", "composer.lock", "package.json",
        "phpunit.xml", "vite.config.js", ".env.example"
    )
    
    foreach ($item in $itemsToCopy) {
        $source = "temp-backend\$item"
        $dest = "backend\$item"
        if (Test-Path $source) {
            if (Test-Path $dest) {
                Remove-Item -Recurse -Force $dest
            }
            Copy-Item -Recurse -Force $source $dest
            Write-Host "  ✓ Copied $item" -ForegroundColor Green
        }
    }
    
    # Copy vendor directory
    if (Test-Path "temp-backend\vendor") {
        Write-Host "  ✓ Copying vendor directory (this may take a moment)..." -ForegroundColor Yellow
        Copy-Item -Recurse -Force "temp-backend\vendor" "backend\vendor"
        Write-Host "  ✓ Vendor directory copied" -ForegroundColor Green
    }
    
    Write-Host "[2/8] Cleaning up temporary files..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "temp-backend"
    Write-Host "  ✓ Cleanup complete" -ForegroundColor Green
} else {
    Write-Host "[1/8] Laravel installation not complete yet. Please wait..." -ForegroundColor Red
    Write-Host "Run this script again after 'composer create-project' finishes." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[3/8] Setting up backend environment..." -ForegroundColor Yellow
Set-Location backend

# Create .env from .env.example
if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "  ✓ Created .env file" -ForegroundColor Green
}

# Generate application key
Write-Host "  ⏳ Generating application key..." -ForegroundColor Yellow
php artisan key:generate --no-interaction
Write-Host "  ✓ Application key generated" -ForegroundColor Green

Set-Location ..

Write-Host ""
Write-Host "[4/8] Database Configuration" -ForegroundColor Yellow
Write-Host "  Please ensure MySQL is running and update backend\.env with:" -ForegroundColor Cyan
Write-Host "    DB_DATABASE=produk" -ForegroundColor White
Write-Host "    DB_USERNAME=root" -ForegroundColor White
Write-Host "    DB_PASSWORD=your_password" -ForegroundColor White
Write-Host ""
$response = Read-Host "Have you configured the database settings (y/n)"
if ($response -ne "y") {
    Write-Host "  ⚠ Please configure database settings in backend\.env and run this script again" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "[5/8] Creating database..." -ForegroundColor Yellow
$dbCreated = $false
try {
    # Try to create database
    $null = mysql -u root -e "CREATE DATABASE IF NOT EXISTS produk;" 2>&1
    Write-Host "  ✓ Database 'produk' created" -ForegroundColor Green
    $dbCreated = $true
} catch {
    Write-Host "  ⚠ Could not create database automatically" -ForegroundColor Yellow
    Write-Host "  Please create database manually: CREATE DATABASE produk;" -ForegroundColor Cyan
    $response = Read-Host "Have you created the database manually (y/n)"
    if ($response -eq "y") {
        $dbCreated = $true
    }
}

if (-not $dbCreated) {
    Write-Host "  ✗ Database not created. Exiting..." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[6/8] Running migrations..." -ForegroundColor Yellow
Set-Location backend
php artisan migrate --force
Write-Host "  ✓ Migrations completed" -ForegroundColor Green

Write-Host ""
Write-Host "[7/8] Importing sample data..." -ForegroundColor Yellow
Set-Location ..
try {
    Get-Content "produk_database.sql" | mysql -u root produk 2>&1 | Out-Null
    Write-Host "  ✓ Sample data imported" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Could not import data automatically" -ForegroundColor Yellow
    Write-Host "  Run manually from cmd: mysql -u root produk less-than produk_database.sql" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "[8/8] Setting up frontend..." -ForegroundColor Yellow
Set-Location frontend
if (-not (Test-Path "node_modules")) {
    Write-Host "  ⏳ Installing npm dependencies (this may take a few minutes)..." -ForegroundColor Yellow
    npm install
    Write-Host "  ✓ npm dependencies installed" -ForegroundColor Green
} else {
    Write-Host "  ✓ npm dependencies already installed" -ForegroundColor Green
}
Set-Location ..

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✓ Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "To start the application:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Terminal 1 - Backend:" -ForegroundColor Yellow
Write-Host "  cd backend" -ForegroundColor White
Write-Host "  php artisan serve" -ForegroundColor White
Write-Host ""
Write-Host "Terminal 2 - Frontend:" -ForegroundColor Yellow
Write-Host "  cd frontend" -ForegroundColor White
Write-Host "  npm run dev" -ForegroundColor White
Write-Host ""
Write-Host "Then open: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
