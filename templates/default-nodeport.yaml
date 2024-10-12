{{- define "default-nodeport" }}
apiVersion: v1
kind: Service
metadata:
  namespace: "{{ .Release.Namespace }}"
  name: "{{ .Values.name }}-svc"
spec:
  type: NodePort
  ports:
    {{- range $p := .Values.ports }}
    -  name: "{{ $p.name }}"
       port: {{ $p.port }}
       targetPort: {{ $p.port }}
       nodePort: {{ $p.nodePort }}
       protocol: "{{ $p.protocol | default "TCP" }}"
    {{- end }}
  selector:
    app: {{ .Values.name }}
  {{- end }}