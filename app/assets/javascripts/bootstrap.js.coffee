# $ ->
#   $("body > .navbar").scrollSpy()
$ ->
   $("a[rel=tooltip]").tooltip()
# $ ->
#   $("a[rel=popover]").popover offset: 10
# $ ->
#   $(".navbar-wrapper").dropdown()
$ ->
  $(".alert-message").alert()
$ ->
  creditCardFormModal = $("#creditCardFormModal").modal(
    backdrop: true
    closeOnEscape: true
  )
  $(".open-credit-card-form-modal").click ->
    creditCardFormModal.toggle()

  creditCardModal = $("#creditCardModal").modal(
    backdrop: true
    closeOnEscape: true
  )
  $(".open-credit-card-modal").click ->
    creditCardModal.toggle()

  $(".modal .close").click ->
    $(this).parents(".modal").toggle()
