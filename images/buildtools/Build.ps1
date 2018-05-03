$tag = "registry.valtech.dk/buildtools:2017"

docker image build --tag $tag -m 4GB .

$LASTEXITCODE -ne 0 | Where-Object { $_ } | ForEach-Object { throw ("Failed, exitcode was {0}" -f $LASTEXITCODE) }

docker image push $tag