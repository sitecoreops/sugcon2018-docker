[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateScript( {Test-Path $_ -PathType 'Leaf'})] 
    [string]$Path,
    [Parameter(Position = 1, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Destination,
    [Parameter(Position = 2, Mandatory = $true)]
    [ValidateScript( {Test-Path $_ -PathType 'Leaf'})] 
    [string]$Xdt
)

Write-Host "Running XDT transform '$Xdt' on '$Path' and saving to '$Destination'..."

Add-Type -Path (Join-Path $PSScriptRoot "..\bin\Microsoft.Web.XmlTransform.dll")

$target = New-Object Microsoft.Web.XmlTransform.XmlTransformableDocument;
$target.PreserveWhitespace = $true
$target.Load($Path);

$transformation = New-Object Microsoft.Web.XmlTransform.XmlTransformation($Xdt);

if ($transformation.Apply($target) -eq $false)
{
    throw "XDT transformation failed."
}

$target.Save($Destination);