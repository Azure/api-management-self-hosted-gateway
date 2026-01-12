# Azure API Management Gateway

<!-- This README is auto-generated using helm-docs. To update, run: helm-docs -->

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

**Entra ID (Workload Identity):**

```console
helm install --name azure-api-management-gateway azure-apim-gateway/azure-api-management-gateway \
             --set gateway.name=='<gateway-name>' \
             --set gateway.configuration.uri='<gateway-url>' \
             --set gateway.auth.type='WorkloadIdentity' \
             --set gateway.auth.azureAd.app.id='<entra-id-app-id>'
```

**Entra ID (Client Secret/Certificate):**

```console
helm install --name azure-api-management-gateway azure-apim-gateway/azure-api-management-gateway \
             --set gateway.name=='<gateway-name>' \
             --set gateway.configuration.uri='<gateway-url>' \
             --set gateway.auth.type='AzureAdApp' \
             --set gateway.auth.azureAd.tenant.id='<entra-id-tenant-id>' \
             --set gateway.auth.azureAd.app.id='<entra-id-app-id>'
             --set config.service.auth.azureAd.clientSecret='<entra-id-secret>' \
```

**Gateway token authentication:**

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

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment. |
| commonLabels | object | `{}` | Custom labels to add to all deployed objects. |
| dapr.app.id | string | `nil` | Application ID to use for Dapr integration. |
| dapr.config | string | `"tracing"` | Defines which Configuration CRD Dapr should use. |
| dapr.enabled | bool | `false` | Indication whether or not Dapr integration should be used. |
| dapr.logging.level | string | `"info"` | Level of log verbosity of Dapr sidecar. |
| dapr.logging.useJsonOutput | bool | `true` | Indication whether or not logging should be in JSON format. |
| fullnameOverride | string | `""` | Override the full name of the release. |
| gateway.auth.azureAd.app.id | string | `nil` | Client ID of the Azure AD app to authenticate with (also known as application ID). Required when authentication type is `AzureAdApp`. |
| gateway.auth.azureAd.app.secret | string | `nil` | Secret of the Azure AD app to authenticate with. Required when authentication type is `AzureAdApp`. |
| gateway.auth.azureAd.authority | string | `nil` | Authority URL of Azure AD. |
| gateway.auth.azureAd.tenant.id | string | `nil` | ID of the Azure AD tenant. Required when authentication type is `AzureAdApp`. |
| gateway.auth.key | string | `nil` | Authentication key to authenticate with to Azure API Management service. Typically starts with `GatewayKey`. When an existing secret is configured, the value specified here will not be used. |
| gateway.auth.type | string | `"GatewayToken"` | Type of authentication to use for Azure API Management's Configuration API. Options are `GatewayToken` or `AzureAdApp`. |
| gateway.configuration.additional | object | `{}` | Capability to specify a list of settings to add which are not supported by the Helm chart yet. |
| gateway.configuration.backup.enabled | bool | `false` | If enabled will store a backup copy of the latest downloaded configuration on a storage volume. |
| gateway.configuration.backup.persistentVolumeClaim.accessMode | string | `"ReadWriteMany"` | Access mode for the Persistent Volume Claim (PVC). |
| gateway.configuration.backup.persistentVolumeClaim.create | bool | `true` | Create a Persistent Volume Claim (PVC) with values specified in *.backup.persistentVolumeClaim.*. |
| gateway.configuration.backup.persistentVolumeClaim.existingName | string | `""` | Use an existing Persistent Volume Claim (PVC) instead of creating one. *.persistentVolumeClaim.create needs to be false. |
| gateway.configuration.backup.persistentVolumeClaim.size | string | `"50Mi"` | Size of the Persistent Volume Claim (PVC) to be created. |
| gateway.configuration.backup.persistentVolumeClaim.storageClassName | string | `nil` | storageClassName to be set on the Persistent Volume Claim (PVC). `null` means no storageClassName specified and will use the platform default, `""` means no storageClassName specified and none will be used. |
| gateway.configuration.uri | string | `nil` | Endpoint in Azure API Management to which every self-hosted agent has to connect. |
| gateway.deployment.dns.hostAliases | object | `{}` | Add custom host aliases (configuration endpoint e.g.). Check the [values.yaml](./values.yaml) for the details. |
| gateway.deployment.network.proxy.bypass | string | `nil` | List of addresses/domains that should be bypassed when using an HTTP(S) network proxy. |
| gateway.deployment.network.proxy.http | string | `nil` | Address of HTTP network proxy to use for all outbound HTTP requests to the backend services (egress). |
| gateway.deployment.network.proxy.https | string | `nil` | Address of HTTPS network proxy to use for all outbound HTTPS requests to the backend services (egress). |
| gateway.deployment.strategy | object | `{}` | Specifies the deployment [strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) to use for replacing old pods by new ones. May be `Recreate` or `RollingUpdate`. |
| gateway.deployment.terminationGracePeriodSeconds | int | `60` | Determines the maximum time the Pod may spend in the Terminating phase. Learn more [about the termination of Pods](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-handler-execution). |
| gateway.name | string | `nil` | Name of the gateway in Azure API Management. Required when using Azure AD authentication. |
| highAvailability.disruption.maximumUnavailable | string | `"25%"` | Amount of pods that are allowed to be unavailable due to [voluntary disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#voluntary-and-involuntary-disruptions). |
| highAvailability.enabled | bool | `true` | Indication whether or not the gateway should be scheduled highly available in the cluster. |
| highAvailability.podTopologySpread.whenUnsatisfiable | string | `"ScheduleAnyway"` | Indication how pods should be spread across nodes in case the requirement cannot be met. Learn more in the [Kubernetes docs](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/). |
| image.pullPolicy | string | `"IfNotPresent"` | Policy to pull image. |
| image.repository | string | `"mcr.microsoft.com/azure-api-management/gateway"` | Repository which provides the image. |
| image.tag | string | `nil` | Tag of image to use. Defaults to app version of Helm chart. |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries. |
| ingress.controller.annotations | list | `[]` | Annotations for ingress controller. ([experimental feature](https://github.com/Azure/api-management-self-hosted-gateway-ingress)). |
| ingress.controller.dns.suffix | string | `"svc.cluster.local"` | DNS suffix to use to build Kubernetes hostname for services inside the cluster. ([experimental feature](https://github.com/Azure/api-management-self-hosted-gateway-ingress)). |
| ingress.controller.enabled | bool | `false` | Indication whether or not Self-Hosted gateway should act as an Ingress controller. ([experimental feature](https://github.com/Azure/api-management-self-hosted-gateway-ingress)). |
| ingress.controller.ingressClass.annotations | list | `[]` | Annotations to apply to ingress class. ([experimental feature](https://github.com/Azure/api-management-self-hosted-gateway-ingress)). |
| ingress.controller.ingressClass.controller | string | `"azure-api-management/gateway"` | Controller name for ingress class. ([experimental feature](https://github.com/Azure/api-management-self-hosted-gateway-ingress)). |
| ingress.controller.namespace | string | `""` | Kubernetes namespace to watch. ([experimental feature](https://github.com/Azure/api-management-self-hosted-gateway-ingress)). |
| nameOverride | string | `""` | Override the name of the chart. |
| nodeSelector | object | `{}` | Node selector for pod assignment. |
| observability.azureMonitor.metrics.enabled | bool | `true` | Indication whether or not metrics should be sent to Azure Monitor. Learn more in [our documentation](https://docs.microsoft.com/en-us/azure/api-management/how-to-configure-cloud-metrics-logs#metrics). |
| observability.logs.local.journal.endpoint | string | `nil` | Endpoint to send logs to with journal protocol. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| observability.logs.local.json.endpoint | string | `"127.0.0.1:8888"` | UDP endpoint that accepts JSON data. This can be a file path, `IP:port`, or `hostname:port` convention. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| observability.logs.local.localsyslog.endpoint | string | `nil` | Endpoint to send logs to with localsyslog protocol. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| observability.logs.local.localsyslog.facility | string | `nil` | Facility code as per [localsyslog](https://en.wikipedia.org/wiki/Syslog#Facility), for example `7`. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| observability.logs.local.rfc5424.endpoint | string | `nil` | Endpoint to send logs to with rfc5424 protocol. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| observability.logs.local.rfc5424.facility | string | `nil` | Facility code as per [rfc5424](https://tools.ietf.org/html/rfc5424), for example `7`. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| observability.logs.local.type | string | `"auto"` | Type of local logs to use. Allowed values are `none`, `auto`, `localsyslog`, `rfc5424`, `journal`, `json` or `forward`. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| observability.logs.std.format | string | `"text"` | Format of standard output logs also referred to as container logs. Allowed values are `none`, `text` or `json`. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| observability.logs.std.level | string | `"info"` | Level of logs outputted to standard output. Allowed values are `all`, `debug`, `info`, `warn`, `error` or `fatal`. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| observability.logs.std.useColor | bool | `true` | Indication whether or not output messages should use color. Allowed values are `true` or `false`. |
| observability.opentelemetry.collector.uri | string | `nil` | Uri of the OpenTelemetry Collector to push metrics to. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-deploy-self-hosted-gateway-kubernetes-opentelemetry). |
| observability.opentelemetry.enabled | bool | `false` | Indication whether or not OpenTelemetry observability should be provided for the gateway. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-deploy-self-hosted-gateway-kubernetes-opentelemetry). |
| observability.opentelemetry.histogram.buckets | string | `nil` | Define custom bucket sizes for all histograms in OpenTelemetry metrics. Format must be `,` separated (e.g., '10,20'). Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-deploy-self-hosted-gateway-kubernetes-opentelemetry). |
| observability.opentelemetry.systemMetrics.enabled | bool | `false` | Indication whether or not system metrics should be collected by OpenTelemetry. |
| observability.statsD.enabled | bool | `false` | Indication whether or not StatsD metrics should be pushed by the gateway. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#configure-the-self-hosted-gateway-to-emit-metrics). |
| observability.statsD.endpoint | string | `nil` | Endpoint to push StatsD metrics to. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#configure-the-self-hosted-gateway-to-emit-metrics). |
| observability.statsD.sampling | int | `1` | Defines the metrics sampling rate. Value can be between `0` and `1`. e.g., `0.5`. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#configure-the-self-hosted-gateway-to-emit-metrics). |
| observability.statsD.tagFormat | string | `"dogStatsD"` | Defines the [tagging format](https://github.com/prometheus/statsd_exporter#tagging-extensions) in StatsD metrics as per the official docs. Value can be `none`, `librato`, `dogStatsD`, `influxDB`. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#configure-the-self-hosted-gateway-to-emit-metrics). |
| podSecurityContext | object | `{}` | Privilege and access control settings for the pod. |
| probes.liveness | object | `{"httpGet":{"path":"/status-0123456789abcdef","port":"http"}}` | Configuration for liveness probes of the container. Uses `/status-0123456789abcdef` as endpoint for HTTP probes. |
| probes.readiness | object | `{"httpGet":{"path":"/status-0123456789abcdef","port":"http"}}` | Configuration for readiness probes of the container. Uses `/status-0123456789abcdef` as endpoint for HTTP probes. |
| probes.startup | object | `{"httpGet":{"path":"/status-0123456789abcdef","port":"http"}}` | Configuration for startup probes of the container. Uses `/status-0123456789abcdef` as endpoint for HTTP probes. |
| replicaCount | int | `3` | Number of gateway replicas to deploy. Set to 'null' to remove `replicaCount` property from the deployment. |
| resources | object | `{}` | Pod resource requests & limits. We usually recommend not to specify default resources and to leave this as a conscious choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. If you do want to specify resources, uncomment the following lines, adjust them as necessary, and remove the curly braces after 'resources:'. |
| secret.createSecret | bool | `true` | Indication whether or not a Kubernetes secret should be created to store the authentication token. |
| secret.existingSecretName | string | `""` | Name of the existing secret to be used by the gateway. Requires `secret.createSecret` to be false. |
| security.tls.client.ciphers.allowedSuites | string | `nil` | A comma-separated list of ciphers to use for the TLS connection between the self-hosted gateway and the backend. Learn more in our [security / TLS documentation](https://aka.ms/apim/sputnik/security/tls). Default cipher suites are used as per [our documentation](https://docs.microsoft.com/azure/api-management/self-hosted-gateway-overview#available-cipher-suites). |
| security.tls.server.ciphers.allowedSuites | string | `nil` | A comma-separated list of ciphers to use for the TLS connection between the API client and the self-hosted gateway. Learn more in our [security / TLS documentation](https://aka.ms/apim/sputnik/security/tls). Default cipher suites are used as per [our documentation](https://docs.microsoft.com/azure/api-management/self-hosted-gateway-overview#available-cipher-suites). |
| securityContext | object | `{}` | Privilege and access control settings for the container. |
| service.annotations | object | `{}` | Annotations to add to the Kubernetes service. |
| service.loadBalancer.allocateNodePorts | bool | `true` | Defines if node ports will be automatically allocated for services with type `LoadBalancer`. |
| service.ports.http | int | `8080` | Port for HTTP traffic on service for other pods to talk to. |
| service.ports.https | int | `8081` | Port for HTTPS traffic on service for other pods to talk to. |
| service.ports.instance.heartbeat | int | `4291` | Port used for sending heartbeats to all instances for synchronization purposes. |
| service.ports.instance.synchronization | int | `4290` | Port used for internal discovery of gateway instances to synchronize across all of them, ie for rate limiting. |
| service.type | string | `"ClusterIP"` | Type of Kubernetes service to use to expose to serve traffic. |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. When true, a service account is automatically generated with the deployment name. |
| serviceAccount.labels | object | `{}` | Labels to add to the service account. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and `create` is true, a name is generated using the fullname template. If not set and `create` is false, falls back to `serviceAccountName` value. |
| serviceAccountName | string | `""` | **Deprecated - Use `serviceAccount.name` instead.** Legacy field for specifying an existing service account. By default, a service account is now auto-generated with release name (see `serviceAccount.create`). |
| tolerations | list | `[]` | Tolerations for pod assignment. |

Specify each parameter using the `--set key=value[,key=value]` argument to
`helm install`.

Alternatively, a YAML file that specifies the values for the above parameters can
be provided while installing the chart. For example,

```console
helm install azure-apim-gateway/azure-api-management-gateway --name azure-api-management-gateway -f values.yaml
```

## High Availability

We deploy the self-hosted gateway highly available by default to optimize for resilience to reduce impact on your platform, but you can opt-out by using `highAvailability.enabled=false`.

This will ensure that:

- **Distributing Pods Across Nodes** - Instances will be spread across nodes in the cluster that are in different availability zones
  - However, this will only work if your cluster is using availability zones. For Azure Kubernetes Service, learn more [here](https://docs.microsoft.com/en-us/azure/aks/availability-zones).
  - Learn more about [pod topology spread constraints](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/).
- **Prevent Against Voluntary Disruptions** - Only a % of instances can be removed due to [voluntary disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#voluntary-and-involuntary-disruptions) (ie. node drain, deployment upgrade, pod delete, etc.)
