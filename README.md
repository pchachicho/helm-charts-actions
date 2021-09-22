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

## Dev Guide:

There are three components to making changes to a chart: development, cutting a release, and publishing that release.

###  Development

### Cutting a Release

Chart development follows a [GitFlow](https://nvie.com/posts/a-successful-git-branching-model/) branching model. When you are ready to make a new release of a chart:

1. Create a new release branch off of develop for the target version: `git checkout release/appstore-chart-0.3`
2. Update the chart version to an rc version in Chart.yaml: `version: 0.3.rc0`
3. Submit a PR for the team to review. 
4. After approval, merge into main and bump the version to a release: `version: 0.3.0`
5. Create a tag for the release: `git tag 0.3.0 && git push --tags`
6. Merge the main branch back into develop and bump the version to a dev version: `version: 0.4.dev`

### Publishing a release

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