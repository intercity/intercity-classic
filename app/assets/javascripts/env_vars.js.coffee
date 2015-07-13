# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'click', 'td[data-action=toggle-var-visibility]',(e) ->
  e.preventDefault()
  var_id = $(this).data('env-var-id')

  $('tr#env_var_' + var_id).find('.js-hidden-var').toggle()
  $('tr#env_var_' + var_id).find('.js-starred-var').toggle()

