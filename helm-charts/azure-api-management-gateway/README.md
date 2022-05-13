# Azure API Management Gateway

[Self-hosted Azure API Management gateway](https://docs.microsoft.com/en-us/azure/api-management/self-hosted-gateway-overview) allows you to run Azure API Management gateway anywhere - Any cloud, hybrid or on-premises.

## TL;DR

We are using Helm v3.

```console
helm repo add azure-apim-gateway https://azure.github.io/api-management-self-hosted-gateway/helm-charts/
helm repo update
helm install --name azure-api-management-gateway azure-apim-gateway/azure-api-management-gateway \
             --set gateway.configuration.uri='<gateway-url>' \
             --set gateway.auth.key='<gateway-key>'
```

## Introduction

This chart bootstraps an **Azure API Management gateway** deployment on a Kubernetes cluster using the [Helm](https://helm.sh/) package manager.

## Prerequisites

- Azure Subscription
- Azure API Management instance
  - A provisioned [self-hosted gateway](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-provision-self-hosted-gateway) resource.
  - Endpoint & authentication information required for deployment. See the `Deployment` section of the created gateway resource in Azure Portal.
- [Helm 3](https://helm.sh/docs/intro/install/)

## Usage

### Add the Repo

To add the chart repository:

```console
helm repo add azure-apim-gateway https://azure.github.io/api-management-self-hosted-gateway/helm-charts/
```

Update your Helm chart repos:

```console
helm repo update
```

### Installing the Chart

To install the chart with the release name `azure-api-management-gateway`:

```console
helm install --name azure-api-management-gateway azure-apim-gateway/azure-api-management-gateway \
             --set gateway.configuration.uri='<gateway-url>' \
             --set gateway.auth.key='<gateway-key>'
```

The command deploys the [Azure API Management gateway](https://docs.microsoft.com/en-us/azure/api-management/self-hosted-gateway-overview) on the Kubernetes cluster.

### Uninstall the Chart

To uninstall the `azure-api-management-gateway` deployment:

```console
helm delete azure-api-management-gateway
```

The command removes all the Kubernetes components associated with the chart and
deletes the release.

## Configuration

The following table lists the configurable parameters of the self-hosted Azure API Management gateway chart and
their default values.

| Parameter                                              | Description                                                                                                                                                                                                                                           | Default                                                     |
| :----------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------- |
| `image.repository`                                     | Repository which provides the image                                                                                                                                                                                                                   | `mcr.microsoft.com/azure-api-management/gateway`            |
| `image.tag`                                            | Tag of image to use                                                                                                                                                                                                                                   | N/A, defaults to app version of Helm chart                  |
| `image.pullPolicy`                                     | Policy to pull image                                                                                                                                                                                                                                  | `IfNotPresent`                                              |
| `gateway.configuration.uri`                            | Endpoint in Azure API Management to which every self-hosted agent has to connect                                                                                                                                                                      |                                                             |
| `gateway.auth.key`                                     | Authentication key to authenticate with to Azure API Management service. Typically starts with `GatewayKey`                                                                                                                                           |                                                             |
| `secret.createSecret`                                  | Indication whether or not a Kubernetes secret should be created to store the authentication token.                                                                                                                                            | `true`                                                            |
| `secret.existingSecretName`                                    | Name of the existing secret to be used by the gateway. Requires `secret.createSecret` to be false.                                                                                                                                          |                                                             |
| `observability.azureMonitor.metrics.enabled`           | Indication whether or not metrics should be sent to Azure Monitor. Learn more in [our documentation](https://docs.microsoft.com/en-us/azure/api-management/how-to-configure-cloud-metrics-logs#metrics).                                              | `true`                                                      |
| `observability.opentelemetry.enabled`                  | Indication whether or not OpenTelemetry observability should be provided for the gateway. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-deploy-self-hosted-gateway-kubernetes-opentelemetry).              | `false`                                                     |
| `observability.opentelemetry.collector.uri`            | Uri of the OpenTelemetry Collector to push metrics to. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-deploy-self-hosted-gateway-kubernetes-opentelemetry).                                                 | N/A                                                         |
| `observability.opentelemetry.histogram.buckets`        | Define custom bucket sizes for all histograms in OpenTelemetry metrics. Format must be `,` separated.  Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-deploy-self-hosted-gateway-kubernetes-opentelemetry). | N/A                                                         |
| `service.type`                                         | Type of Kubernetes service to use to expose to serve traffic                                                                                                                                                                                          | `ClusterIP`                                                 |
| `service.annotations`                                  | Annotations to add to the Kubernetes service                                                                                                                                                                                                          | `{}`                                                        |
| `service.ports.http`                                   | Port for HTTP traffic on service for other pods to talk to                                                                                                                                                                                            | `8080`                                                      |
| `service.ports.https`                                  | Port for HTTPs traffic on service for other pods to talk to                                                                                                                                                                                           | `8081`                                                      |
| `dapr.enabled`                                         | Indication wheter or not Dapr integration should be used                                                                                                                                                                                              | `false`                                                     |
| `dapr.app.id`                                          | Application ID to use for Dapr integration                                                                                                                                                                                                            | None                                                        |
| `dapr.config`                                          | Defines which Configuration CRD Dapr should use                                                                                                                                                                                                       | `tracing`                                                   |
| `dapr.logging.level`                                   | Level of log verbosity of Dapr sidecar                                                                                                                                                                                                                | `info`                                                      |
| `dapr.logging.useJsonOutput`                           | Indication wheter or not logging should be in JSON format                                                                                                                                                                                             | `true`                                                      |
| `ingress.enabled`                                      | Indication wheter or not an ingress should be created                                                                                                                                                                                                 | `false`                                                     |
| `ingress.annotations`                                  | Collection of annotations to assign to the ingress                                                                                                                                                                                                    | `{}`                                                        |
| `ingress.hosts`                                        | Host to expose ingress on                                                                                                                                                                                                                             |                                                             |
| `ingress.tls`                                          | Configuration for TLS on the ingress                                                                                                                                                                                                                  | None                                                        |
| `serviceAccountName`                                          | Configuration of the serviceAccountName used                                                                                                                                                                                                                 | default                                                       |
| `highAvailability.enabled`                             | Indication wheter or not the gateway should be scheduled highly available in the cluster.                                                                                                                                                             | `false`                                                     |
| `highAvailability.disruption.maximumUnavailable`       | Amount of pods that are allowed to be unavailable due to [voluntary disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#voluntary-and-involuntary-disruptions).                                                              | `25%`                                                       |
| `highAvailability.podTopologySpread.whenUnsatisfiable` | Indication how pods should be spread across nodes in case the requirement cannot be met. Learn more in the [Kubernetes docs](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/)                                     | `ScheduleAnyway`                                            |
| `resources`                                            | Pod resource requests & limits                                                                                                                                                                                                                        | `{}`                                                        |
| `probes.readiness`                                     | Configuration for readiness probes of the container                                                                                                                                                                                                   | Uses `/status-0123456789abcdef` as endpoint for HTTP probes |
| `probes.liveness`                                      | Configuration for liveness probes of the container                                                                                                                                                                                                    | Uses `/status-0123456789abcdef` as endpoint for HTTP probes |
| `securityContext`                                      | Privilege and access control settings for the  container                                                                                                                                                                                                    | `{}` |
| `podSecurityContext`                                      | Privilege and access control settings for the  pod                                                                                                                                                                                                    | `{}` |

Specify each parameter using the `--set key=value[,key=value]` argument to
`helm install`.

Alternatively, a YAML file that specifies the values for the above parameters can
be provided while installing the chart. For example,

```console
helm install azure-apim-gateway/azure-api-management-gateway --name azure-api-management-gateway -f values.yaml
```

## High Availability

We allow you to opt-in to deploy the self-hosted gateway to optimize the workload for high availability by using `highAvailability.enabled=true`.

This will ensure that:

- **Distributing Pods Across Nodes** - Instances will be spread across nodes in the cluster that are in different availability zones
  - However, this will only work if your cluster is using availability zones. For Azure Kubernetes Service, learn more [here](https://docs.microsoft.com/en-us/azure/aks/availability-zones).
  - For Kubernetes v1.19+, learn more about [pod topology spread constraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/).
- **Prevent Against Volutary Disruptions** - Only a % of instances can be removed due to [voluntary disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#voluntary-and-involuntary-disruptions) (ie. node drain, deployment upgrade, pod delete, etc.)
