$Report = ".\infra\validation-report.txt"

Add-Content $Report "----------------------------------"
Add-Content $Report ("Дата: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
Add-Content $Report ("Пользователь: " + $env:USERNAME)

$StatusOk = $true

$svc = docker ps --filter "name=my_postgres" --format "{{.Status}}"
if ($svc -match "Up") {
    Add-Content $Report "Служба: Running (Docker container my_postgres)"
} else {
    Add-Content $Report "Служба: НЕ ЗАПУЩЕНА"
    $StatusOk = $false
}

$r = docker exec my_postgres pg_isready -U myuser
Add-Content $Report ("pg_isready: " + $r)
if ($r -notlike "*accepting*") {
    $StatusOk = $false
}

docker exec my_postgres psql -U myuser -d mydb -c "SELECT 1;" >> $Report 2>&1
if ($LASTEXITCODE -eq 0) {
    Add-Content $Report "Тестовый запрос: OK"
} else {
    Add-Content $Report "Тестовый запрос: ОШИБКА"
    $StatusOk = $false
}

if ($StatusOk) {
    Add-Content $Report "Итог: сервис работоспособен"
    Write-Host "[health-check] OK" -ForegroundColor Green
    exit 0
} else {
    Add-Content $Report "Итог: ОБНАРУЖЕНЫ ПРОБЛЕМЫ"
    Write-Host "[health-check] Проблемы найдены" -ForegroundColor Red
    exit 1
}