{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{- define "charts.default.host" -}}
{{- if eq .Values.global.hosts.default.protocol "http" -}}
{{- .Values.global.hosts.http.dnsNames | first -}}
{{- else -}}
{{- .Values.global.hosts.https.dnsNames | first -}}
{{- end -}}
{{- end }}

{{- define "charts.host.external.tp" -}} 
{{- .Values.global.hosts.default.protocol }}://{{ include "charts.default.host" . -}}
{{- end }}

{{- define "charts.certificate.secretName" -}}
{{- .Release.Namespace -}}-tls-secret
{{- end -}}

{{- define "charts.name" -}}
{{- default .Chart.Name .Values.global.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "charts.mongo.secretname." }}
{{ default "mongo" .Values.global.mongo.secretName }}
{{- end -}}

{{- define "charts.externalSecrets.role" -}}
{{ .Values.global.cluster.name }}-{{ .Release.Namespace}}-secrets-role
{{- end -}}

{{- define "charts.roles.permitted" -}}
{{- .Release.Namespace -}}/.*
{{- end -}}

{{- define "charts.worker.role" -}}
{{ .Values.global.cluster.name }}-{{ .Release.Namespace}}-worker-role
{{- end -}}

{{- define "charts.host.internal.tp" -}} internal {{- end }}

{{ define "charts.host.internal.address" -}}
http://{{include "charts.host.internal.tp" .}}.{{.Release.Namespace}}
{{- end }}

{{- define "charts.s3.url" -}} https://s3-{{.Values.global.cluster.region}}.amazonaws.com {{- end }}

{{- define "charts.image.s3.bucket" -}}
{{- if (.Values.image.bucket) and (ne .Values.image.bucket "") -}}
{{ .Values.image.bucket }}
{{- else -}}
tidepool-{{ .Release.Namespace }}-data
{{- end -}}
{{- end -}}

{{- define "charts.blob.s3.bucket" -}}
{{- if (.Values.blob.bucket) and (ne .Values.blob.bucket "") -}}
{{ .Values.blob.bucket }}
{{- else -}}
tidepool-{{ .Release.Namespace }}-data
{{- end -}}
{{- end -}}

{{- define "charts.hydrophone.s3.bucket" -}}
{{- if (.Values.hydrophone.bucket) and (ne .Values.hydrophone.bucket "") -}}
{{ .Values.hydrophone.bucket }}
{{- else -}}
tidepool-{{ .Release.Namespace }}-asset
{{- end -}}
{{- end -}}

{{- define "charts.jellyfish.s3.bucket" -}}
{{- if (.Values.jellyfish.bucket) and (ne .Values.jellyfish.bucket "") -}}
{{ .Values.jellyfish.bucket }}
{{- else -}}
tidepool-{{ .Release.Namespace }}-data
{{- end -}}
{{- end -}}

