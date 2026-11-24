<#
  로고 원본(assets\img\icon)에서 사이트용 로고 파일을 만듭니다.
  로고가 바뀌면 사이트 폴더에서 다시 실행하세요:
      powershell -ExecutionPolicy Bypass -File tools/make-logo-files.ps1

  만드는 파일
  - assets\img\cal-emblem.png   원형 엠블럼 128x128 (상단 메뉴, 바닥글)
  - favicon.png                 원형 엠블럼 64x64 (브라우저 탭)
  - apple-touch-icon.png        원형 엠블럼 180x180, 흰 배경 (휴대폰 홈 화면)
  - share.jpg                   가로형 로고 1200x630, 흰 배경 (링크 미리보기)
#>
Add-Type -AssemblyName System.Drawing
$src = 'assets\img\icon\CAL_앰블럼 (배경X).png'
$wide = 'assets\img\icon\CAL_앰블럼 (흰색).jpg'
# 원형 엠블럼이 있는 영역 (원본 1280x587 기준). 로고 원본이 바뀌면 이 숫자를 다시 맞추세요.
$box = New-Object System.Drawing.Rectangle(242, 79, 425, 425)

function Save-Png($img, $path) { $img.Save((Join-Path (Get-Location) $path), [System.Drawing.Imaging.ImageFormat]::Png) }
function New-Canvas($w, $h, $fill) {
  $bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = 'HighQualityBicubic'; $g.SmoothingMode = 'HighQuality'; $g.PixelOffsetMode = 'HighQuality'; $g.CompositingQuality = 'HighQuality'
  if ($fill) { $g.Clear($fill) } else { $g.Clear([System.Drawing.Color]::Transparent) }
  return @($bmp, $g)
}

$logo = [System.Drawing.Image]::FromFile((Join-Path (Get-Location) $src))
foreach ($item in @(@('assets\img\cal-emblem.png', 128, $null, 0), @('favicon.png', 64, $null, 0), @('apple-touch-icon.png', 180, [System.Drawing.Color]::White, 14))) {
  $path, $size, $fill, $pad = $item
  $bmp, $g = New-Canvas $size $size $fill
  $g.DrawImage($logo, (New-Object System.Drawing.Rectangle($pad, $pad, ($size - 2 * $pad), ($size - 2 * $pad))), $box, [System.Drawing.GraphicsUnit]::Pixel)
  $g.Dispose(); Save-Png $bmp $path; $bmp.Dispose()
  "{0}  {1}x{1}  {2:N0} KB" -f $path, $size, ((Get-Item $path).Length / 1KB)
}
$logo.Dispose()

# 링크 미리보기 이미지: 흰 배경 1200x630 가운데에 가로형 로고
$w = [System.Drawing.Image]::FromFile((Join-Path (Get-Location) $wide))
$bmp, $g = New-Canvas 1200 630 ([System.Drawing.Color]::White)
$scale = [Math]::Min(1120 / $w.Width, 560 / $w.Height)
$dw = [int]($w.Width * $scale); $dh = [int]($w.Height * $scale)
$g.DrawImage($w, [int]((1200 - $dw) / 2), [int]((630 - $dh) / 2), $dw, $dh)
$g.Dispose(); $w.Dispose()
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$p = New-Object System.Drawing.Imaging.EncoderParameters(1)
$p.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]88)
$bmp.Save((Join-Path (Get-Location) 'share.jpg'), $codec, $p); $bmp.Dispose()
"{0}  1200x630  {1:N0} KB" -f 'share.jpg', ((Get-Item 'share.jpg').Length / 1KB)
