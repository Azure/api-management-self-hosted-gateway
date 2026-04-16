## Getting started

You can easily install the self-hosted gateway with Docker:

```
docker run -d -p 8080:8080 -p 8081:8081 --name <gateway-name> \
  --env config.service.endpoint=<instance-name>.configuration.azure-api.net \
  config.service.auth=<auth-token> \
  mcr.microsoft.com/azure-api-management/gateway:<containerImageVersion>
```

Learn how you can install it on other container platforms:

- [Deploy self-hosted gateway on Kubernetes with Helm](https://aka.ms/apim/sputnik/deploy/k8s/helm)
- [Deploy self-hosted gateway on Kubernetes with Azure Arc (Preview)](https://aka.ms/apim/sputnik/deploy/k8s/arc)
- [Deploy self-hosted gateway on Kubernetes with YAML](https://aka.ms/apim/sputnik/deploy/k8s/yaml)

Here are other relevant resources:

- [Authenticate self-hosted gateway with Azure AD](https://learn.microsoft.com/en-us/azure/api-management/self-hosted-gateway-enable-azure-ad)
- [Self-hosted gateway on Microsoft Artifact Registry](https://aka.ms/apim/shgw/registry-portal)
- [Our image tagging strategy](https://aka.ms/apim/shgw/image-tagging)

## What is new?

### Highlights

- TBD

### Features

- TBD
- Keep an eye on [official repo](https://github.com/Azure/API-Management/releases) for more soon

### Fixes / Changes

- TBD

### Breaking Changes

None.

### Removal

None.
