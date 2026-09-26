; extends

; Inject YAML into non-jinja content, only for *.yaml.j2 files (filetype yamljinja).
; #buf-filetype? is registered in lua/plugins/treesitter.lua.
((content) @injection.content
  (#buf-filetype? "yamljinja")
  (#set! injection.language "yaml")
  (#set! injection.combined))
