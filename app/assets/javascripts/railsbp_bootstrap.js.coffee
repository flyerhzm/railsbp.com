# $ ->
#   $("body > .topbar").scrollSpy()
$ ->
  $(".tabs").tabs()
# $ ->
#   $("a[rel=twipsy]").twipsy live: true
# $ ->
#   $("a[rel=popover]").popover offset: 10
# $ ->
#   $(".topbar-wrapper").dropdown()
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
$ ->
  $(".btn").button "complete"

$ ->
  $('.topbar').dropdown()
