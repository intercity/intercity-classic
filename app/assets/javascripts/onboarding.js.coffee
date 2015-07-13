# TODO: Merge this 2 on click listeners to one
$ ->
  $("[data-form-area=initial]").removeClass("hidden")
  $("[data-form-area]:not([data-form-area='initial'])").addClass("hidden")
  $("[data-role~=form-step-ssh] :input").prop("disabled", true)

  $(document).on 'click', '[data-action=test-server-connection]', (e) ->
    parent = $(e.target).parents("[data-role~=form-step]")
    e.preventDefault()
    $(e.target).addClass("hidden")
    parent.find("[data-form-area=working]").removeClass("hidden")

    parent.find("[data-form-area=error]").addClass("hidden")
    parent.removeClass("error")

    ip = parent.find("[data-form-field=ip]").val()
    port = parent.find("[data-form-field=port]").val()
    $.post($(e.target).data("server-test-url"), { ip: ip, port: port })

  $(document).on 'click', '[data-action=verify-ssh-key]', (e) ->
    parent = $(e.target).parents("[data-role~=form-step]")
    e.preventDefault()
    $(e.target).addClass("hidden")
    parent.find("[data-form-area=working]").removeClass("hidden")

    parent.find("[data-form-area=error]").addClass("hidden")
    parent.removeClass("error")

    ip_form = $(document).find("[data-role~=form-step-ip]")
    ip = ip_form.find("[data-form-field=ip]").val()
    port = ip_form.find("[data-form-field=port]").val()
    user = parent.find("[data-form-field=user]").val()
    $.post($(e.target).data("server-test-url"),
    { ip: ip, port: port, user: user })
