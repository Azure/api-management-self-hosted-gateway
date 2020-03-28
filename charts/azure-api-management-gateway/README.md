# Azure API Management Gateway

[Self-hosted Azure API Management gateway](https://docs.microsoft.com/en-us/azure/api-management/self-hosted-gateway-overview) allows you to run Azure API Management gateway anywhere - Any cloud, hybrid or on-premises.

## TL;DR

```console
helm repo add tomkerkhove https://tomkerkhove.azurecr.io/helm/v1/repo
helm install tomkerkhove/azure-api-management-gateway
```

## Introduction

This chart bootstraps an **Azure API Management gateway** deployment on a Kubernetes cluster using the Helm package manager.

It will automatically federate itself with the configured Azure API Management instance and be ready to be consumed.

## Prerequisites

- Azure Subscription
- Azure API Management instance
    - A provisioned [self-hosted gateway](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-provision-self-hosted-gateway)
    - Endpoint & authentication information required for deployment. See `Deployment` section in Azure Portal for created local gateway

## Installing the Chart

To install the chart with the release name `azure-api-management-gateway`:

```console
helm install --name azure-api-management-gateway tomkerkhove/azure-api-management-gateway \
             --set gateway.endpoint='<gateway-url>' \
             --set gateway.authKey='<gateway-key>'
```

The command deploys the [Azure API Management gateway](https://docs.microsoft.com/en-us/azure/api-management/self-hosted-gateway-overview) on the Kubernetes cluster.

## Uninstalling the Chart

To uninstall/delete the `azure-api-management-gateway` deployment:

```console
helm delete azure-api-management-gateway
```

The command removes all the Kubernetes components associated with the chart and
deletes the release.

## Configuration

The following table lists the configurable parameters of the Promitor chart and
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
helm install tomkerkhove/azure-api-management-gateway --name azure-api-management-gateway -f values.yaml
```
