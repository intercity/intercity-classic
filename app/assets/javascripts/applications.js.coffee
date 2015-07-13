# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click', 'a#IntercomReportProblem', ->
  Intercom('show');
  url = $(this).attr('data-url')
  textarea = $('textarea#newMessageBody')
  textarea.val("I think I found a bug in " + url + "\n\n")
  textarea[0].selectionStart = textarea[0].selectionEnd = textarea.val().length
  return false

$(document).on 'click', 'a#IntercomContactUs', ->
  Intercom('show');
  return false

$ ->
  $("[data-behavior='show-modal']").magnificPopup({
    type: "inline",
    midClick: true
  })

$(document).on 'click', 'div.toggle-inputs', ->
  $(this).next('table').toggle()
  $(this).find('i').
    toggleClass('fa-chevron-right').
    toggleClass('fa-chevron-down')
