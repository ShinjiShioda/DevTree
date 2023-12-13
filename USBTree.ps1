function global:Proc([ref]$devices){
    # すべてのデバイスを順番に処理（親のないデバイス）
    foreach($devc in $devices.value){
            Add-Child -parentDevice ([ref]$devc) -devices $devices ;
        }
     }
function global:Add-Child([ref]$parentDevice,[ref]$devices){
    # $parentDeviceが親かどうか
    if ($parentDevice.value.ParentIDPrefix -ne $null) {
        # 親なので子のリストを作成
        $childList = $devices.value | ? {$_.DeviceID -like  "*$($parentDevice.value.ParentIDPrefix)*"}
        foreach ($currentDev in $childList){
            # すべの子を処理（再帰呼び出し）
            add-child -parentDevice ([ref]$currentDev) -devices $devices
            # 処理済みの子をchildプロパティに追加（初期値が配列）
            $parentDevice.value.child += $currentDev
            # 処理済みの子をデバイスのリストから削除
            $devices.value = $devices.value | ? { $_.DeviceID -ne $currentDev.DeviceID }
        }
    }
    # 親でないときにはなにもしない
}
# 子供をプリントする
function global:Out-child($numberOfLevel,$devs,$displayScriptBlock){
    # すべての$devsを処理
    foreach($dev in $devs){
        # スクリプトブロック（$$parentDevice）を使って現在のデバイスを出力
        & $displayScriptBlock $numberOfLevel $dev
        # 子があるならレベルを増やして再帰呼び出し
        if($dev.child.length -ne 0){
            out-child ($numberOfLevel+1) $dev.child $displayScriptBlock
        }
    }
}
# 処理するコマンド例
Write-host "Proc ([ref]`$mydev)"