{{- define "charts.image.s3.url" -}} {{include "charts.s3.url" .}}/{{include "charts.image.s3.bucket" .}} {{- end }}
{{- define "charts.blob.s3.url" -}} {{include "charts.s3.url" .}}/{{include "charts.blob.s3.bucket" .}} {{- end }}
{{- define "charts.hydrophone.s3.url" -}} {{include "charts.s3.url" .}}/{{include "charts.hydrophone.s3.bucket" .}} {{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "charts.fullname" -}}
{{- if .Values.global.fullnameOverride -}}
{{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.global.nameOverride -}}
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
{{- define "charts.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "charts.secret.prefix" -}}
{{ .Values.global.cluster.name }}/{{ .Release.Namespace }}
{{- end -}}

{{/*
Create environment variables used by all platform services.
*/}}

{{ define "charts.platform.env.dexcom" }}
        - name: TIDEPOOL_SERVICE_PROVIDER_DEXCOM_AUTHORIZE_URL
          value: '{{.Values.global.provider.dexcom.authorize.url}}'
        - name: TIDEPOOL_SERVICE_PROVIDER_DEXCOM_REDIRECT_URL
          value: {{include "charts.host.external.tp" .}}/v1/oauth/dexcom/redirect
        - name: TIDEPOOL_SERVICE_PROVIDER_DEXCOM_SCOPES
          value: offline_access
        - name: TIDEPOOL_SERVICE_PROVIDER_DEXCOM_TOKEN_URL
          value: '{{.Values.global.provider.dexcom.token.url}}'
        - name: TIDEPOOL_SERVICE_PROVIDER_DEXCOM_CLIENT_ID
          valueFrom:
            secretKeyRef:
              name: dexcom-api
              key: ClientId
              optional: true
        - name: TIDEPOOL_SERVICE_PROVIDER_DEXCOM_CLIENT_SECRET
          valueFrom:
            secretKeyRef:
              name: dexcom-api
              key: ClientSecret
              optional: true
        - name: TIDEPOOL_SERVICE_PROVIDER_DEXCOM_STATE_SALT
          valueFrom:
            secretKeyRef:
              name: dexcom-api
              key: StateSalt
              optional: true
{{ end }}

{{ define "charts.platform.env.clients" }}
        - name: TIDEPOOL_AUTH_CLIENT_ADDRESS
          value: http://auth:{{.Values.global.ports.auth}}
        - name: TIDEPOOL_AUTH_CLIENT_EXTERNAL_ADDRESS
          value: "{{ include "charts.host.internal.address" .}}"
        - name: TIDEPOOL_AUTH_CLIENT_EXTERNAL_SERVER_SESSION_TOKEN_SECRET
          valueFrom:
            secretKeyRef:
              name: tidepool-server-secret
              key: ServiceAuth
        - name: TIDEPOOL_BLOB_CLIENT_ADDRESS
          value: http://blob:{{.Values.global.ports.blob}}
        - name: TIDEPOOL_DATA_CLIENT_ADDRESS
          value: http://data:{{.Values.global.ports.data}}
        - name: TIDEPOOL_DATA_SOURCE_CLIENT_ADDRESS
          value: http://data:{{.Values.global.ports.data}}
        - name: TIDEPOOL_DEXCOM_CLIENT_ADDRESS
          value: '{{.Values.global.provider.dexcom.client.url}}'
        - name: TIDEPOOL_IMAGE_CLIENT_ADDRESS
          value: http://image:{{.Values.global.ports.image}}
        - name: TIDEPOOL_METRIC_CLIENT_ADDRESS
          value: "{{ include "charts.host.internal.address" .}}"
        - name: TIDEPOOL_NOTIFICATION_CLIENT_ADDRESS
          value: http://notification:{{.Values.global.ports.notification}}
        - name: TIDEPOOL_PERMISSION_CLIENT_ADDRESS
          value: http://gatekeeper:{{.Values.global.ports.gatekeeper}}
        - name: TIDEPOOL_TASK_CLIENT_ADDRESS
          value: http://task:{{.Values.global.ports.task}}
        - name: TIDEPOOL_USER_CLIENT_ADDRESS
          value: "{{ include "charts.host.internal.address" .}}"
{{ end }}

{{ define "charts.platform.env.misc" }}
        - name: TIDEPOOL_ENV
          value: local
        - name: TIDEPOOL_LOGGER_LEVEL
          value: debug
        - name: TIDEPOOL_SERVER_TLS
          value: "false"
        - name: TIDEPOOL_AUTH_SERVICE_SECRET
          valueFrom:
            secretKeyRef:
              name: auth
              key: ServiceAuth
{{ end }}

{{- define "charts.mongo.secretName" -}}
{{- default "mongo" .Values.mongo.secretName -}}
{{- end -}}

{{ define "charts.mongo.params" }}
        - name: TIDEPOOL_STORE_SCHEME
          valueFrom:
            secretKeyRef:
              name: {{ include "charts.mongo.secretName" . }}
              key: scheme
        - name: TIDEPOOL_STORE_USERNAME
          valueFrom:
            secretKeyRef:
              name: {{ include "charts.mongo.secretName" . }}
              key: username
        - name: TIDEPOOL_STORE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ include "charts.mongo.secretName" . }}
              key: password
              optional: true
        - name: TIDEPOOL_STORE_ADDRESSES
          valueFrom:
            secretKeyRef:
              name: {{ include "charts.mongo.secretName" . }}
              key: addresses
        - name: TIDEPOOL_STORE_OPT_PARAMS
          valueFrom:
            secretKeyRef:
              name: {{ include "charts.mongo.secretName" . }}
              key: optparams
        - name: TIDEPOOL_STORE_TLS
          valueFrom:
            secretKeyRef:
              name: {{ include "charts.mongo.secretName" . }}
              key: tls
{{ end }}

{{ define "charts.platform.env.mongo" }}
{{ include "charts.mongo.params" . }}
        - name: TIDEPOOL_STORE_DATABASE
          value: tidepool
{{ end }}        

{{/*
Create liveness and readiness probes for platform services.
*/}}
{{- define "charts.platform.probes" -}}
        livenessProbe:
          httpGet:
            path: /status
            port: {{.}}
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
        readinessProbe:
          httpGet:
            path: /status
            port: {{.}}
          initialDelaySeconds: 5
          periodSeconds: 10
          timeoutSeconds: 5
{{- end -}} 
{{- define "charts.init.shoreline" -}}
      - name: init-shoreline
        image: busybox
        command: ['sh', '-c', 'until nc -zvv shoreline {{.Values.global.ports.shoreline}}; do echo waiting for shoreline; sleep 2; done;']
{{- end -}} 
