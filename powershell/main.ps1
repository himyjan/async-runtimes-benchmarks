param([int]$numTasks = 100000)

$script:remaining = $numTasks
$script:reset = New-Object System.Threading.ManualResetEvent($false)

for ($i = 0; $i -lt $script:numTasks; $i++) {
    [System.Threading.ThreadPool]::QueueUserWorkItem({
        [System.Threading.Thread]::Sleep(10000)
        if ([System.Threading.Interlocked]::Decrement([ref]$script:remaining) -eq 0) {
            $script:reset.Set()
        }
    }, $null) | Out-Null
}

$script:reset.WaitOne() | Out-Null
Write-Output "All tasks completed"
