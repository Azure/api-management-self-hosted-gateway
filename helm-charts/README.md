# Helm charts

## Releasing a new version

```bash
helm package azure-api-management-gateway
helm repo index . --url https://azure.github.io/api-management-self-hosted-gateway/helm-charts/
git add .
git commit ...
git push origin master
```