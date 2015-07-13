# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click', 'a[data-behavior=activate-intercom]', (e) ->
  e.preventDefault()
  Intercom('show')

$(document).on 'click', 'div[data-action=type-selection]', ->
  return if $(this).hasClass('inactive')
  provider = $(this).attr('id')
  $('div[data-action=type-selection]').removeClass('active')
  $('input#server_provider').val(provider)
  $(this).addClass('active')
  $('section.servers').find('.server-type').addClass('hidden')
  $('section.servers').find('.server-type').each ->
    if $(this).data('server-type') == provider
      $(this).removeClass('hidden')


