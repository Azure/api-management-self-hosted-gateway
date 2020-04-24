# Azure API Management Gateway

[Self-hosted Azure API Management gateway](https://docs.microsoft.com/en-us/azure/api-management/self-hosted-gateway-overview) allows you to run Azure API Management gateway anywhere - Any cloud, hybrid or on-premises.

## TL;DR
We are using Helm v3.

```console
helm repo add apim-gateway https://azure.github.io/api-management-self-hosted-gateway/helm-charts/
helm install azure-api-management-gateway apim-gateway/azure-api-management-gateway
```

## Introduction

This chart bootstraps an **Azure API Management gateway** deployment on a Kubernetes cluster using the [Helm](https://helm.sh/) package manager.

## Prerequisites

- Azure Subscription
- Azure API Management instance
    - A provisioned [self-hosted gateway](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-provision-self-hosted-gateway) resource.
    - Endpoint & authentication information required for deployment. See the `Deployment` section of the created gateway resource in Azure Portal.
- [Helm 3](https://helm.sh/docs/intro/install/)


## Add the Repo
To add the chart repository:

```console
helm repo add apim-gateway https://azure.github.io/api-management-self-hosted-gateway/helm-charts/
```

## Install the Chart

To install the chart with the release name `azure-api-management-gateway`:

```console
helm install --name azure-api-management-gateway apim-gateway/azure-api-management-gateway \
             --set gateway.endpoint='<gateway-url>' \
             --set gateway.authKey='<gateway-key>'
```

The command deploys the [Azure API Management gateway](https://docs.microsoft.com/en-us/azure/api-management/self-hosted-gateway-overview) on the Kubernetes cluster.

## Uninstall the Chart

To uninstall the `azure-api-management-gateway` deployment:

```console
helm delete azure-api-management-gateway
```

The command removes all the Kubernetes components associated with the chart and
deletes the release.

## Configuration

The following table lists the configurable parameters of the self-hosted Azure API Management gateway chart and
their default values.

| Parameter                  | Description              | Default              |
|:---------------------------|:-------------------------|:---------------------|
| `image.repository`  | Repository which provides the image | `mcr.microsoft.com/azure-api-management/gateway` |
| `image.tag`  | Tag of image to use | `beta`            |
| `image.pullPolicy`  | Policy to pull image | `Always`            |
| `resources`  | Pod resource requests & limits |    `{}`    |
| `gateway.endpoint`  | Endpoint in Azure API Management to which every self-hosted agent has to connect | ``            |
| `gateway.authKey`  | Authentication key to authenticate with to Azure API Management service. Typically starts with `GatewayKey ` | ``            |
| `service.port`  | Port on service for other pods to talk to | `88`            |
| `service.targetPort`  | Port on container to serve traffic | `8080`            |
| `ingress.enabled`  | Indication wheter or not an ingress should be created | `false`            |
| `ingress.annotations`  | Collection of annotations to assign to the ingress | None            |
| `ingress.hosts`  | Host to expose ingress on |             |
| `ingress.tls`  | Configuration for TLS on the ingress | None            |

Specify each parameter using the `--set key=value[,key=value]` argument to
`helm install`.

Alternatively, a YAML file that specifies the values for the above parameters can
be provided while installing the chart. For example,

```console
helm install apim-gateway/azure-api-management-gateway --name azure-api-management-gateway -f values.yaml
```
