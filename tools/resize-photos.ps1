<#
  사진 줄이기 (사진 페이지용)

  사용법: 사이트 폴더(D:\CAL_website)에서 PowerShell을 열고
      powershell -ExecutionPolicy Bypass -File tools/resize-photos.ps1

  하는 일
  - assets\img\gallery 아래의 JPG 사진 중 긴 변이 1600px보다 크거나 500KB보다 큰 것을
    긴 변 1600px, JPEG 품질 82로 줄여서 같은 이름으로 덮어씁니다.
  - 줄인 결과가 원래보다 작을 때만 바꿉니다. 이미 작은 사진은 그대로 둡니다.
  - 휴대폰 사진의 회전 정보(EXIF)를 반영해서 똑바로 세운 뒤 저장합니다.

  주의: 원본을 덮어씁니다. 원본은 반드시 사이트 폴더 밖에 따로 보관한 뒤 실행하세요.
#>
param(
  [string]$Path = "assets\img\gallery",
  [int]$MaxSide = 1600,
  [int]$Quality = 82,
  [int]$MaxKB = 500
)

Add-Type -AssemblyName System.Drawing
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$params = New-Object System.Drawing.Imaging.EncoderParameters(1)
$params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$Quality)

$files = Get-ChildItem -Path $Path -Recurse -File | Where-Object { $_.Extension -match '^\.(jpe?g)$' }
$changed = 0; $before = 0; $after = 0; $failed = 0

foreach ($f in $files) {
  $before += $f.Length
  try {
    $img = [System.Drawing.Image]::FromFile($f.FullName)
    $needs = ($img.Width -gt $MaxSide) -or ($img.Height -gt $MaxSide) -or ($f.Length -gt $MaxKB * 1KB)
    if (-not $needs) { $img.Dispose(); $after += $f.Length; continue }

    # EXIF 회전 정보(0x0112)를 반영
    if ($img.PropertyIdList -contains 0x0112) {
      switch ([int]$img.GetPropertyItem(0x0112).Value[0]) {
        2 { $img.RotateFlip('RotateNoneFlipX') }
        3 { $img.RotateFlip('Rotate180FlipNone') }
        4 { $img.RotateFlip('Rotate180FlipX') }
        5 { $img.RotateFlip('Rotate90FlipX') }
        6 { $img.RotateFlip('Rotate90FlipNone') }
        7 { $img.RotateFlip('Rotate270FlipX') }
        8 { $img.RotateFlip('Rotate270FlipNone') }
      }
    }

    $scale = [Math]::Min(1.0, $MaxSide / [Math]::Max($img.Width, $img.Height))
    $w = [int][Math]::Round($img.Width * $scale); $h = [int][Math]::Round($img.Height * $scale)
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = 'HighQualityBicubic'; $g.SmoothingMode = 'HighQuality'; $g.PixelOffsetMode = 'HighQuality'
    $g.DrawImage($img, 0, 0, $w, $h)
    $g.Dispose(); $img.Dispose()

    $tmp = "$($f.FullName).tmp"
    $bmp.Save($tmp, $codec, $params); $bmp.Dispose()

    $newSize = (Get-Item -LiteralPath $tmp).Length
    if ($newSize -lt $f.Length) {
      Move-Item -LiteralPath $tmp -Destination $f.FullName -Force
      $after += $newSize; $changed++
    } else {
      Remove-Item -LiteralPath $tmp; $after += $f.Length
    }
  } catch {
    $failed++; $after += $f.Length
    Write-Warning "건너뜀: $($f.FullName) ($($_.Exception.Message))"
  }
}

"사진 {0}장 중 {1}장을 줄였습니다. {2:N0}MB -> {3:N0}MB (실패 {4}장)" -f $files.Count, $changed, ($before / 1MB), ($after / 1MB), $failed
