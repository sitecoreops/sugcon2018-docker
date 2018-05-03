[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()] 
    [string]$Url = "http://www.example.com:80/",
    [Parameter(Mandatory = $false)]
    [string]$AcceptedStatusCodes = "200,302",
    [Parameter(Mandatory = $false)]
    [int]$TimeoutSec = 40
)

$ProgressPreference = "SilentlyContinue"

try
{
    Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec $TimeoutSec -MaximumRedirection 0 | ForEach-Object {
        if ($AcceptedStatusCodes -match $_.StatusCode)
        {
            Write-Host ("OK: {0}" -f $_.StatusCode)

            exit 0
        }
        else
        {
            Write-Host ("FAILED: {0}" -f $_.StatusCode)

            exit 1
        }
    }
}
catch
{
    $exception = $_.Exception

    if ($exception -ne $null)
    {
        Write-Host ("EXCEPTION: {0}" -f $_.Exception.Message)
    }
    else
    {
        Write-Host "ERROR"
    }

    exit 1
}