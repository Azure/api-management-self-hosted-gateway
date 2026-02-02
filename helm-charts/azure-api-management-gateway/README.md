# Azure API Management Gateway

![Version: 1.15.0](https://img.shields.io/badge/Version-1.15.0-informational?style=flat-square) ![AppVersion: 2.11.0](https://img.shields.io/badge/AppVersion-2.11.0-informational?style=flat-square) [![Documentation](https://img.shields.io/badge/docs-azure.com-blue?style=flat-square)](https://docs.microsoft.com/azure/api-management/self-hosted-gateway-overview)

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

## Common Scenarios

### Gateway Token Authentication

```yaml
gateway:
  configuration:
    uri: "https://my-gateway.configuration.azure-api.net"
  auth:
    key: "GatewayKey ey..."
```

### Microsoft Entra ID (formerly Azure AD) Authentication - Workload Identity

```yaml
gateway:
  name: "my-gateway"
  configuration:
    uri: "https://my-gateway.configuration.azure-api.net"
  auth:
    type: "WorkloadIdentity"
    azureAd:
      app:
        id: "00000000-0000-0000-0000-000000000000"
```

### Microsoft Entra ID (formerly Azure AD) Authentication - Client Certificate

```yaml
gateway:
  name: "my-gateway"
  configuration:
    uri: "https://my-gateway.configuration.azure-api.net"
  auth:
    type: "AzureAdApp"
    azureAd:
      tenant:
        id: "00000000-0000-0000-0000-000000000000"
      app:
        id: "00000000-0000-0000-0000-000000000000"
      # Client certificate should be provided via secret
```

## Configuration

The following sections list the configurable parameters of the self-hosted Azure API Management gateway chart organized by category.

- [Gateway Configuration](#gateway-configuration)
- [High Availability](#high-availability)
- [Observability](#observability)
- [Security](#security)
- [Networking](#networking)
- [Dapr](#dapr)
- [Advanced Configuration](#advanced-configuration)

### Gateway Configuration

Connection and authentication settings for the Azure API Management gateway.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `gateway.auth.azureAd.app.id` | string | `nil` | **Required for AzureAdApp and WorkloadIdentity auth.** Client ID (application ID) of the Azure AD app registered for gateway authentication. Find this in Azure Portal under App registrations. |
| `gateway.auth.azureAd.app.secret` | string | `nil` | **Required for AzureAdApp auth (client secret).** Client secret of the Azure AD app. Not used with WorkloadIdentity. Not used when an existing secret is configured. |
| `gateway.auth.azureAd.authority` | string | `nil` | Azure AD authority URL. Defaults to public Azure AD if not specified. Example: `https://login.microsoftonline.com/<tenant-id>`. |
| `gateway.auth.azureAd.tenant.id` | string | `nil` | **Required for AzureAdApp auth.** Azure AD tenant ID (GUID). Find this in Azure Portal under Azure Active Directory → Properties. |
| `gateway.auth.key` | string | `nil` | **Required for GatewayToken auth.** Authentication token from Azure API Management gateway resource. Starts with `GatewayKey`. Find this in the Azure Portal under the gateway's Deployment section. Not used when an existing secret is configured. |
| `gateway.auth.type` | string | `"GatewayToken"` | Type of authentication to use for Azure API Management's Configuration API. Options: `GatewayToken` (use gateway.auth.key), `AzureAdApp` (use client secret/certificate), or `WorkloadIdentity` (use managed identity). |
| `gateway.configuration.additional` | object | `{}` | Advanced: Specify additional gateway configuration settings not yet supported by the Helm chart. See [Azure API Management self-hosted gateway configuration](https://docs.microsoft.com/azure/api-management/self-hosted-gateway-settings-reference). |
| `gateway.configuration.backup.enabled` | bool | `false` | Enable storing a backup copy of the latest downloaded gateway configuration on a persistent volume. This allows the gateway to start with last-known configuration if it cannot reach Azure API Management. |
| `gateway.configuration.backup.persistentVolumeClaim.accessMode` | string | `"ReadWriteMany"` | Access mode for the Persistent Volume Claim (PVC). Use `ReadWriteMany` for multi-replica deployments, `ReadWriteOnce` for single replica. |
| `gateway.configuration.backup.persistentVolumeClaim.create` | bool | `true` | Create a new Persistent Volume Claim (PVC) for configuration backup with the settings specified below. |
| `gateway.configuration.backup.persistentVolumeClaim.existingName` | string | `""` | Use an existing Persistent Volume Claim (PVC) for configuration backup instead of creating one. Requires `*.persistentVolumeClaim.create` to be false. |
| `gateway.configuration.backup.persistentVolumeClaim.size` | string | `"50Mi"` | Size of the Persistent Volume Claim (PVC) for configuration backup. |
| `gateway.configuration.backup.persistentVolumeClaim.storageClassName` | string | `nil` | Storage class name for the Persistent Volume Claim (PVC). `null` uses the cluster default storage class, `""` means no storage class will be set. |
| `gateway.configuration.uri` | string | `nil` | **Required.** Configuration endpoint URL from your Azure API Management gateway resource. Find this in the Azure Portal under the gateway's Deployment section. Format: `https://<gateway-name>.configuration.azure-api.net`. |
| `gateway.deployment.dns.hostAliases` | object | `{}` | Add custom host aliases to /etc/hosts in the gateway pod (useful for custom configuration endpoints). Check the [values.yaml](./values.yaml) for format details. |
| `gateway.deployment.network.proxy.bypass` | string | `nil` | Comma-separated list of addresses/domains to bypass when using an HTTP(S) network proxy. Example: `localhost,127.0.0.1,.svc.cluster.local`. |
| `gateway.deployment.network.proxy.http` | string | `nil` | HTTP network proxy address for outbound HTTP requests to backend services (egress). Format: `http://proxy.example.com:8080`. |
| `gateway.deployment.network.proxy.https` | string | `nil` | HTTPS network proxy address for outbound HTTPS requests to backend services (egress). Format: `http://proxy.example.com:8080`. |
| `gateway.deployment.strategy` | object | `{}` | Deployment [strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) to use for replacing old pods. May be `Recreate` (stop all old pods before creating new ones) or `RollingUpdate` (default, gradually replace pods). |
| `gateway.deployment.terminationGracePeriodSeconds` | int | `60` | Maximum time in seconds the Pod may spend in the Terminating phase during shutdown. The gateway uses this time to gracefully complete ongoing requests. Learn more [about the termination of Pods](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-handler-execution). |
| `gateway.name` | string | `nil` | Name of the gateway resource in Azure API Management. This is required when using Azure AD authentication (WorkloadIdentity or AzureAdApp). Find this in the Azure Portal under your API Management instance. |

### High Availability

Settings for deployment resilience.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `highAvailability.disruption.maximumUnavailable` | string | `"25%"` | Maximum percentage or number of pods that can be unavailable during [voluntary disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#voluntary-and-involuntary-disruptions) like node drains or deployments. Example: `25%` or `1`. |
| `highAvailability.enabled` | bool | `true` | Deploy the gateway with high availability features enabled. When true, distributes pods across availability zones and prevents voluntary disruptions. Recommended for production deployments. |
| `highAvailability.podTopologySpread.whenUnsatisfiable` | string | `"ScheduleAnyway"` | How to handle pod scheduling when topology spread constraints cannot be met. `ScheduleAnyway` allows scheduling even if constraints are not met (preferred), `DoNotSchedule` prevents scheduling. Learn more in the [Kubernetes docs](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/). |

### Observability

Monitoring, logging, and telemetry configuration.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `observability.azureMonitor.metrics.enabled` | bool | `true` | Enable sending metrics to Azure Monitor. This allows you to monitor gateway performance in Azure Portal. Learn more in [our documentation](https://docs.microsoft.com/en-us/azure/api-management/how-to-configure-cloud-metrics-logs#metrics). |
| `observability.logs.local.journal.endpoint` | string | `nil` | Endpoint to send logs to with journal protocol. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| `observability.logs.local.json.endpoint` | string | `"127.0.0.1:8888"` | UDP endpoint that accepts JSON data. This can be a file path, `IP:port`, or `hostname:port` convention. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| `observability.logs.local.localsyslog.endpoint` | string | `nil` | Endpoint to send logs to with localsyslog protocol. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| `observability.logs.local.localsyslog.facility` | string | `nil` | Facility code as per [localsyslog](https://en.wikipedia.org/wiki/Syslog#Facility), for example `7`. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| `observability.logs.local.rfc5424.endpoint` | string | `nil` | Endpoint to send logs to with rfc5424 protocol. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| `observability.logs.local.rfc5424.facility` | string | `nil` | Facility code as per [rfc5424](https://tools.ietf.org/html/rfc5424), for example `7`. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| `observability.logs.local.type` | string | `"auto"` | Type of local logs to use. Allowed values are `none`, `auto`, `localsyslog`, `rfc5424`, `journal`, `json` or `forward`. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| `observability.logs.std.format` | string | `"text"` | Format of standard output logs also referred to as container logs. Allowed values are `none`, `text` or `json`. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| `observability.logs.std.level` | string | `"info"` | Level of logs outputted to standard output. Allowed values are `all`, `debug`, `info`, `warn`, `error` or `fatal`. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#logs). |
| `observability.logs.std.useColor` | bool | `true` | Indication whether or not output messages should use color. Allowed values are `true` or `false`. |
| `observability.opentelemetry.collector.uri` | string | `nil` | OpenTelemetry Collector endpoint URI to push metrics and traces to. Format: `http://otel-collector:4317` (gRPC) or `http://otel-collector:4318` (HTTP). Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-deploy-self-hosted-gateway-kubernetes-opentelemetry). |
| `observability.opentelemetry.enabled` | bool | `false` | Enable OpenTelemetry observability for the gateway. This provides distributed tracing and enhanced metrics. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-deploy-self-hosted-gateway-kubernetes-opentelemetry). |
| `observability.opentelemetry.histogram.buckets` | string | `nil` | Define custom bucket sizes for all histograms in OpenTelemetry metrics. Comma-separated values in milliseconds. Example: `10,20,50,100,200,500,1000`. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-deploy-self-hosted-gateway-kubernetes-opentelemetry). |
| `observability.opentelemetry.systemMetrics.enabled` | bool | `false` | Enable collecting system metrics (CPU, memory) via OpenTelemetry in addition to API metrics. |
| `observability.statsD.enabled` | bool | `false` | Enable pushing StatsD metrics from the gateway. Useful for integration with Prometheus, Datadog, or other StatsD-compatible systems. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#configure-the-self-hosted-gateway-to-emit-metrics). |
| `observability.statsD.endpoint` | string | `nil` | StatsD endpoint to push metrics to. Format: `udp://statsd-server:8125`. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#configure-the-self-hosted-gateway-to-emit-metrics). |
| `observability.statsD.sampling` | int | `1` | Metrics sampling rate. Value between `0` (no metrics) and `1` (all metrics). Example: `0.5` samples 50% of requests. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#configure-the-self-hosted-gateway-to-emit-metrics). |
| `observability.statsD.tagFormat` | string | `"dogStatsD"` | StatsD [tagging format](https://github.com/prometheus/statsd_exporter#tagging-extensions) for metric tags. Options: `none`, `librato`, `dogStatsD`, `influxDB`. Use `dogStatsD` for Datadog compatibility. Learn more in [our documentation](https://docs.microsoft.com/azure/api-management/how-to-configure-local-metrics-logs#configure-the-self-hosted-gateway-to-emit-metrics). |

### Security

TLS and security settings.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `security.tls.client.ciphers.allowedSuites` | string | `nil` | Comma-separated list of TLS cipher suites for gateway-to-backend connections. Use this to ensure compatibility with backend systems or enforce strong encryption. Example: `TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`. Learn more in our [security / TLS documentation](https://aka.ms/apim/sputnik/security/tls). Default cipher suites are used as per [our documentation](https://docs.microsoft.com/azure/api-management/self-hosted-gateway-overview#available-cipher-suites). |
| `security.tls.server.ciphers.allowedSuites` | string | `nil` | Comma-separated list of TLS cipher suites for client-to-gateway connections. Use this to enforce strong encryption or comply with security policies. Example: `TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`. Learn more in our [security / TLS documentation](https://aka.ms/apim/sputnik/security/tls). Default cipher suites are used as per [our documentation](https://docs.microsoft.com/azure/api-management/self-hosted-gateway-overview#available-cipher-suites). |

### Networking

Service and ingress configuration.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ingress.controller.annotations` | list | `[]` | **Experimental.** Annotations to add to managed Ingress resources. See the [ingress controller repository](https://github.com/Azure/api-management-self-hosted-gateway-ingress). |
| `ingress.controller.dns.suffix` | string | `"svc.cluster.local"` | **Experimental.** DNS suffix for building Kubernetes service hostnames inside the cluster. Example: `svc.cluster.local`. See the [ingress controller repository](https://github.com/Azure/api-management-self-hosted-gateway-ingress). |
| `ingress.controller.enabled` | bool | `false` | **Experimental.** Enable Self-Hosted gateway to act as a Kubernetes Ingress controller. This feature is experimental and under active development. See the [ingress controller repository](https://github.com/Azure/api-management-self-hosted-gateway-ingress) for details and limitations. |
| `ingress.controller.ingressClass.annotations` | list | `[]` | **Experimental.** Annotations to apply to the IngressClass resource. See the [ingress controller repository](https://github.com/Azure/api-management-self-hosted-gateway-ingress). |
| `ingress.controller.ingressClass.controller` | string | `"azure-api-management/gateway"` | **Experimental.** Controller name for the IngressClass resource. See the [ingress controller repository](https://github.com/Azure/api-management-self-hosted-gateway-ingress). |
| `ingress.controller.namespace` | string | `""` | **Experimental.** Kubernetes namespace to watch for Ingress resources. Empty string watches all namespaces. See the [ingress controller repository](https://github.com/Azure/api-management-self-hosted-gateway-ingress). |
| `service.annotations` | object | `{}` | Annotations to add to the Kubernetes service. |
| `service.loadBalancer.allocateNodePorts` | bool | `true` | Defines if node ports will be automatically allocated for services with type `LoadBalancer`. |
| `service.ports.http` | int | `8080` | Port for HTTP traffic on service for other pods to talk to. |
| `service.ports.https` | int | `8081` | Port for HTTPS traffic on service for other pods to talk to. |
| `service.ports.instance.heartbeat` | int | `4291` | Port used for sending heartbeats to all instances for synchronization purposes. |
| `service.ports.instance.synchronization` | int | `4290` | Port used for internal discovery of gateway instances to synchronize across all of them, ie for rate limiting. |
| `service.type` | string | `"ClusterIP"` | Type of Kubernetes service to use to expose to serve traffic. |

### Dapr

Configuration for Dapr integration.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `dapr.app.id` | string | `nil` | Application ID to use for Dapr integration. |
| `dapr.config` | string | `"tracing"` | Defines which Configuration CRD Dapr should use. |
| `dapr.enabled` | bool | `false` | Indication whether or not Dapr integration should be used. |
| `dapr.logging.level` | string | `"info"` | Level of log verbosity of Dapr sidecar. |
| `dapr.logging.useJsonOutput` | bool | `true` | Indication whether or not logging should be in JSON format. |

### Advanced Configuration

Additional deployment, pod, and resource settings.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `affinity` | object | `{}` | Affinity for pod assignment. |
| `commonLabels` | object | `{}` | Custom labels to add to all deployed objects. |
| `fullnameOverride` | string | `""` | Override the full name of the release. |
| `image.pullPolicy` | string | `"IfNotPresent"` | Policy to pull image. |
| `image.repository` | string | `"mcr.microsoft.com/azure-api-management/gateway"` | Repository which provides the image. |
| `image.tag` | string | `nil` | Tag of image to use. Defaults to app version of Helm chart. |
| `imagePullSecrets` | list | `[]` | Image pull secrets for private registries. |
| `nameOverride` | string | `""` | Override the name of the chart. |
| `nodeSelector` | object | `{}` | Node selector for pod assignment. |
| `podSecurityContext` | object | `{}` | Privilege and access control settings for the pod. |
| `probes.liveness` | object | `{"httpGet":{"path":"/status-0123456789abcdef","port":"http"}}` | Configuration for liveness probes of the container. Uses `/status-0123456789abcdef` as endpoint for HTTP probes. |
| `probes.readiness` | object | `{"httpGet":{"path":"/status-0123456789abcdef","port":"http"}}` | Configuration for readiness probes of the container. Uses `/status-0123456789abcdef` as endpoint for HTTP probes. |
| `probes.startup` | object | `{"httpGet":{"path":"/status-0123456789abcdef","port":"http"}}` | Configuration for startup probes of the container. Uses `/status-0123456789abcdef` as endpoint for HTTP probes. |
| `replicaCount` | int | `3` | Number of gateway replicas to deploy. Set to 'null' to remove `replicaCount` property from the deployment. |
| `resources` | object | `{}` | Pod resource requests & limits. We usually recommend not to specify default resources and to leave this as a conscious choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. If you do want to specify resources, uncomment the following lines, adjust them as necessary, and remove the curly braces after 'resources:'. |
| `secret.createSecret` | bool | `true` | Indication whether or not a Kubernetes secret should be created to store the authentication token. |
| `secret.existingSecretName` | string | `""` | Name of the existing secret to be used by the gateway. Requires `secret.createSecret` to be false. |
| `securityContext` | object | `{}` | Privilege and access control settings for the container. |
| `serviceAccount.annotations` | object | `{}` | Annotations to add to the service account. |
| `serviceAccount.create` | bool | `true` | Specifies whether a service account should be created. When true, a service account is automatically generated with the deployment name. |
| `serviceAccount.labels` | object | `{}` | Labels to add to the service account. |
| `serviceAccount.name` | string | `""` | The name of the service account to use. If not set and `create` is true, a name is generated using the fullname template. If not set and `create` is false, falls back to `serviceAccountName` value. |
| `serviceAccountName` | string | `""` | **Deprecated - Use `serviceAccount.name` instead.** Legacy field for specifying an existing service account. By default, a service account is now auto-generated with release name (see `serviceAccount.create`). |
| `tolerations` | list | `[]` | Tolerations for pod assignment. |

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
