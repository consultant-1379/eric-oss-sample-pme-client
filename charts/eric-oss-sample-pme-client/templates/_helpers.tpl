{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eric-oss-sample-pme-client.name" }}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart version as used by the chart label.
*/}}
{{- define "eric-oss-sample-pme-client.version" }}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "eric-oss-sample-pme-client.fullname" -}}
{{- if .Values.fullnameOverride -}}
  {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- $name := default .Chart.Name .Values.nameOverride -}}
  {{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Define the service id.
*/}}
{{- define "eric-oss-sample-pme-client.serviceId" -}}
rapp-{{ include "eric-oss-sample-pme-client.name" . -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-oss-sample-pme-client.chart" }}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create image pull secrets for global (outside of scope)
*/}}
{{- define "eric-oss-sample-pme-client.pullSecret.global" -}}
{{- $pullSecret := "" -}}
{{- if .Values.global -}}
  {{- if .Values.global.pullSecret -}}
    {{- $pullSecret = .Values.global.pullSecret -}}
  {{- end -}}
  {{- end -}}
{{- print $pullSecret -}}
{{- end -}}

{{/*
Create image pull secret, service level parameter takes precedence
*/}}
{{- define "eric-oss-sample-pme-client.pullSecret" -}}
{{- $pullSecret := (include "eric-oss-sample-pme-client.pullSecret.global" . ) -}}
{{- if .Values.imageCredentials -}}
  {{- if .Values.imageCredentials.pullSecret -}}
    {{- $pullSecret = .Values.imageCredentials.pullSecret -}}
  {{- end -}}
{{- end -}}
{{- print $pullSecret -}}
{{- end -}}

{{- define "eric-oss-sample-pme-client.mainImagePath" -}}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := (index $productInfo "images" "eric-oss-sample-pme-client" "registry") -}}
    {{- $repoPath := (index $productInfo "images" "eric-oss-sample-pme-client" "repoPath") -}}
    {{- $name := (index $productInfo "images" "eric-oss-sample-pme-client" "name") -}}
    {{- $tag := (index $productInfo "images" "eric-oss-sample-pme-client" "tag") -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.global.registry.repoPath) -}}
              {{- $repoPath = .Values.global.registry.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if (index .Values "imageCredentials" "eric-oss-sample-pme-client") -}}
            {{- if (index .Values "imageCredentials" "eric-oss-sample-pme-client" "registry") -}}
                {{- if (index .Values "imageCredentials" "eric-oss-sample-pme-client" "registry" "url") -}}
                    {{- $registryUrl = (index .Values "imageCredentials" "eric-oss-sample-pme-client" "registry" "url") -}}
                {{- end -}}
            {{- end -}}
        {{- end -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- $imagePath := printf "%s/%s/%s:%s" $registryUrl $repoPath $name $tag -}}
    {{- print (regexReplaceAll "[/]+" $imagePath "/") -}}
{{- end -}}

{{/*
Timezone variable
*/}}
{{- define "eric-oss-sample-pme-client.timezone" }}
  {{- $timezone := "UTC" }}
  {{- if .Values.global }}
    {{- if .Values.global.timezone }}
      {{- $timezone = .Values.global.timezone }}
    {{- end }}
  {{- end }}
  {{- print $timezone | quote }}
{{- end -}}

{{/*
Create a user defined label (DR-D1121-068, DR-D1121-060)
*/}}
{{ define "eric-oss-sample-pme-client.config-labels" }}
  {{- $global := (.Values.global).labels -}}
  {{- $service := .Values.labels -}}
  {{- include "eric-oss-sample-pme-client.mergeLabels" (dict "location" .Template.Name "sources" (list $global $service)) }}
{{- end }}

{{/*
Merged labels for Default, which includes Standard and Config
*/}}
{{- define "eric-oss-sample-pme-client.labels" -}}
  {{- $standard := include "eric-oss-sample-pme-client.standard-labels" . | fromYaml -}}
  {{- $config := include "eric-oss-sample-pme-client.config-labels" . | fromYaml -}}
  {{- include "eric-oss-sample-pme-client.mergeLabels" (dict "location" .Template.Name "sources" (list $standard $config)) | trim }}
{{- end -}}

