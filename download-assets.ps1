# ─── 4mb-site: download Figma assets ─────────────────────────
# Шлях до вашого проекту на Google Drive
$ProjectRoot = "G:\My Drive\опбр\4mb-site"
$BasePath = "$ProjectRoot\assets\images"

# Figma personal access token (ОБОВ'ЯЗКОВО вставте, якщо отримаєте 401)
$FigmaToken = ""

# ─── Створення базової папки, якщо її немає ───────────────────
if (-not (Test-Path $BasePath)) {
    New-Item -ItemType Directory -Path $BasePath -Force | Out-Null
}

# ─── Список зображень ─────────────────────────────────────────
$images = @(
    ("ui",          "logo-4",            "666c7aa7-07f4-4fa6-81de-e231bd97c453"),
    ("ui",          "telegram",          "a41ab375-f2bb-4f39-a5fb-0935464d5fad"),
    ("ui",          "facebook",          "6e9513f8-2d7a-4b5c-8847-3e95ff9fbd09"),
    ("ui",          "emblem-hero",       "7d092f7c-b413-4c67-b6a3-6bac665ebd48"),
    ("ui",          "emblem-contacts",   "856b55e0-4105-499f-bd09-25751edd2bec"),
    ("ui",          "badge-commander",   "a48f4d60-8a2a-4945-aa9f-ab25286cd5ee"),
    ("hero",        "hero-bg",           "db6d7e4f-eafd-44cd-b302-69d887a7fcc1"),
    ("gallery",     "system-1",          "75e92f9e-c684-422b-b32c-ef396bd865a9"),
    ("gallery",     "system-2",          "7384e4aa-5de8-4032-8561-36c9d1134313"),
    ("gallery",     "system-3",          "41bd8559-506d-4013-b2ac-6b7d21d0d904"),
    ("gallery",     "system-4",          "09620695-af7e-4ae2-b7b6-cbdb3eed330b"),
    ("gallery",     "system-5",          "16cf6d4f-e273-4c3c-a9bf-63e0dc925861"),
    ("gallery",     "system-6",          "ba6eac0f-9e29-4a95-b1a1-cf1c7bb017c8"),
    ("gallery",     "path-1",            "72d159e6-292e-4996-918a-96e36bd3fc03"),
    ("gallery",     "path-2",            "0dd074e0-b6a4-4e62-9246-a0d1f20f6267"),
    ("gallery",     "path-3",            "0ba23ece-eb54-4919-a240-60e1a3138884"),
    ("gallery",     "path-4",            "057ad464-c546-48ca-9c2a-8b5842994ff9"),
    ("gallery",     "path-5",            "e7f7cd74-c59d-49e6-a057-156120157e42"),
    ("gallery",     "path-6",            "9bb6a106-14d7-432e-b47c-4de54f747d02"),
    ("commanders",  "cmd-1",             "0a655bf4-7afc-41e9-b9f4-a7ca063a32e3"),
    ("commanders",  "cmd-2",             "26fcf476-d4cf-49fd-a30d-5a5cb2b724a8"),
    ("reels",       "review-1",          "f66a273f-b41e-4d9a-8b86-efbb86611b41"),
    ("reels",       "review-2",          "7b08abb6-d2f9-4fd5-9cff-21b488f13060"),
    ("reels",       "review-3",          "888de518-c559-40ce-b07d-5cb51c4f5522"),
    ("reels",       "review-4",          "6da8375a-66ee-4c63-8a9f-41a2593b11e2"),
    ("jobs",        "job-1",             "5602ca79-194c-48ee-9c99-57065592e6c1"),
    ("jobs",        "job-2",             "97e6a440-5a6c-4f01-a8ca-2e3f2f585a01"),
    ("jobs",        "job-3",             "942dcf45-0eb5-403f-be22-536bccde90c0"),
    ("jobs",        "job-4",             "6bb398de-1020-4a05-a34c-bccadce12992")
)

$headers = @{ "User-Agent" = "Mozilla/5.0" }
if ($FigmaToken -ne "") { $headers["X-Figma-Token"] = $FigmaToken }

$ok = 0; $fail = 0

foreach ($img in $images) {
    $folder, $name, $id = $img
    $url = "https://www.figma.com/api/mcp/asset/$id"
    
    # Автоматичне створення підпапки для кожної категорії
    $TargetFolder = Join-Path $BasePath $folder
    if (-not (Test-Path $TargetFolder)) {
        New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
    }

    try {
        $response = Invoke-WebRequest -Uri $url -Headers $headers -UseBasicParsing -ErrorAction Stop
        
        $ct = $response.Headers["Content-Type"] -as [string]
        $ext = if ($ct -match "jpeg|jpg") { "jpg" }
               elseif ($ct -match "png") { "png" }
               elseif ($ct -match "svg") { "svg" }
               else { "png" }

        $path = Join-Path $TargetFolder "$name.$ext"

        # Якщо це SVG (текст), зберігаємо як текст, інакше як байти
        if ($ext -eq "svg") {
            [System.IO.File]::WriteAllText($path, $response.Content)
        } else {
            [System.IO.File]::WriteAllBytes($path, $response.Content)
        }
        
        Write-Host "  [OK]   Saved to: $folder/$name.$ext" -ForegroundColor Green
        $ok++
    }
    catch {
        Write-Host "  [FAIL] $folder/$name — $($_.Exception.Message)" -ForegroundColor Red
        $fail++
    }
}

Write-Host "`nЗавершено! Успішно: $ok, Помилок: $fail" -ForegroundColor Cyan
Read-Host "Натисніть Enter для виходу"