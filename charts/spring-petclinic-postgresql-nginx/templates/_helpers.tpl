{{/*
Expand the name of the chart.
*/}}
{{- define "spring-petclinic.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "spring-petclinic.fullname" -}}
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
{{- define "spring-petclinic.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "spring-petclinic.labels" -}}
helm.sh/chart: {{ include "spring-petclinic.chart" . }}
{{ include "spring-petclinic.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "spring-petclinic.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spring-petclinic.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "spring-petclinic.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "spring-petclinic.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name for PostgreSQL Primary objects
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec)
Copied from https://github.com/bitnami/charts/blob/master/bitnami/postgresql/templates/_helpers.tpl
Modified in order to be useable within the scope of this Chart
*/}}
{{- define "spring-petclinic.postgresql.primary.fullname" -}}
{{- if .Values.postgresql.fullnameOverride -}}
{{- .Values.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the name for a custom user to create
Copied from https://github.com/bitnami/charts/blob/master/bitnami/postgresql/templates/_helpers.tpl
Modified in order to be useable within the scope of this Chart
*/}}
{{- define "spring-petclinic.postgresql.username" -}}
{{- if .Values.postgresql.global.postgresql.auth.username }}
{{- .Values.postgresql.global.postgresql.auth.username -}}
{{- else -}}
{{- .Values.postgresql.auth.username -}}
{{- end -}}
{{- end -}}

{{/*
Return the name for a custom database to create
Copied from https://github.com/bitnami/charts/blob/master/bitnami/postgresql/templates/_helpers.tpl
Modified in order to be useable within the scope of this Chart
*/}}
{{- define "spring-petclinic.postgresql.database" -}}
{{- if .Values.postgresql.global.postgresql.auth.database }}
{{- .Values.postgresql.global.postgresql.auth.database -}}
{{- else if .Values.postgresql.auth.database -}}
{{- .Values.postgresql.auth.database -}}
{{- end -}}
{{- end -}}

{{/*
Get the password secret
Copied from https://github.com/bitnami/charts/blob/master/bitnami/postgresql/templates/_helpers.tpl
Modified in order to be useable within the scope of this Chart
*/}}
{{- define "spring-petclinic.postgresql.secretName" -}}
{{- if .Values.postgresql.global.postgresql.auth.existingSecret }}
{{- printf "%s" (tpl .Values.postgresql.global.postgresql.auth.existingSecret $) -}}
{{- else if .Values.postgresql.auth.existingSecret -}}
{{- printf "%s" (tpl .Values.postgresql.auth.existingSecret $) -}}
{{- else -}}
{{- printf "%s" (include "spring-petclinic.postgresql.primary.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return PostgreSQL service port
Copied from https://github.com/bitnami/charts/blob/master/bitnami/postgresql/templates/_helpers.tpl
Modified in order to be useable within the scope of this Chart
*/}}
{{- define "spring-petclinic.postgresql.service.port" -}}
{{- if .Values.postgresql.global.postgresql.service.ports.postgresql }}
    {{- .Values.postgresql.global.postgresql.service.ports.postgresql -}}
{{- else -}}
    {{- .Values.postgresql.primary.service.ports.postgresql -}}
{{- end -}}
{{- end -}}

{{/*
Return the PostgreSQL host
*/}}
{{- define "spring-petclinic.postgresql.host" -}}
{{- printf "%s.%s.svc.cluster.local" (include "spring-petclinic.postgresql.primary.fullname" .) .Release.Namespace -}}
{{- end -}}

{{/*
Return the JDBC PostgreSQL URL.
*/}}
{{- define "spring-petclinic.postgresql.url" -}}
{{- printf "jdbc:postgresql://%s:%v/%s" (include "spring-petclinic.postgresql.host" .) (include "spring-petclinic.postgresql.service.port" .) (include "spring-petclinic.postgresql.database" .) -}}
{{- end -}}