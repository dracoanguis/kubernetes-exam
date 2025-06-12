{{/*
Expand the name of the chart.
*/}}
{{- define "microservice.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "microservice.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "microservice.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "microservice.labels" -}}
helm.sh/chart: {{ include "microservice.chart" . }}
{{ include "microservice.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "microservice.selectorLabels" -}}
app.kubernetes.io/name: {{ include "microservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "microservice.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "microservice.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the rediness probe
*/}}
{{- define "microservice.readinessProbe" -}}
{{- if hasKey .Values.readinessProbe "custom" -}}
readinessProbe:
{{- toYaml .Values.readinessProbe.custom | nindent 2 }}
{{- else -}}
readinessProbe:
  initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds | default 15 }}
  periodSeconds: {{ .Values.readinessProbe.periodSeconds | default 10 }}
  grpc:
    port: {{ .Values.readinessProbe.port | default .Values.service.port | required "A port must be specified for the service" }}
{{- end -}}
{{- end -}}

{{/*
Create the liveness probe
*/}}
{{- define "microservice.livenessProbe" -}}
{{- if hasKey .Values.livenessProbe "custom" -}}
livenessProbe:
{{- toYaml .Values.livenessProbe.custom | nindent 2 }}
{{- else -}}
livenessProbe:
  initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds | default 15 }}
  periodSeconds: {{ .Values.livenessProbe.periodSeconds | default 10 }}
  grpc:
    port: {{ .Values.livenessProbe.port | default .Values.service.port | required "A port must be specified for the service" }}
{{- end -}}
{{- end -}}