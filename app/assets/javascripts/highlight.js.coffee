ready = ->
  enableSyntaxHighlighting()

enableSyntaxHighlighting = ->
  $(".js-code-highlighting").find('pre code').each (i, block) ->
    hljs.highlightBlock block

$(document).ready(ready)
$(document).on('page:load', ready)
