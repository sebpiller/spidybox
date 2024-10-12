{{- define "default-volume-local" }}

{{ if $.Values.claimName }}
{{ else }}
{{- range $volume := .Values.volumes }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: "{{ $.Release.Namespace }}"
  name: "{{ $.Values.name }}-{{ $volume.name }}-pv"
spec:
  storageClassName: "local-path"
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem
  claimRef:
    namespace: "{{ $.Release.Namespace }}"
    name: "{{ $.Values.name }}-{{ $volume.name }}-pvc"
  capacity:
    storage: "{{ $volume.capacity }}"
  accessModes:
    - {{ $volume.accessMode | default "ReadWriteOnce" }}
  hostPath:
    path: "{{ $.Values.global.localStorageRootPath | default "/data" }}/{{ $.Release.Namespace }}/{{ $.Values.name }}/{{ $volume.name }}"
{{- end }}
{{- end }}



{{ if $.Values.claimName }}
{{ else }}
{{- range $volume := .Values.volumes }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: "{{ $.Release.Namespace }}"
  name: "{{ $.Values.name }}-{{ $volume.name }}-pvc"
spec:
  volumeMode: Filesystem
  volumeName: "{{ $.Values.name }}-{{ $volume.name }}-pv"
  accessModes:
    - {{ $volume.accessMode | default "ReadWriteOnce" }}
  resources:
    requests:
      storage: "{{ $volume.capacity }}"
{{- end }}
{{- end }}


{{- end }}