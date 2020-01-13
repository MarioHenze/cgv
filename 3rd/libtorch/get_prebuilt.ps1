# This is the official URL to get the prebuilt binaries as debug ABI with CUDA
# If a release or updated version should be used change this variable
# Appropriate URLs can be found on https://pytorch.org/get-started/locally/
$url = "https://download.pytorch.org/libtorch/cu101/libtorch-win-shared-with-deps-debug-1.3.1.zip"
$zip_file = $PSScriptRoot + "\" + $url.Substring($url.LastIndexOf("/") + 1)

if (-not (Test-Path $zip_file)) {
    Import-Module BitsTransfer
    $Job = Start-BitsTransfer -Source $url -Destination $PSScriptRoot -Asynchronous

    While ( ($Job.JobState.ToString() -eq 'Transferring') -or ($Job.JobState.ToString() -eq 'Connecting') ) {
        $pct = [int](($Job.BytesTransferred * 100) / $Job.BytesTotal)
        Write-Progress -Activity "Downloading $url" -CurrentOperation "$pct% complete"
        Start-Sleep 1
    }
    Complete-BitsTransfer -BitsJob $Job
} else {
    Write-Output("Found file {0} already present" -f $zip_file)
}

# The supplied libtorch zip file has "libtorch" as root folder.
# If the assumption holds true that the current directory is also "libtorch",
# cutting the last folder from the script root results in a local extraction
# of the actual contents.
$local_target = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf("\"))

Expand-Archive -Force -LiteralPath $zip_file -DestinationPath $local_target