{{/*
Return the fsgroup set via global parameter if it's set, otherwise 10000
*/}}
{{- define "eric-oss-sample-pme-client.fsGroup.coordinated" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.fsGroup -}}
      {{- if .Values.global.fsGroup.manual -}}
        {{ .Values.global.fsGroup.manual }}
      {{- else -}}
        {{- if eq .Values.global.fsGroup.namespace true -}}
          # The 'default' defined in the Security Policy will be used.
        {{- else -}}
          10000
      {{- end -}}
    {{- end -}}
  {{- else -}}
    10000
  {{- end -}}
  {{- else -}}
    10000
  {{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "eric-oss-sample-pme-client.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create }}
    {{- default (include "eric-oss-sample-pme-client.fullname" .) .Values.serviceAccount.name }}
  {{- else }}
    {{- default "default" .Values.serviceAccount.name }}
  {{- end }}
{{- end }}

{{/*
Create the name of the postgres secret to use
*/}}
{{- define "eric-oss-sample-pme-client.pgSecretName" -}}
   {{- (include "eric-oss-sample-pme-client.fullname" .) }}-postgres-secret
{{- end }}

{{/*
Create container level annotations
*/}}
{{- define "eric-oss-sample-pme-client.container-annotations" }}
    {{- if .Values.appArmorProfile -}}
    {{- $appArmorValue := .Values.appArmorProfile.type -}}
        {{- if .Values.appArmorProfile.type -}}
            {{- if eq .Values.appArmorProfile.type "localhost" -}}
                {{- $appArmorValue = printf "%s/%s" .Values.appArmorProfile.type .Values.appArmorProfile.localhostProfile }}
            {{- end}}
container.apparmor.security.beta.kubernetes.io/eric-oss-sample-pme-client: {{ $appArmorValue | quote }}
        {{- end}}
    {{- end}}
{{- end}}

{{/*
Seccomp profile section (DR-1123-128)
*/}}
{{- define "eric-oss-sample-pme-client.seccomp-profile" }}
    {{- if .Values.seccompProfile }}
      {{- if .Values.seccompProfile.type }}
          {{- if eq .Values.seccompProfile.type "Localhost" }}
              {{- if .Values.seccompProfile.localhostProfile }}
seccompProfile:
  type: {{ .Values.seccompProfile.type }}
  localhostProfile: {{ .Values.seccompProfile.localhostProfile }}
            {{- end }}
          {{- else }}
seccompProfile:
  type: {{ .Values.seccompProfile.type }}
          {{- end }}
        {{- end }}
      {{- end }}
{{- end }}

{{/*
Annotations for Product Name and Product Number (DR-D1121-064).
*/}}
{{- define "eric-oss-sample-pme-client.product-info" }}
ericsson.com/product-name: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productName | quote }}
ericsson.com/product-number: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productNumber | quote }}
ericsson.com/product-revision: {{regexReplaceAll "(.*)[+|-].*" .Chart.Version "${1}" | quote }}
{{- end }}

{{/*
Create a user defined annotation (DR-D1121-065, DR-D1121-060)
*/}}
{{ define "eric-oss-sample-pme-client.config-annotations" }}
  {{- $global := (.Values.global).annotations -}}
  {{- $service := .Values.annotations -}}
  {{- include "eric-oss-sample-pme-client.mergeAnnotations" (dict "location" .Template.Name "sources" (list $global $service)) }}
{{- end }}

