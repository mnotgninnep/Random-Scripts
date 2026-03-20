# Usage: Change these paths to your source images
# Source folder
$workingFolder = "C:\Users\User\Documents\Scripts\Intune\App Logos"
# Input image. Can be .ico, .png or .jpg. Pre-made .ico is best. Use software. The powershell way isn't great.
# Suggestion for online:  https://www.icoconverter.com/
# Suggestion for offline: https://github.com/siriz/win-icon-converter/releases
$inputImage    = "example.ico"
# Input path combines the above.
$Path          = Join-Path $workingFolder $inputImage
# Output base64 encoded .ico to a .txt file of the same name. Also copies to the clipboard for easy pasting to the remediation script.
$outputFile    = Join-Path $workingFolder ($inputImage.Split(".")[0] + ".txt")

# Rest of script below here...
Add-Type -AssemblyName System.Drawing

# Fuction to process image data to base64 encoded icon data to paste to remediation script.
function Get-Base64SmartIcon {
    param ([string]$SourcePath)
    
    $Extension = [System.IO.Path]::GetExtension($SourcePath).ToLower()

    # Pass-Through for existing .ico files
    if ($Extension -eq ".ico") {
        Write-Host "Existing .ico detected. Encoding raw bytes for pass-through..." -ForegroundColor Cyan
        $Bytes = [System.IO.File]::ReadAllBytes($SourcePath)
        return [Convert]::ToBase64String($Bytes)
    }

    # Processing for PNG/JPG
    Write-Host "Image file detected. Generating anti-aliased multi-res icon stack..." -ForegroundColor Yellow
    $SourceImg = [System.Drawing.Image]::FromFile($SourcePath)
    $Sizes = @(16, 32, 48, 256)
    
    $IcoStream = New-Object System.IO.MemoryStream
    $BW = New-Object System.IO.BinaryWriter($IcoStream)

    # ICONDIR Header
    $BW.Write([uint16]0); $BW.Write([uint16]1); $BW.Write([uint16]$Sizes.Count)

    $ImageDataStreams = @()
    $Offset = 6 + (16 * $Sizes.Count)

    foreach ($Size in $Sizes) {
        $Bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
        $G = [System.Drawing.Graphics]::FromImage($Bitmap)
        
        # Professional Rendering Engine
        $G.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $G.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $G.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $G.Clear([System.Drawing.Color]::Transparent)

        # Centered Aspect Ratio
        $Ratio = [Math]::Min($Size / $SourceImg.Width, $Size / $SourceImg.Height)
        $NewW = [int]($SourceImg.Width * $Ratio); $NewH = [int]($SourceImg.Height * $Ratio)
        $G.DrawImage($SourceImg, [int](($Size - $NewW) / 2), [int](($Size - $NewH) / 2), $NewW, $NewH)

        # Save Frame as PNG Bytes
        $MS = New-Object System.IO.MemoryStream
        $Bitmap.Save($MS, [System.Drawing.Imaging.ImageFormat]::Png)
        $Bytes = $MS.ToArray()
        $ImageDataStreams += ,$Bytes

        # ICONDIRENTRY
        $BW.Write([byte]($Size -eq 256 ? 0 : $Size)) # Width
        $BW.Write([byte]($Size -eq 256 ? 0 : $Size)) # Height
        $BW.Write([byte]0); $BW.Write([byte]0)       # Colors/Reserved
        $BW.Write([uint16]1); $BW.Write([uint16]32)  # Planes/BPP
        $BW.Write([uint32]$Bytes.Length)             # Data Size
        $BW.Write([uint32]$Offset)                   # Data Offset
        
        $Offset += $Bytes.Length
        $G.Dispose(); $Bitmap.Dispose()
    }

    # Write Image Data
    foreach ($Data in $ImageDataStreams) { $BW.Write($Data) }

    $Base64 = [Convert]::ToBase64String($IcoStream.ToArray())
    $BW.Close(); $IcoStream.Dispose(); $SourceImg.Dispose()
    
    return $Base64
}

# Main execution
if (Test-Path $Path) {
    $Base64Result = Get-Base64SmartIcon -SourcePath $Path
    
    # Write to file
    $Base64Result | Out-File $outputFile
    
    # Copy to clipboard
    $Base64Result | Set-Clipboard
    
    Write-Host "`nSuccess!" -ForegroundColor Green
    Write-Host "1. Base64 string saved to: $outputFile"
    Write-Host "2. Base64 string has been copied to your CLIPBOARD." -ForegroundColor Magenta
    Write-Host "   You can now paste it directly into your Intune script.`n" -ForegroundColor Magenta
} else {
    Write-Error "Source file not found at: $Path. Check it's actually in the input folder."
}