# ASCII.JP Windows Info 2023年12月17日公開記事プログラム
$myDevに記録されているデバイスのリストの親子関係を処理する（$myDevが変更される）

$ proc ([ref]$myDev)

処理した$myDevを親子関係で表示する

$ Out-Child 0 $myDev {表示用スクリプトブロック}

例

$ Out-child 0 $mydev {"$($dev.Name)($($dev.ParentIDPrefix)) $($dev.DeviceID)"}