Standard labels of Helm and Kubernetes
*/}}
{{- define "eric-oss-sample-pme-client.standard-labels" -}}
app.kubernetes.io/name: {{ include "eric-oss-sample-pme-client.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ include "eric-oss-sample-pme-client.version" . }}
helm.sh/chart: {{ include "eric-oss-sample-pme-client.chart" . }}
chart: {{ include "eric-oss-sample-pme-client.chart" . }}
{{- end -}}

{{/*
Merged annotations for Default, which includes productInfo, prometheus and config
*/}}
{{- define "eric-oss-sample-pme-client.annotations" -}}
  {{- $productInfo := include "eric-oss-sample-pme-client.product-info" . | fromYaml -}}
  {{- $prometheusAnn := include "eric-oss-sample-pme-client.prometheus" . | fromYaml -}}
  {{- $config := include "eric-oss-sample-pme-client.config-annotations" . | fromYaml -}}
  {{- include "eric-oss-sample-pme-client.mergeAnnotations" (dict "location" .Template.Name "sources" (list $productInfo $prometheusAnn $config)) | trim }}
{{- end -}}

{{/*
Create prometheus info
*/}}
{{- define "eric-oss-sample-pme-client.prometheus" -}}
prometheus.io/path: {{ .Values.prometheus.path | quote }}
prometheus.io/port: {{ .Values.service.port | quote }}
prometheus.io/scrape: {{ .Values.prometheus.scrape | quote }}
{{- end -}}

{{/*
Create log control configmap name.
*/}}
{{- define "eric-oss-sample-pme-client.log-control-configmap.name" }}
  {{- include "eric-oss-sample-pme-client.name" . | printf "%s-log-control-configmap" | quote }}
{{- end -}}

{{/*
Define the role reference for security policy
*/}}
{{- define "eric-oss-sample-pme-client.securityPolicy.reference" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.security -}}
      {{- if .Values.global.security.policyReferenceMap -}}
        {{ $mapped := index .Values "global" "security" "policyReferenceMap" "default-restricted-security-policy" }}
        {{- if $mapped -}}
          {{ $mapped }}
        {{- else -}}
          default-restricted-security-policy
        {{- end -}}
      {{- else -}}
        default-restricted-security-policy
      {{- end -}}
    {{- else -}}
      default-restricted-security-policy
    {{- end -}}
  {{- else -}}
    default-restricted-security-policy
  {{- end -}}
{{- end -}}

{{/*
Define the annotations for security policy
*/}}
{{- define "eric-oss-sample-pme-client.securityPolicy.annotations" -}}
# Automatically generated annotations for documentation purposes.
{{- end -}}

{{/*
Define Pod Disruption Budget value taking into account its type (int or string)
*/}}
{{- define "eric-oss-sample-pme-client.pod-disruption-budget" -}}
  {{- if kindIs "string" .Values.podDisruptionBudget.minAvailable -}}
    {{- print .Values.podDisruptionBudget.minAvailable | quote -}}
  {{- else -}}
    {{- print .Values.podDisruptionBudget.minAvailable | atoi -}}
  {{- end -}}
{{- end -}}

{{/*
Define upper limit for TerminationGracePeriodSeconds
*/}}
{{- define "eric-oss-sample-pme-client.terminationGracePeriodSeconds" -}}
{{- if .Values.terminationGracePeriodSeconds -}}
  {{- toYaml .Values.terminationGracePeriodSeconds -}}
{{- end -}}
{{- end -}}

{{/*
Define tolerations to comply to DR-D1120-060
*/}}
{{- define "eric-oss-sample-pme-client.tolerations" -}}
{{- if .Values.tolerations -}}
  {{- toYaml .Values.tolerations -}}
{{- end -}}
{{- end -}}

{{/*
Create a merged set of nodeSelectors from global and service level.
*/}}
{{- define "eric-oss-sample-pme-client.nodeSelector" -}}
{{- $globalValue := (dict) -}}
{{- if .Values.global -}}
    {{- if .Values.global.nodeSelector -}}
      {{- $globalValue = .Values.global.nodeSelector -}}
    {{- end -}}
{{- end -}}
{{- if .Values.nodeSelector -}}
  {{- range $key, $localValue := .Values.nodeSelector -}}
    {{- if hasKey $globalValue $key -}}
         {{- $Value := index $globalValue $key -}}
         {{- if ne $Value $localValue -}}
           {{- printf "nodeSelector \"%s\" is specified in both global (%s: %s) and service level (%s: %s) with differing values which is not allowed." $key $key $globalValue $key $localValue | fail -}}
         {{- end -}}
     {{- end -}}
    {{- end -}}
    nodeSelector: {{- toYaml (merge $globalValue .Values.nodeSelector) | trim | nindent 2 -}}
{{- else -}}
  {{- if not ( empty $globalValue ) -}}
    nodeSelector: {{- toYaml $globalValue | trim | nindent 2 -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
    Define Image Pull Policy
*/}}
{{- define "eric-oss-sample-pme-client.registryImagePullPolicy" -}}
    {{- $globalRegistryPullPolicy := "IfNotPresent" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.imagePullPolicy -}}
                {{- $globalRegistryPullPolicy = .Values.global.registry.imagePullPolicy -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- print $globalRegistryPullPolicy -}}
{{- end -}}



{/*
Define JVM heap size (DR-D1126-010 | DR-D1126-011)
*/}}
{{- define "eric-oss-sample-pme-client.jvmHeapSettings" -}}
    {{- $initRAM := "" -}}
    {{- $maxRAM := "" -}}
    {{/*
       ramLimit is set by default to 1.0, this is if the service is set to use anything less than M/Mi
       Rather than trying to cover each type of notation,
       if a user is using anything less than M/Mi then the assumption is its less than the cutoff of 1.3GB
       */}}
    {{- $ramLimit := 1.0 -}}
    {{- $ramComparison := 1.3 -}}

    {{- if not (index .Values "resources" "eric-oss-sample-pme-client" "limits" "memory") -}}
        {{- fail "memory limit for eric-oss-sample-pme-client is not specified" -}}
    {{- end -}}

    {{- if (hasSuffix "Gi" (index .Values "resources" "eric-oss-sample-pme-client" "limits" "memory")) -}}
        {{- $ramLimit = trimSuffix "Gi" (index .Values "resources" "eric-oss-sample-pme-client" "limits" "memory") | float64 -}}
    {{- else if (hasSuffix "G" (index .Values "resources" "eric-oss-sample-pme-client" "limits" "memory")) -}}
        {{- $ramLimit = trimSuffix "G" (index .Values "resources" "eric-oss-sample-pme-client" "limits" "memory") | float64 -}}
    {{- else if (hasSuffix "Mi" (index .Values "resources" "eric-oss-sample-pme-client" "limits" "memory")) -}}
        {{- $ramLimit = (div (trimSuffix "Mi" (index .Values "resources" "eric-oss-sample-pme-client" "limits" "memory") | float64) 1000) | float64  -}}
    {{- else if (hasSuffix "M" (index .Values "resources" "eric-oss-sample-pme-client" "limits" "memory")) -}}
        {{- $ramLimit = (div (trimSuffix "M" (index .Values "resources" "eric-oss-sample-pme-client" "limits" "memory") | float64) 1000) | float64  -}}
    {{- end -}}

    {{- if (index .Values "resources" "eric-oss-sample-pme-client" "jvm") -}}
        {{- if (index .Values "resources" "eric-oss-sample-pme-client" "jvm" "initialMemoryAllocationPercentage") -}}
            {{- $initRAM = index .Values "resources" "eric-oss-sample-pme-client" "jvm" "initialMemoryAllocationPercentage" | float64 -}}
            {{- $initRAM = printf "-XX:InitialRAMPercentage=%f" $initRAM -}}
        {{- else -}}
            {{- fail "initialMemoryAllocationPercentage not set" -}}
        {{- end -}}
        {{- if and (index .Values "resources" "eric-oss-sample-pme-client" "jvm" "smallMemoryAllocationMaxPercentage") (index .Values "resources" "eric-oss-sample-pme-client" "jvm" "largeMemoryAllocationMaxPercentage") -}}
            {{- if lt $ramLimit $ramComparison -}}
                {{- $maxRAM =index .Values "resources" "eric-oss-sample-pme-client" "jvm" "smallMemoryAllocationMaxPercentage" | float64 -}}
                {{- $maxRAM = printf "-XX:MaxRAMPercentage=%f" $maxRAM -}}
            {{- else -}}
                {{- $maxRAM = index .Values "resources" "eric-oss-sample-pme-client" "jvm" "largeMemoryAllocationMaxPercentage" | float64 -}}
                {{- $maxRAM = printf "-XX:MaxRAMPercentage=%f" $maxRAM -}}
            {{- end -}}
        {{- else -}}
            {{- fail "smallMemoryAllocationMaxPercentage | largeMemoryAllocationMaxPercentage not set" -}}
        {{- end -}}
    {{- else -}}
        {{- fail "jvm heap percentages are not set" -}}
    {{- end -}}
{{- printf "%s %s" $initRAM $maxRAM -}}
{{- end -}}

{{/*
Define the log streaming method parameter (DR-470222-010)
*/}}
{{- define "eric-oss-sample-pme-client.streamingMethod" -}}
{{- $streamingMethod := "direct" -}}
{{- if .Values.global -}}
  {{- if .Values.global.log -}}
      {{- if .Values.global.log.streamingMethod -}}
        {{- $streamingMethod = .Values.global.log.streamingMethod }}
      {{- end -}}
  {{- end -}}
{{- end -}}
{{- if .Values.log -}}
  {{- if .Values.log.streamingMethod -}}
    {{- $streamingMethod = .Values.log.streamingMethod }}
  {{- end -}}
{{- end -}}
{{- print $streamingMethod -}}
{{- end -}}

{{/*
Define the label needed for reaching eric-log-transformer (DR-470222-010)
*/}}
{{- define "eric-oss-sample-pme-client.directStreamingLabel" -}}
{{- $streamingMethod := (include "eric-oss-sample-pme-client.streamingMethod" .) -}}
{{- if or (eq "direct" $streamingMethod) (eq "dual" $streamingMethod) }}
logger-communication-type: "direct"
{{- end -}}
{{- end -}}

{{/*
Define logging environment variables and decide on expected behavior (DR-470222-010)
*/}}
{{ define "eric-oss-sample-pme-client.loggingEnv" }}
{{- $streamingMethod := (include "eric-oss-sample-pme-client.streamingMethod" .) -}}
{{- if or (eq "direct" $streamingMethod) (eq "dual" $streamingMethod) -}}
  {{- if eq "direct" $streamingMethod }}
- name: LOGBACK_CONFIG_FILE
  value: "classpath:logback-http.xml"
  {{- end }}
  {{- if eq "dual" $streamingMethod }}
- name: LOGBACK_CONFIG_FILE
  value: "classpath:logback-dual.xml"
  {{- end }}
- name: LOGSTASH_DESTINATION
  value: eric-log-transformer
- name: LOGSTASH_PORT
  value: "9080"
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: POD_UID
  valueFrom:
    fieldRef:
      fieldPath: metadata.uid
- name: CONTAINER_NAME
  value: eric-oss-sample-pme-client
- name: NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
- name: NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
{{- else if eq $streamingMethod "indirect" }}
- name: LOGBACK_CONFIG_FILE
  value: "classpath:logback-json.xml"
{{- else }}
  {{- fail ".log.streamingMethod unknown" }}
{{- end -}}
{{ end }}

{{/*
API GW hostname
*/}}
{{ define "eric-oss-sample-pme-client.apiGwHost" }}
  {{- $apiGwHost := "" -}}
  {{- if ((((.Values).global).hosts).gas) -}}
    {{- $apiGwHost = ((((.Values).global).hosts).gas) -}}
  {{- end -}}
  {{- if (((.Values).apiGateway.route).host) -}}
    {{- $apiGwHost = (((.Values).apiGateway.route).host) -}}
  {{- end -}}
  {{- printf "%s" $apiGwHost -}}
{{- end -}}

{{/*
API GW URL
*/}}
{{ define "eric-oss-sample-pme-client.apiGwUrl" }}
  {{- printf "https://%s" (include "eric-oss-sample-pme-client.apiGwHost" . ) -}}
{{- end -}}

{{/*
IAM URL
*/}}
{{ define "eric-oss-sample-pme-client.iamUrl" }}
  {{- $iamHost := .Values.baseUrl -}}
  {{- if ((((.Values).global).hosts).iam) -}}
    {{- $iamHost = ((((.Values).global).hosts).iam) -}}
  {{- end -}}
  {{- if (((.Values).iam).host) -}}
    {{- $iamHost = (((.Values).iam).host) -}}
  {{- end -}}
  {{ if hasPrefix "https://" $iamHost }}
    {{- printf "%s" $iamHost -}}
  {{ else }}
    {{- printf "https://%s" $iamHost -}}
  {{- end -}}
{{- end -}}

{{/*
PME Hostname
*/}}
{{ define "eric-oss-sample-pme-client.pmeHost" }}
  {{- $pmeHost := "" -}}
  {{- if ((((.Values).global).hosts).gas) -}}
    {{- $pmeHost = ((((.Values).global).hosts).gas) -}}
  {{- end -}}
  {{- if (((.Values).pme).host) -}}
    {{- $pmeHost = (((.Values).pme).host) -}}
  {{- end -}}
  {{- printf "%s" $pmeHost -}}
{{- end -}}

{{/*
PME URL
*/}}
{{ define "eric-oss-sample-pme-client.pmeUrl" }}
  {{- $pmeUrl := (include "eric-oss-sample-pme-client.pmeHost" . ) -}}
  {{- if (((.Values).pme).url) -}}
    {{- $pmeUrl = (((.Values).pme).url) -}}
  {{- end -}}
  {{ if (or (hasPrefix "https://" $pmeUrl) (hasPrefix "http://" $pmeUrl)) }}
    {{- printf "%s" $pmeUrl -}}
  {{ else }}
    {{- printf "https://%s" $pmeUrl -}}
  {{- end -}}
{{- end -}}

{{/*
TLS version
*/}}
{{ define "eric-oss-sample-pme-client.clientProtocol" }}
  {{- $clientProtocol := .Values.tls.clientProtocol -}}
  {{- printf "-Djdk.tls.client.protocols=%s" $clientProtocol -}}
{{- end -}}