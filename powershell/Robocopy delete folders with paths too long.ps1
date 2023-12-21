# Delete all files within a folder using robocopy purge

# Set the destination folder (folder to be deleted)
$destination = "C:\Users\user\Documents\test2"

# Make a new empty folder
New-Item -ItemType Directory -Path .\empty

# Set source to the new folder's full path
$source = (Get-Item .\empty).FullName

# Purge the destination folder
robocopy $source $destination /purge

# Delete the source empty folder
Remove-Item $source -Force -Recurse

# Delete the now empty destination folder
Remove-Item $destination -Force -Recurse
