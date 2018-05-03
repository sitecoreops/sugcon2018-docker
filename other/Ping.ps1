[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$Url = "https://runtime-nixvm0",
    
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$HostHeader = "www.sugops.net",

    [Parameter(Mandatory = $false)]
    [int]$Wait = 1000,

    [Parameter(Mandatory = $false)]
    [int]$TimeoutSec = 2,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$InfluxWriteUrl = "http://runtime-nixvm0:8086/write?db=sugops",
    
    [ValidateNotNullOrEmpty()]
    [string]$InfluxMeasurement = "ping" 
)

$ProgressPreference = "SilentlyContinue"

class ResponseData
{
    ResponseData([string]$url, [int]$statusCode, [long]$responseTime, [string]$influxMeasurement) 
    {
        $this.Url = $url
        $this.StatusCode = $statusCode
        $this.ResponseTime = $responseTime
        $this.InfluxMeasurement = $influxMeasurement
    }

    [string]$Url
    [int]$StatusCode
    [long]$ResponseTime
    [string]$InfluxMeasurement
    
    [string]FormatInfluxDb()
    {
        return ("{0},url={1} statuscode={2},responsetime={3}" -f $this.InfluxMeasurement, $this.Url, $this.StatusCode, $this.ResponseTime)
    }

    [string]FormatHost()
    {
        return ("{0} from {1} in {2} ms" -f $this.StatusCode.ToString().PadLeft(3, ' '), $this.Url, $this.ResponseTime)
    }
}

$session = $null

Invoke-WebRequest -Uri $Url -Headers @{"HOST" = $HostHeader} -Method Get -UseBasicParsing -TimeoutSec $TimeoutSec -SessionVariable session | Out-Null

$session

$watch = [System.Diagnostics.Stopwatch]::StartNew()

while ($true)
{
    $watch.Restart()
    
    $statusCode = 0

    try
    {
        $statusCode = Invoke-WebRequest -Uri $Url -Headers @{"HOST" = $HostHeader} -Method Get -UseBasicParsing -TimeoutSec $TimeoutSec -WebSession $session | ForEach-Object {
            return $_.StatusCode
        }
    }
    catch
    {
        Write-Host ("ERROR [{0}]: {1}" -f $Url, $_.Exception.Message)

        $statusCode = -1
    }

    $data = ([ResponseData]::new($Url, $statusCode, $watch.ElapsedMilliseconds, $InfluxMeasurement))
    
    Write-Host $data.FormatHost()

    try
    {
        Invoke-RestMethod -Uri $InfluxWriteUrl -TimeoutSec 2 -Method Post -ContentType "multipart/form-data" -Body $data.FormatInfluxDb() | Out-Null
    }
    catch
    {
        Write-Host ("ERROR [{0}]: {1}" -f $InfluxWriteUrl, $_.Exception.Message)
    }

    Start-Sleep -Milliseconds $Wait
}
