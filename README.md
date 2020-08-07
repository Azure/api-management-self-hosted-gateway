# Azure API Management Self-Hosted Gateway samples and stuff

## What is Azure API Management Self-Hosted Gateway?

[Self-hosted gateway](https://aka.ms/apim/sputnik/overview) is a feature of [Azure API Management](https://aka.ms/apimrocks). The self-hosted gateway, a containerized version of the API Management gateway component, expands API Management support for hybrid and multi-cloud environments. It allows customers to manage all of their APIs using a single API management solution without compromising security, compliance, or performance. Customers can deploy the self-hosted gateways to the same environments where they host their APIs while continuing to manage them from an associated API Management service in Azure.

## Installing with Helm

The Azure API Management Self-Hosted Gateway is available as a Helm chart and can be easily installed on Kubernetes.

Install the Helm repo:
```cli
helm repo add azure-apim-gateway https://azure.github.io/api-management-self-hosted-gateway/helm-charts/
```

Update repo to fetch the latest Helm charts:
```cli
helm repo update
```

To install the chart with the release name `azure-api-management-gateway`:
```
helm install --name azure-api-management-gateway azure-apim-gateway/azure-api-management-gateway \
             --set gateway.endpoint='<azure-api-management-url>' \
             --set gateway.authKey='<azure-api-management-gateway-key>'
```

This will deploy the Azure API Management Self-Hosted gateway on your Kubernetes cluster, but we provide options to configure it according to your needs.

To learn more, we recommend inspecting the Helm chart:
```cli
helm inspect all azure-apim-gateway/azure-api-management-gateway
```

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
