# Contributing to Azure API Management Self-Hosted Gateway

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Updating Helm Chart Documentation

The Helm chart documentation in `helm-charts/azure-api-management-gateway/README.md` is automatically generated using [helm-docs](https://github.com/norwoodj/helm-docs).

### How to Update Documentation

1. Install helm-docs: Follow the [installation instructions](https://github.com/norwoodj/helm-docs#installation)
2. Update the comments in `values.yaml` using the `# --` format for descriptions
3. Run `helm-docs` in the `helm-charts/azure-api-management-gateway` directory
4. Commit both `values.yaml` and the generated `README.md`

The CI workflow will validate that the README is up-to-date with the values.yaml file.

## Release Process

### Releasing a New Helm Chart Version

When releasing a new version of the Helm chart, follow these steps:

1. **Update Chart Version**: Update the `version` field in `helm-charts/azure-api-management-gateway/Chart.yaml`

2. **Update Documentation**: 
   - Ensure all changes to `values.yaml` are documented with `# --` comments
   - Run `helm-docs` in the `helm-charts/azure-api-management-gateway` directory to regenerate the README
   - Verify the generated `README.md` is accurate and complete

3. **Package and Index the Chart**: Navigate to the `helm-charts` directory and run:
   ```bash
   cd helm-charts
   helm package azure-api-management-gateway
   helm repo index . --url https://azure.github.io/api-management-self-hosted-gateway/helm-charts/
   ```

4. **Commit and Push Changes**: 
   ```bash
   git add .
   git commit -m "Release Helm chart version X.Y.Z"
   git push origin main
   ```

5. **Verify CI**: Ensure the `validate-helm-docs` job in the CI workflow passes, confirming documentation is synchronized
