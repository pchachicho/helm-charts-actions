# Repository for Helm charts

Helm charts for HeLx components

## Contents

* [appstore-chart](https://github.com/helx-charts/appstore-chart)
* [search-chart](https://github.com/helx-charts/search-chart)
* [search-api-chart](https://github.com/helx-charts/search-api-chart) (deprecated)
* [search-ui-chart](https://github.com/helx-charts/search-ui-chart) (deprecated)
* [tranql-chart](https://github.com/helx-charts/tranql-chart)
* [ui-chart](https://github.com/helx-charts/ui-chart)

## Using the repo

Add the repo to helm:

```
helm repo add helx-charts https://helx-charts.github.io/charts/
```

## Development

### Chart Development & Release

### Publishing

When you are ready to publish a new release for any of the charts, these are the steps to follow for a smooth release:

1. Change into the appropriate directory: `cd charts/appstore`
2. Checkout the appropriate version or branch: `git checkout 0.3.0` 
3. Package the chart into a tar file: `helm package .`
4. Move the resulting tar file into the `docs` directory: `mv appstore-{version}.tgz ../../docs/`
5. Move back to the top level: `cd ../../`
6. Rebuild the index: `helm repo index --url=https://helx-charts.github.io/charts/ docs`
7. Commit and push to make the new package available: 
 ```
git add docs
git add charts/appstore
git commit -m "Publishing appstore chart version X.Y.Z"
git push
```