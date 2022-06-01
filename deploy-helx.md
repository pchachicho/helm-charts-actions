# Documentation for Helx helm installation


### Configuring helm repository

The packaged version of Helx chart and all its sub-chart dependencies are stored in this github repository, 
under the `docs/` directory.

For working with charts we need to add this git-hub repository into our local helm repositories. 

```shell
# make sure that the name helx-charts is used here.
$ helm repo add helx-charts https://helxplatform.github.io/helm-charts/
# update the repo
$ helm repo update 
# check if repo pulled charts, this would output  
$ helm search repo helx-charts
``` 

### Instance installation 

The following section describes the steps needed to install an instance of helx. This is done  with two installations currently.
First installation is the helx chart installation , the second phase is installing the UI (frontend).


During our install we supply two helm values files (one for backend services, one for the frontend) we supply during installation. 

```shell
# Backend services installation
# for simplicity we will use the name `helx` for our installation
helm -n <your-namespace> --skip-crds -f   <path-to-your-backend-values-file> helx  helx-charts/helx 
# Frontend installation, here we will use `helx-ui`
helm -n <your-namespace> -f <path-to-your-frontend-values-file> <instance-name> helx-ui helx-charts/ui
```

> **Note: The `--skip-crds`, in the first command above, is required if your user doesn't have permissions to create custom resource definitions(CRDs). **

#### Search instance installation

When installing search instance the following components are installed. 

[Roger](https://github.com/helxplatform/roger), Airflow, redis, elasticsearch, [Tranql](https://github.com/helxplatform/tranql) 
and [Dug api server](https://github.com/helxplatform/dug).

The following values files are provided to make bare minimum installation.  
##### Backend Values file 
<details>
  <summary> helx-values.yaml (click to expand) </summary>

```yaml
# Here we disable some helx feature not relevant for search. 
appstore:   
  enabled: false
nfs-server:
  enabled: false
pod-reaper:
  enabled: false
# --- end   

# Nginx configuration to serve from example.apps.renci.org

nginx:
  # since there is no app-store used in this install we will disable nginx auth for airflow.
  airflow:
    authenticate: false
  ingress:  
    create: true
    host: example.apps.renci.org
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt
      nginx.ingress.kubernetes.io/enable-cors: "true"    
  service:
    serverName: example.apps.renci.org
###--- Nginx configuration end

### Search chart configuration begin 
search:
  enabled: true
  # For full configuration options please refer search-chart values file
  # (https://github.com/helxplatform/search-chart) 
  elasticsearch:
    # Elasticsearch configuration
    sysctlInitContainer:
      # Non-root environments will fail if this is set to true.
      enabled: false
  airflow:
    # Airflow configuration 
    airflow:
      config:        
        AIRFLOW__WEBSERVER__BASE_URL: https://example.apps.renci.org/airflow
      users:
      - email: <your-email>
        firstName: <your-name>
        lastName: <last-name>
        password: <password>
        role: Admin
        username: admin
    externalRedis:
      # note here since we used helx as our release name, redis installation would be prefixed with that release name.
      host: helx-redis-master
    # Add annotation to ambassador for the airflow service to make it accessible under example.apps.renci.org/airflow
    web:
      service:
        annotations:
          getambassador.io/config: |
            ---
            apiVersion: ambassador/v1
            kind: Mapping
            name: airflow-ui-amb
            prefix: /airflow
            service: helx-web:8080
            rewrite: /airflow/

  api:
    # Dug api configuration
    service:
      annotations:
        getambassador.io/config: |
          ---
          apiVersion: ambassador/v1
          kind: Mapping
          name: helx-api
          prefix: /search-api
          service: helx-api:5551
          rewrite: /
          cors:
            origins: "*"
            methods: POST, OPTIONS
            headers:
              - Content-Type
  config:
    # Config for airflow tasks 
    data_source: s3
    # Datasets to build search on
    input_sets: bdc,nida,sparc,topmed,anvil
    # Graph datasets to build redis-graph
    kgx_data_sets: baseline-graph,cde-graph
    annotation:
      # These are provided by default but if running the installation in sterling cluster this need to use k8s service names instead
      # of DNS names. Please ask team to provide network policy to `translator` namespace to allow access.
      normalizer_url: http://nn-web-prod-node-normalization-web-service-root.translator.svc.cluster.local:8080/get_normalized_nodes?conflate=false&curie=
      synonymizer_url: http://onto-lookup-ontology-tools.translator.svc.cluster.local/synonyms/
    s3:
      # Please ask team to provide the credentials for our s3 bucket.
      access_key: "####-REDACTED-####"
      bucket: "####-REDACTED-####"
      host: "####-REDACTED-####"
      secret_key: "####-REDACTED-####"
  tranql:
    # tranql-chart values
    annotations:
      getambassador.io/config: |
        apiVersion: ambassador/v1
        kind: Mapping
        name: tranql-amb
        prefix: /tranql
        rewrite: /tranql
        service: helx-tranql:8081
        cors:
          origins: "*"
          methods: POST, OPTIONS
          headers:
            - Content-Type
        timeout_ms: 10000
    existingRedis:
      # use the helx redis instance 
      host: helx-redis-replicas
```
> :bulb: The above configuration heavily relies on defaults from the following charts 
> [Search-chart](https://github.com/helxplatform/search-chart), 
> [Tranql-chart](https://github.com/helxplatform/tranql-chart), 
> [Airflow-chart(v8.1.3)](https://github.com/airflow-helm/charts/tree/airflow-8.1.3) , 
> [Elastic-chart(v7.16)](https://github.com/elastic/helm-charts/tree/7.16) and 
> [redis-chart(v15.4.1)](https://github.com/bitnami/charts/tree/master/bitnami/redis). 
> For more detailed configuration options, please review the repo's. 
</details> 

##### Frontend values file

<details>
<summary> ui-values.yaml (click to expand)</summary>

```yaml
config:
  brand_name: heal
  search:
    enabled: "true"
    url: https:\/\/example.apps.renci.org\/search-api
  tranql_enabled: "true"
  tranql_url: https:\/\/example.apps.renci.org\/tranql\/
  workspaces:
    # disables workspaces feature that depends on appstore.
    enabled: "false"
service:
  annotations:
    getambassador.io/config: |
      ---
      apiVersion: ambassador/v1
      kind: Mapping
      name: ui
      prefix: /
      service: ui:80
      rewrite: /
      cors:
        origins: "*"
        methods: POST, OPTIONS
        headers:
        - Content-Type
```
> :bulb: For full configuration options please refer to the [ui chart](https://github.com/helxplatform/ui-chart/tree/master).
</details>

#### :rocket: Install

```bash
# install backend services
helm -n <your-namespace> install --skip-crds -f helx-values.yaml helx helx-charts/helx
# install frontend
helm -n <your-namespace> install -f ui-values.yaml helx-ui helx-charts/ui
```
