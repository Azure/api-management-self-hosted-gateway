{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "azure-api-management-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "azure-api-management-gateway.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "azure-api-management-gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
    Common labels
*/}}
{{- define "azure-api-management-gateway.labels" -}}
helm.sh/chart: {{ include "azure-api-management-gateway.chart" . }}
{{ include "azure-api-management-gateway.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{/*
    Selector labels
*/}}
{{- define "azure-api-management-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "azure-api-management-gateway.fullname" . }}
app.kubernetes.io/component: self-hosted-gateway
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
    Create a name for the pod disruption budget
*/}}
{{- define "azure-api-management-gateway.disruptionname" -}}
{{ include "azure-api-management-gateway.fullname" . | trunc 52 | trimSuffix "-" }}-disruption
{{- end }}