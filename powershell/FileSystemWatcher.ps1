###############################################################################################################
# This script watches a folder for changes and if a file is created it will copy it to a destination folder.
# Source for most of this script: https://powershell.one/tricks/filesystem/filesystemwatcher#advanced-mode-asynchonous
###############################################################################################################

# Set the path to monitor
$MonitoredPath = "C:\Users\user\Desktop\"

# Set the path to copy files into
$destinationFolder = "C:\Users\user\Downloads\test"

# specify which files you want to monitor
$FileFilter = '*'

# specify whether you want to monitor subfolders as well:
$IncludeSubfolders = $true

# specify the file or folder properties you want to monitor:
$AttributeFilter = [IO.NotifyFilters]::FileName, [IO.NotifyFilters]::LastWrite 

try
{
  $watcher = New-Object -TypeName System.IO.FileSystemWatcher -Property @{
    Path = $MonitoredPath
    Filter = $FileFilter
    IncludeSubdirectories = $IncludeSubfolders
    NotifyFilter = $AttributeFilter
  }

  # define the code that should execute when a change occurs:
  $action = {
    # the code is receiving this to work with:
    
    # change type information:
    $details = $event.SourceEventArgs
    $Name = $details.Name
    $FullPath = $details.FullPath
    $OldFullPath = $details.OldFullPath
    $OldName = $details.OldName
    
    # type of change:
    $ChangeType = $details.ChangeType
    
    # when the change occured:
    $Timestamp = $event.TimeGenerated
    
    # save information to a global variable for testing purposes
    # so you can examine it later
    # MAKE SURE YOU REMOVE THIS IN PRODUCTION!
    $global:all = $details
    
    # now you can define some action to take based on the
    # details about the change event:
    
    # let's compose a message:
    $text = "{0} was {1} at {2}" -f $FullPath, $ChangeType, $Timestamp
    Write-Host ""
    Write-Host $text -ForegroundColor DarkYellow
    
    # you can also execute code based on change type here:
    switch ($ChangeType)
    {
      'Changed'  { "CHANGE" }
      'Created'  { "CREATED"
        # Make a copy of the file that was just created into the $destinationFolder with robocopy
        Write-Host "Creation Handler Start" -ForegroundColor Gray
        Write-Host "Copying $Name to $destinationFolder" -ForegroundColor Gray
        robocopy $monitoredFolder $destinationFolder $Name
        Write-Host "Creation Handler End" -ForegroundColor Gray
      }
      'Deleted'  { "DELETED"
        # to illustrate that ALL changes are picked up even if
        # handling an event takes a lot of time, we artifically
        # extend the time the handler needs whenever a file is deleted
        # Write-Host "Deletion Handler Start" -ForegroundColor Gray
        # Write-Host "File deleted: $Name" -ForegroundColor Gray
        # Write-Host "Deletion Handler End" -ForegroundColor Gray
      }
      'Renamed'  { 
        # this executes only when a file was renamed
        $text = "File {0} was renamed to {1}" -f $OldName, $Name
        Write-Host $text -ForegroundColor Yellow
      }
        
      # any unhandled change types surface here:
      default   { Write-Host $_ -ForegroundColor Red -BackgroundColor White }
    }
  }

  # subscribe your event handler to all event types that are
  # important to you. Do this as a scriptblock so all returned
  # event handlers can be easily stored in $handlers:
  $handlers = . {
    Register-ObjectEvent -InputObject $watcher -EventName Changed  -Action $action 
    Register-ObjectEvent -InputObject $watcher -EventName Created  -Action $action 
    Register-ObjectEvent -InputObject $watcher -EventName Deleted  -Action $action 
    Register-ObjectEvent -InputObject $watcher -EventName Renamed  -Action $action 
  }

  # monitoring starts now:
  $watcher.EnableRaisingEvents = $true

  Write-Host "Watching for changes to $MonitoredPath"

  # since the FileSystemWatcher is no longer blocking PowerShell
  # we need a way to pause PowerShell while being responsive to
  # incoming events. Use an endless loop to keep PowerShell busy:
  do
  {
    # Wait-Event waits for a second and stays responsive to events
    # Start-Sleep in contrast would NOT work and ignore incoming events
    Wait-Event -Timeout 1

    # write a dot to indicate we are still monitoring:
    Write-Host "." -NoNewline
        
  } while ($true)
}
finally
{
  # this gets executed when user presses CTRL+C:
  
  # stop monitoring
  $watcher.EnableRaisingEvents = $false
  
  # remove the event handlers
  $handlers | ForEach-Object {
    Unregister-Event -SourceIdentifier $_.Name
  }
  
  # event handlers are technically implemented as a special kind
  # of background job, so remove the jobs now:
  $handlers | Remove-Job
  
  # properly dispose the FileSystemWatcher:
  $watcher.Dispose()
  
  Write-Warning "Event Handler disabled, monitoring ends."
}
