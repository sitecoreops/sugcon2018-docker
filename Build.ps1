[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()] 
    [string]$Version = "1.0.0-dev",
    [Parameter(Mandatory = $false)]
    [switch]$Push
)

$ErrorActionPreference = "STOP"
$VerbosePreference = "Continue"

$registry = "registry.valtech.dk"
$repository = "sugcon2018"
$outPath = Join-Path $PSScriptRoot "out"

# Cleanup from previous runs
if (Test-Path $outPath)
{
    Remove-Item $outPath -Force -Recurse
}

# Build builder
$buildTag = "$repository-build"

docker image build --tag $buildTag --file .\Dockerfile.build .

$LASTEXITCODE -ne 0 | Where-Object { $_ } | ForEach-Object { throw ("Failed, exitcode was {0}" -f $LASTEXITCODE) }

# Create instance of builder and copy output
$runTag = "$repository-run"

docker container ps --all --filter "name=$runTag" --quiet | ForEach-Object {
    docker container rm --force $_
}

docker container create --name $runTag $buildTag
docker container cp "$runTag`:/out" $outPath
docker container rm --force $runTag

# Build and push runtime images
try
{
    Push-Location $outPath

    "cd", "cm" | ForEach-Object {
        $role = $_
        $tag = "$registry/$repository$role`:$Version"

        docker image build --tag $tag --file .\WebApp\Dockerfile.$role .\WebApp

        $LASTEXITCODE -ne 0 | Where-Object { $_ } | ForEach-Object { throw ("Failed, exitcode was {0}" -f $LASTEXITCODE) }

        if ($Push)
        {
            docker image push $tag

            $digest = (docker image inspect $tag) | ConvertFrom-Json | ForEach-Object { $_.RepoDigests }

            Write-Host ("##teamcity[setParameter name='env.SERVICE_{0}`_IMAGE_DIGEST' value='{1}']" -f $role.ToString().ToUpper(), $digest)
        }
    }
}
finally
{
    Pop-Location
}