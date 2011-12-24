# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
  subscription.setupForm()

subscription =
  setupForm: ->
    $('#creditCardFormModal .edit_user').submit ->
      $('input[type=submit]').attr('disabled', true)
      if $("#card_number").length > 0
        subscription.processCard()
        false
      else
        true

  processCard: ->
    card =
      number: $('#card_number').val()
      cvc: $('#card_code').val()
      expMonth: $('#card_month').val()
      expYear: $('#card_year').val()
    Stripe.createToken(card, subscription.handleStripeResponse)

  handleStripeResponse: (status, response) ->
    if status == 200
      $('#user_stripe_card_token').val(response.id)
      $('#creditCardFormModal .edit_user')[0].submit()
    else
      $('#stripe_error').addClass("alert-message block-message error").text(response.error.message)
      $('input[type=submit]').attr('disabled', false)

