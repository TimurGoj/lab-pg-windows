param (
    [string]$MigrationsPath = ".\db\migrations"
)

Write-Host "[Валидация] Запуск проверки миграций..." -ForegroundColor Cyan

if (-Not (Test-Path $MigrationsPath)) {
    Write-Host "[Валидация] ОШИБКА: Папка $MigrationsPath не найдена!" -ForegroundColor Red
    exit 1
}

$files = Get-ChildItem -Path $MigrationsPath -Filter "*.sql"
if ($files.Count -eq 0) {
    Write-Host "[Валидация] ВНИМАНИЕ: В папке нет SQL-файлов." -ForegroundColor Yellow
    exit 0
}

$hasErrors = $false

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $fName = $file.Name
    
    if ($content -match "(?i)DROP\s+(TABLE|DATABASE)") {
        Write-Host "[Валидация] ОШИБКА в $fName : Найдена опасная команда DROP!" -ForegroundColor Red
        $hasErrors = $true
    }
    
    if ($content -match "(?i)TRUNCATE\s+TABLE") {
        Write-Host "[Валидация] ОШИБКА в $fName : Найдена опасная команда TRUNCATE!" -ForegroundColor Red
        $hasErrors = $true
    }

    if ($content -match "(?i)\bSELEC\b") {
        Write-Host "[Валидация] ОШИБКА в $fName : Опечатка (SELEC вместо SELECT)!" -ForegroundColor Red
        $hasErrors = $true
    }
}

if ($hasErrors) {
    Write-Host "`n[Валидация] ПРОВАЛЕНО. Исправьте ошибки и повторите." -ForegroundColor Red
    exit 1
} else {
    Write-Host "`n[Валидация] УСПЕШНО. Валидация завершена успешно." -ForegroundColor Green
    exit 0
}