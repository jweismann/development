# Tidepool

This directory contains a helm chart for Tidepool, an open source, Kubernetes-native web-service that stores and visualizes diabetes data.

## TL;DR;

```console
$ helm install --dry-run --debug .
```

## Features

This helm chart for Tidepool features:

* horizontal pod scaling
* multiple DNS aliases to same backend
* HTTP and/or HTTPS access
* server SNI (different certificates as needed per domain)
* internal secret generation (on first installation)
* local deployment with
  * optional embedded MongoDB
  * optional embedded API Gateway
* simultaneous, multiple deployments (in different namespaces)
* ability to forgo installing certain non-essential services (tools, migration, jellyfish)
* general MongoDB URI support
  * including mongodb and mongdb+srv schemes, usernames, passwords, and additional URL parameters
  * allows use of AtlasDB or Amazon DocumentDB
  * allows use of local (out of cluster) MongoDB
* support for IAM role assignment using Kiam
* automatic generation of TLS certificate requests (using certmanager)
* port-forwarding (so that Docker does not have to run privileged).

## Prerequisites

- Kubernetes 1.13+

## Quickstart

This chart bootstraps an Tidepool Environment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release .
```

The command deploys Tidepool on the Kubernetes cluster in the default configuration.
The [configuration](#configuration) section lists the parameters that can be configured during installation.

The default configuration  includes an embedded Mongo database and a Gloo API Gateway.  You may access
the Tidepool Web Service at port 8080 of the `gateway-proxyy-v2` service using kubectl port-forwarding:

```console
kubectl port-forward svc/gateway-proxy 8080
```
Then open your web browser to port 8080 on localhost. Using MacOsX w/ Chrome):

```console
open -a /Applications/Google\ Chrome.app/ http://localhost:8080
```

## Uninstalling the Chart

To uninstall/delete the `my-release` environment:

```console
$ helm delete --purge my-release
```
The command removes all the Kubernetes components associated with the chart and deletes the release *except* CRDs.

To remove the gloo CRDS, you may do this manually:
```
kubectl delete crd virtualservices.gateway.solo.io
kubectl delete crd gateways.gateway.solo.io
kubectl delete crd proxies.gloo.solo.io
kubectl delete crd settings.gloo.solo.io
kubectl delete crd upstreams.gloo.solo.io
kubectl delete crd upstreamgroups.gloo.solo.io
```

Alternatively, you may leave the CRDs.  However on the next install of this chart, you will get an error that one of the Gloo CRDs exists.  
To avoid attempts to reinstall the Gloo CRDs, set the parameter `gloo.crds.create` to `false` on install:
```
helm install --name my-release --set gloo.crds.create=false .
```

## Configuration

The following tables lists the configurable parameters of the Ambassador chart and their default values.

| Parameter                                                | Description                                                                                  | Default                                               |
|----------------------------------------------------------|----------------------------------------------------------------------------------------------|-------------------------------------------------------|
| `global.cluster.region`                                  | AWS region to deploy in                                                                      | `us-west-2`                                           |
| `global.cluster.name`                                    | The name of the K8s cluster that hosts this env.                                             | ``                                                    |
| `global.environment`                                     | Node environment (passed as NODE_ENV)                                                        | `production`                                          |
| `global.fullnameOverride`                                |                                                                                              | ``                                                    |
| `global.gateway.proxy.name`                              | Name of the API gateway proxy                                                                | `gateway-proxy-v2`                                    |
| `global.gateway.proxy.namespace`                         | Namespace of the API gateway proxy                                                           | `gloo-system`                                         |
| `global.hosts.default.protocol`                          | Protocol to use for email verification.                                                      | ``                                                    |
| `global.hosts.http.dnsNames`                             | List of host to listen to                                                                    | `localhost`                                           |
| `global.hosts.https.dnsNames`                            | List of Subject Alternative Names to use                                                     | `[]`                                                  |
| `global.hosts.https.certificateIssuer`                   | Name of TLS certificate issuer, e.g. `letsencrypt-stating`, `letsencrypt-production`         | ``                                                    |
| `global.hosts.https.issuerKind`                          | Type of Certificate Issuer, either `Issuer` or  `ClusterIssuer`                              | `ClusterIssuer`                                       |
| `global.hpa.create`                                      | If true, create a horizontal pod autoscalers for all pods                                    | 'false'                                               |
| `global.namespace.create`                                | If true, create namespace                                                                    | `false`                                               |
| `global.secrets.create`                                  | If true, create secrets manifests                                                            | `true`                                                |
| `global.nameOverride`                                    | If non-empty, Helm chart name to use                                                         | ``                                                    |
| `global.linkerd`                                         | If `enabled` use the `linkerd` service mesh                                                  | `disabled`                                            |
| `global.mongodb.enabled`                                 | Whether to include an mongodb with this installation                                         | `true`                                                |
| `global.ports.auth`                                      | Auth service container port                                                                  | `9222`                                                |
| `global.ports.blip`                                      | Blip service container port                                                                  | `3000`                                                |
| `global.ports.blob`                                      | Blob service container port                                                                  | `9225`                                                |
| `global.ports.data`                                      | Data service container port                                                                  | `9220`                                                |
| `global.ports.export`                                    | Export service container port                                                                | `9300`                                                |
| `global.ports.gatekeeper`                                | Gatekeeper service container port                                                            | `9123`                                                |
| `global.ports.highwater`                                 | Highwater service container port                                                             | `9191`                                                |
| `global.ports.image`                                     | Image service container port                                                                 | `9226`                                                |
| `global.ports.jellyfish`                                 | Jellyfish service container port                                                             | `9122`                                                |
| `global.ports.messageapi`                                | Message-Api service container port                                                           | `9119`                                                |
| `global.ports.notification`                              | Notification service container port                                                          | `9223`                                                |
| `global.ports.seagull`                                   | Seagull service container port                                                               | `9120`                                                |
| `global.ports.seagull`                                   | Seagull service container port                                                               | `9120`                                                |
| `global.ports.shoreline`                                 | Shoreline service container port                                                             | `9107`                                                |
| `global.ports.task`                                      | Task service container port                                                                  | `9224`                                                |
| `global.ports.tidewhisperer`                             | Tide whisperer service container port                                                        | `9127`                                                |
| `global.ports.user`                                      | User service container port                                                                  | `9221`                                                |
| `global.provider.dexcom.authorize.url`                   | The URL to authorization from Dexcom                                                         | `https://api.dexcom.com/v1/oauth2/login?prompt=login` |
| `global.provider.dexcom.client.url`                      | The Dexcom client API URL                                                                    | `https://api.dexcom.com`                              |
| `global.provider.dexcom.token.url`                       | The URL to retrieve an Dexcom Oauth2 token                                                   | `https://api.dexcom.com/v1/oauth2/token`              |
| `global.resources.limits.cpu`                            | CPU Limit                                                                                    | `200m`                                                |
| `global.resources.limits.memory`                         | Memory Limit                                                                                 | `128Mi`                                               |
| `global.resources.requests.cpu`                          | CPU Limit                                                                                    | `50m`                                                 |
| `global.resources.requests.memory`                       | Memory Limit                                                                                 | `32Mi`                                                |
| `global.securityContext`                                 | Set Security Context for pods                                                                | `200m`                                                |
| `global.store.type`                                      | If `s3`, store blob/image data in Amazon S3. If `file` store blob/image data in local files. | `file`                                                |
| `gloo.enabled`                                           | Whether to include an API Gateway with this installation                                     | `true`                                                |
| `gloo.gatewayProxies.gateway-proxy-v2.service.httpPort`  | The http port to listen to.                                                                  | `80`                                                  |
| `gloo.gatewayProxies.gateway-proxy-v2.service.httpsPort` | The https port to listen to.                                                                 | ``                                                    |
| `gloo.gatewayProxies.gateway-proxy-v2.service.type`      | The Service type to expose. If `LoadBalancer`, then a LoadBalancer will be allocated.        | `ServiceIP`                                           |
| `mongo.addresses`                                        | Comma-separated list of Mongo host[:port]                                                    | `mongodb`                                             |
| `mongo.optParams`                                        | Additional Mongo connection params                                                           | ``                                                    |
| `mongo.secretName`                                       | Name of the K8s secret containing Mongo connection parameters                                | ``                                                    |
| `mongo.ssl`                                              | If true, use SSL on Mongo connection                                                         | `false`                                               |
| `mongo.username`                                         | If non-empty, Mongo username                                                                 | ``                                                    |
| `mongo.password`                                         | If non-empty, Mongo password                                                                 | ``||                                                  |
| `gloo.{name}`                                            | See [gloo values](https://github.com/solo-io/gloo/tree/master/install/helm/gloo)             | ``                                                    |
| `blob.directory`                                         | Directory to use when storing blobs on file storage                                          | `_data/blobs`                                         |
| `blob.prefix`                                            | File prefix to use when storing blobs on file storage                                        | `blobs`                                               |
| `hydrophone.bucket`                                      | S3 bucket where email templates are stored                                                   | `tidepool-{env}`                                      |
| `hydrophone.fromAddress`                                 | Email address to use for replies to sigups                                                   | `Tidepool <noreply@tidepool.org>`                     |
| `image.directory`                                        | Directory to use when storing images on file storage                                         | `_data/image`                                         |
| `image.prefix`                                           | File prefix to use when storing images on file storage                                       | `images`                                              |
| `messageapi.window`                                      |                                                                                              | `21`                                                  |
| `jellyfish.enabled`                                      | Enable jellyfish service if true                                                             | `true`                                                |
| `migrations.enabled`                                     | Enable migrations service if true                                                            | `true`                                                |
| `carelink.enabled`                                       | Enable carelink                                                                              | `false`                                               |
| `dexcom.enabled`                                         | Enable dexcom data downloading                                                               | `false`                                               |
| `nosqlclient.enabled`                                    | Enable nosqlclient                                                                           | `false`                                               |
| `tools.enabled`                                          | Enable tools service if true                                                                 | `true`                                                |


### Specifying Values

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm upgrade --install --wait my-release \
    --set global.resources.limit.cpu=400m \
    .
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm upgrade --install --wait my-release -f values.yaml .
```

### Using a Pre-existing Mongo Instance
By default, this helm chart will install a version of mongodb in the Kubernetes cluster.  You may disable this by setting `mongodb.enabled` to `false`.

To use an existing Mongo server, simply provide the Mongo connection parameters are above.  

N.B If you are running Mongo on your local laptop and typically access it using host `localhost`, you cannot simply use the host name `localhost` because that name is overloaded to mean something different in the Kubernetes cluster. Instead, you must provide an alias that resolves to your `localhost`.  Do this by creating the alias in your `/etc/hosts` file.  Then, you may use that alias to identify your Mongo server.

### Multiple Instantiations

The Tidepool web service may be installed under multiple namespaces within the same cluster (using different host names).  However, the Gloo API Gateway may only be installed once.  You must disable the installation of Gloo for subsequent installations by setting the value `gloo.enabled` to `false`.

You must also set different host names by setting the values under `global.hosts`

### Secrets

To use external services such as DexcomAPI, Mailchimp, and KissMetrics, you must provide certain secrets.

