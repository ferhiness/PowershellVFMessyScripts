$ComputerName = 'LGNRDB03'

Get-WmiObject -Class Win32_LogicalDisk -ComputerName $ComputerName |
    Where-Object {$_.DriveType -ne 5} |
    Sort-Object -Property Name | 
    Select-Object Name, VolumeName, VolumeSerialNumber,SerialNumber, FileSystem, Description, VolumeDirty, `
        @{"Label"="DiskSize(GB)";"Expression"={"{0:N}" -f ($_.Size/1GB) -as [float]}}, `
        @{"Label"="FreeSpace(GB)";"Expression"={"{0:N}" -f ($_.FreeSpace/1GB) -as [float]}}, `
        @{"Label"="%Free";"Expression"={"{0:N}" -f ($_.FreeSpace/$_.Size*100) -as [float]}} |
    Format-Table -AutoSize
