{{- define "default-deployment" }}
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: "{{ $.Release.Namespace }}"
  name: "{{ .Values.name }}-dep"
  labels:
    app: "{{ .Values.name }}"
spec:
  replicas: {{ .Values.replicas }}
  selector:
    matchLabels:
      app: "{{ .Values.name }}"
  template:
    metadata:
      labels:
        app: "{{ .Values.name }}"
    spec:
      terminationGracePeriodSeconds: 10
      {{ if .Values.init }}
      initContainers:
        - name: "{{ .Values.name }}-init"
          image: "{{ .Values.init.image }}:{{ .Values.init.version }}"
          command:
            {{- range $c := $.Values.init.commands }}
            - {{ $c | quote }}
            {{- end}}
          volumeMounts:
            {{- range $volume := .Values.volumes }}
            - name: "{{ $volume.name }}"
              mountPath: "/vol-{{ $volume.name }}"
            {{- end }}
      {{- end }}
      containers:
        {{ if $.Values.debug }}
        - name: "{{ .Values.name }}-debug"
          image: "ubuntu:latest"
          imagePullPolicy: IfNotPresent
          resources:
            limits:
              memory: "512Mi"
              cpu: "1000m"
          command:
            - "sh"
            - "-c"
            - "sleep 3600"
          volumeMounts:
            {{- range $volume := .Values.volumes }}
            - name: "{{ $volume.name }}"
              mountPath: "/vol-{{ $volume.name }}"
            {{- end }}
        {{- end }}
        - name: "{{ .Values.name }}-app"
          image: "{{ .Values.image }}:{{ .Values.version }}"
          imagePullPolicy: IfNotPresent
          {{ if .Values.netadmin }}
          stdin: true
          tty: true
          securityContext:
            privileged: true
            capabilities:
              add:
                - NET_ADMIN
          {{- end }}
          {{ if and $.Values.probes $.Values.probes.commands }}
          startupProbe:
            initialDelaySeconds: 10
            terminationGracePeriodSeconds: 30
            exec:
              command:
                {{- range $c := $.Values.probes.commands }}
                - {{ $c | quote }}
                {{- end }}
          readinessProbe:
            initialDelaySeconds: 30
            exec:
              command:
                {{- range $c := $.Values.probes.commands }}
                - {{ $c | quote }}
                {{- end }}
          livenessProbe:
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 3
            terminationGracePeriodSeconds: 30
            exec:
              command:
                {{- range $c := $.Values.probes.commands }}
                - {{ $c | quote }}
                {{- end }}
          {{- else if and .Values.probes .Values.probes.http }}
          startupProbe:
            initialDelaySeconds: 10
            terminationGracePeriodSeconds: 30
            httpGet:
              path: "{{ $.Values.probes.http.path }}"
              port: {{ $.Values.probes.http.port }}
          readinessProbe:
            initialDelaySeconds: 30
            httpGet:
              path: "{{ $.Values.probes.http.path }}"
              port: {{ $.Values.probes.http.port }}
          livenessProbe:
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 3
            terminationGracePeriodSeconds: 30
            httpGet:
              path: "{{ $.Values.probes.http.path }}"
              port: {{ $.Values.probes.http.port }}
          {{- end }}
          resources:
            requests:
              {{ if $.Values.resources.requests }}
              memory: "{{ $.Values.resources.requests.memory }}"
              cpu: "{{ $.Values.resources.requests.cpu }}"
              {{ else }}
              memory: "{{ $.Values.resources.limits.memory | default "512Mi" }}"
              cpu: "{{ $.Values.resources.limits.cpu | default "100m" }}"
              {{ end }}
            limits:
              memory: "{{ $.Values.resources.limits.memory | default "512Mi" }}"
              cpu: "{{ $.Values.resources.limits.cpu | default "100m" }}"
          ports:
            {{- range $p := .Values.ports }}
            - containerPort: {{ $p.port }}
            {{- end }}
          volumeMounts:
            {{- range $volume := .Values.volumes }}
            - name: "{{ $volume.name }}"
              mountPath: "/{{ $volume.name }}"
            {{- end }}
      volumes:
        {{- range $volume := .Values.volumes }}
        - name: "{{ $volume.name }}"
          persistentVolumeClaim:
            {{ if $volume.claimName }}
            claimName: "{{ $volume.claimName }}"
            {{ else }}
            claimName: "{{ $.Values.name }}-{{ $volume.name }}-pvc"
            {{ end }}
        {{- end }}

{{- end }}