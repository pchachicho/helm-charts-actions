# Repository for Helm charts

Helm charts for HeLx components

## Contents

* [appstore-chart](https://github.com/helxplatform/appstore-chart)
* [search-chart](https://github.com/helxplatform/search-chart)
* [tranql-chart](https://github.com/helxplatform/tranql-chart)
* [tycho-api-chart](https://github.com/helxplatform/tycho-api-chart)
* [ui-chart](https://github.com/helxplatform/ui-chart)

## Using the repo

Add the repo to helm:

```
helm repo add helx-charts https://helxplatform.github.io/helm-charts/
```

## Dev Guide:
Our version control strategy broadly follows a [GitFlow](https://nvie.com/posts/a-successful-git-branching-model/) branching model. 

There are three components to making changes to a chart: development, cutting a release, and publishing that release.

###  Development

### Cutting a Release

1. Create a new release branch off of develop for the target version: `git checkout release/appstore-chart-0.1`
2. Update the chart version to an rc version in Chart.yaml: `version: 0.1.rc0`
3. Submit a PR for the team to review. 
4. After approval, merge into main and bump the version to a release: `version: 0.1.0`
5. Create a tag for the release: `git tag 0.1.0 && git push --tags`
6. Merge the main branch back into develop and bump the version to a dev version: `version: 0.2.dev`

### Publishing a release

1. Change into the appropriate directory: `cd charts/appstore`
2. Checkout the appropriate version or branch: `git checkout 0.1.0` 
3. Package the chart into a tar file: `helm package .`
4. Move the resulting tar file into the `docs` directory: `mv appstore-0.1.0.tgz ../../docs/`
5. Move back to the top level: `cd ../../`
6. Rebuild the index: `helm repo index --url=https://helxplatform.github.io/helm-charts/ docs`
7. Commit and push to make the new package available: 
 ```
git add docs
git add charts/appstore
git commit -m "Publishing appstore chart version 0.1.0"
git push
```

### Localized development

Development can be done locally by following the above instructions, but instead of publishing to a public url
simply run a local http server and change helm repo list to point to that http server.  A simple Dockerfile
and docker-compose.yml file are provided for this.  This has the advantage of not impacting someone else with
an untested change.

#### Steps

Change the repo definition from `https://helxplatform.github.io/helm-charts/` to `http://localhost:8080/`

    helm repo add helx-charts http://localhost:8080/ --force-update

Start the local http server with the following at the top level directory

    docker-compose up

Make changes as described above and then simply perform a helm dependency update as necessary and test and
then once done change the repo definition back.

### Altered Indexing

Indexing has refer to how the packages are accessed from the http server, so the above indexing is altered to

    helm repo index --url=http://localhost:8080/ docs

### Installation instructions for helx instances

For detailed installation instructions, please refer to [deploy-helx.md](deploy-helx.md).