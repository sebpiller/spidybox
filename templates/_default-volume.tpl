{{- define "default-volume-local" }}

{{- range $volume := .Values.volumes }}
{{ if eq $volume.storageClassName "nfs-client" }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: "{{ $.Release.Namespace }}"
  name: "{{ $.Values.name }}-{{ $volume.name }}-pv"
  labels:
    type: remote
spec:
  storageClassName: "{{ $volume.storageClassName }}"
  capacity:
    storage: {{ $volume.capacity }}
  accessModes:
    - {{ $volume.accessMode | default "ReadWriteOnce" }}
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: "{{ $.Values.global.nfsVolume.path }}/{{ $volume.subPath }}"
    server: "{{ $.Values.global.nfsVolume.server }}"
    readOnly: {{ $.Values.global.nfsVolume.readOnly | default false }}
{{ else }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: "{{ $.Release.Namespace }}"
  name: "{{ $.Values.name }}-{{ $volume.name }}-pv"
spec:
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem
  storageClassName: "{{ $volume.storageClassName | default "local-path" }}"
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



{{- range $volume := .Values.volumes }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: "{{ $.Release.Namespace }}"
  name: "{{ $.Values.name }}-{{ $volume.name }}-pvc"
spec:
  volumeMode: Filesystem
  {{ if $volume.storageClassName }}
  storageClassName: "{{ $volume.storageClassName }}"
  {{ end }}
  volumeName: "{{ $.Values.name }}-{{ $volume.name }}-pv"
  accessModes:
    - {{ $volume.accessMode | default "ReadWriteOnce" }}
  resources:
    requests:
      storage: "{{ $volume.capacity }}"
{{- end }}
{{- end }}

