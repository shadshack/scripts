# Script to connect to Azure AD sync server and run a manual sync job

# Set the server to connect to and run the sync task on
$server = "servername"
$taskName = "Task Name"

Write-Host -Foregroundcolor yellow "Connecting to server $($server) and running scheduled task '$($taskName)'..."

# Run the command over a PSRemote session
Invoke-Command -ComputerName $server -ScriptBlock {
    # Get the scheduled task for the manual sync job
    $task = Get-ScheduledTask -TaskName $args[0]

    # Run the task
    $task | Start-ScheduledTask

    # Update the status
    $task = Get-ScheduledTask -TaskName $args[0]

    # Wait for the task to complete
    while ($task.State -eq "Running") {
        Start-Sleep -Seconds 1
        $task = Get-ScheduledTask -TaskName $args[0]
    }
    $taskInfo = Get-ScheduledTask -TaskName $args[0] | Get-ScheduledTaskInfo
    if ($taskInfo.LastTaskResult -eq 0){
      Write-Host -Foregroundcolor Green  "Task completed successfully"
    } 
    else {
      Write-Host -Foregroundcolor red "Task failed with error code: "$taskInfo.LastTaskResult
    }
    Write-Host -Foregroundcolor yellow "Last run time: "$taskInfo.LastRunTime

} -ArgumentList $taskName
