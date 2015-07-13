$(document).on 'click', 'input[data-action=backup-switch]', (e) ->
  if $(this).is(':checked')
    $('.backup-settings').removeClass('hidden')
  else
    $('.backup-settings').addClass('hidden')

$ ->
  if $('#load-backups').length
    $.get($('#load-backups').data('fetch-backups-url'))

