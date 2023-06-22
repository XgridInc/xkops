{{ define "xkops.configfile" -}}

active_workflows:

{{- if .Values.customWorkflows }}
{{ toYaml .Values.customWorkflows | indent 2 }}
{{- end }}

{{ end }}
