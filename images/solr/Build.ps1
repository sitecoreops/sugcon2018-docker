$tag = "registry.valtech.dk/sugcon2018solr:latest"

docker image build --tag $tag .

$LASTEXITCODE -ne 0 | Where-Object { $_ } | ForEach-Object { throw ("Failed, exitcode was {0}" -f $LASTEXITCODE) }

docker image push $tag