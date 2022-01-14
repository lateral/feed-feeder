# data for configMap
{{- define "feed-feeder.config_map_data" }}
  DB_HOST: {{ .Values.feedFeeder.database.host | quote }}
  DB_PORT: {{ .Values.feedFeeder.database.port | quote }}
  DB_DATABASE: {{ .Values.feedFeeder.database.name | quote }}
  DB_USERNAME: {{ .Values.feedFeeder.database.user | quote }}
  RAILS_ENV: "production"
  REDIS_URL: {{ .Values.feedFeeder.redis.url | quote }}
  FEED_FEEDER_DOMAIN: {{ .Values.feedFeeder.dns.hostname }}
{{- end }}

# Data for secret
{{- define "feed-feeder.secret_data" }}
  SENTRY_DSN: {{ .Values.feedFeeder.sentry.dsn | b64enc | quote }}
  DB_PW: {{ .Values.feedFeeder.database.password | b64enc| quote }}
  SECRET_KEY_BASE: {{ .Values.feedFeeder.secretKeyBase | b64enc | quote }}
  HTTP_AUTH_PASSWORD: {{ .Values.feedFeeder.httpAuthPassword | b64enc | quote }}
{{- end }}

# Images configuration

{{- define "images.config_map_data" }}
  DB_HOST: {{ .Values.feedFeeder.database.host | quote }}
  DB_PORT: {{ .Values.feedFeeder.database.port | quote }}
  DB_DATABASE: {{ .Values.feedFeeder.database.name | quote }}
  DB_USERNAME: {{ .Values.feedFeeder.database.user | quote }}
  GOOGLE_CREDS_LOCATION: "/app/images_storage_creds.json"
  GOOGLE_PROJECT: {{ .Values.feedFeeder.images.googleProject | quote }}
  GOOGLE_BUCKET_NAME: {{ .Values.feedFeeder.images.googleBucket | quote }}
{{- end }}

{{- define "images.secret_data" }}
  DB_PW: {{ .Values.feedFeeder.database.password | b64enc| quote }}
{{- end }}
