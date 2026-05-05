; extends

; Inject YAML into non-jinja content (for *.yaml.j2 files).
((content) @injection.content
  (#set! injection.language "yaml")
  (#set! injection.combined))
