# 更换桌面
# 设置图片文件夹后，随机更换桌面
# 配合 Windows 任务-计划，可设置每3天更换一次

# 背景图片所在目录。请替换为自己电脑的目录
$bg_dir= "c:\Users\Public\Pictures"

Function Set-WallPaper {
 
<#
 
    .SYNOPSIS
    Applies a specified wallpaper to the current user's desktop
    
    .PARAMETER Image
    Provide the exact path to the image
 
    .PARAMETER Style
    Provide wallpaper style (Example: Fill, Fit, Stretch, Tile, Center, or Span)
  
    .EXAMPLE
    Set-WallPaper -Image "C:\Wallpaper\Default.jpg"
    Set-WallPaper -Image "C:\Wallpaper\Background.jpg" -Style Fit
  
#>
 
param (
    [parameter(Mandatory=$True)]
    # Provide path to image
    [string]$Image,
    # Provide wallpaper style that you would like applied
    [parameter(Mandatory=$False)]
    [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
    [string]$Style
)
 
$WallpaperStyle = Switch ($Style) {
  
    "Fill" {"10"}
    "Fit" {"6"}
    "Stretch" {"2"}
    "Tile" {"0"}
    "Center" {"0"}
    "Span" {"22"}
  
}
 
If($Style -eq "Tile") {
 
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force
 
}
Else {
 
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
    New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force
 
}
 
Add-Type -TypeDefinition @" 
using System; 
using System.Runtime.InteropServices;
  
public class Params
{ 
    [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
    public static extern int SystemParametersInfo (Int32 uAction, 
                                                   Int32 uParam, 
                                                   String lpvParam, 
                                                   Int32 fuWinIni);
}
"@ 
  
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
  
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
  
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}
 

Function Set-RandomWallpapper{
  param (
      [string] $bg_dir
  )
  
  $extList= "*.jpg","*.jpeg","*.png"
  
  $year= Get-Date -Format "yyyy"
  $already_dir= "$bg_dir\__$year"

  $image = Get-ChildItem -Path $bg_dir -Name -Include $extList |
    Get-Random -Count 1

  if($image -eq $null) {
      echo "当前桌面壁纸目录为：    $bg_dir"
      echo "请在其中放置图片文件(支持.jpg .jpep .png 格式)。"
      echo "然后重新运行本程序"
      echo "================================================"
      echo ""
      echo "按任意键退出..."
      [Console]::ReadKey()
      exit
  }

  # 例 2023-06-07--2360
  # 引入毫秒，避免命名冲突
  $today= Get-Date -Format "yyyy-MM-dd--ffff"

  # create if ./$year didn't exited
  New-Item -Path $already_dir -ItemType "directory" -Force

  $ext= $(Get-Item "$bg_dir\$image").extension
  $movedImage="$already_dir\$today" + $ext

  Move-Item -Path "$bg_dir\$image" -Destination $movedImage  
  Set-WallPaper -Image $movedImage -Style Fill
 
}


Set-RandomWallpapper -bg_dir $bg_dir