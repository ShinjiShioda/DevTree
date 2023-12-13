# ASCII.JP Windows Info 2023年12月17日公開記事プログラム
PowerShellを使ってUSBデバイスの親子関係を表示

### 事前準備
PowerShellで以下のコマンドを実行し、デバイス情報を変数に記録させておく。この情報にあるParentIDPrefixを使い、子をchildに入れる。

    $USB=(Get-CimInstance Win32_USBControllerDevice).Dependent.DeviceID | ? {$_ -notlike "BTH*"} | ? {$_ -notlike "SWD*"}
    $mydev=Get-CimInstance Win32_PnPEntity |? DeviceID -in $USB | %{ $p=@{}; 
        $x=(Join-Path "HKLM:\SYSTEM\CurrentControlSet\Enum" $_.DeviceID | Get-ItemProperty) ;
        foreach($y in $x.psobject.Properties.name ){ $p[$y]=$x.$y };
        Add-Member -InputObject $_ -NotePropertyMembers $p -ErrorAction SilentlyContinue -PassThru }
    $mydev | Add-Member -NotePropertyName 'Child' -NotePropertyValue @()
    $mydev | ? { $_.LocationInformation -match "Port_#.*Hub_#" } | %{ 
        Add-Member -InputObject $_ -NotePropertyName "Hub" -NotePropertyValue ([int](($_.LocationInformation -split '\.' -split '#')[3])) }
    $mydev | ? { $_.LocationInformation -match "Port_#.*Hub_#" } | %{ 
        Add-Member -InputObject $_ -NotePropertyName "Port" -NotePropertyValue ([int](($_.LocationInformation -split '\.' -split '#')[1])) }

### 実行
USBTree.ps1を読み込む。関数ProcとOut-Childが定義される。

$myDevに記録されているデバイスのリストの親子関係を処理する（$myDevが変更される）

    proc ([ref]$myDev)

処理した$myDevを親子関係で表示する

    Out-Child 0 $myDev {表示用スクリプトブロック}

例

    Out-child 0 $mydev { param($n,$dev); Write-host "$('  '*$n)$($dev.name)" }

子を出力するループの中で、スクリプトブロックを実行している。コードの28行目。子のレベルと現在のデバイスの２つが引数になる。"param($n, $dev)"は、$nに子のレベル、$devに現在のデバイス（前記の$mydevの要素）が入る。これをスクリプトブロック内で出力すれば、これがOut-Childの出力になる。

詳細は記事参照のこと。
