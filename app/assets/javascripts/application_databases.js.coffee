# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class ApplicationDatabasePicker
  showOrHideDatabaseChooser: ->
    if $(@checkbox).prop('checked')
      $('#database-chooser').show()
    else
      $('#database-chooser').hide()

  constructor: ->
    @checkbox_identifier = 'input[data-action=toggle-database-chooser]'
    @checkbox = $(@checkbox_identifier)
    @showOrHideDatabaseChooser()

    $('body').on 'change', @checkbox_identifier, (e) =>
      @showOrHideDatabaseChooser()


$ ->
  if $('#database-chooser')
    new ApplicationDatabasePicker()
