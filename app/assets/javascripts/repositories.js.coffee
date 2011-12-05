# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  $("#repository .tabs .current").click ->
    $(this).addClass("active")
    $("#repository .tabs .history").removeClass("active")
    $("#repository > .current").show()
    $("#repository > .history").hide()
  $("#repository .tabs .history").click ->
    $(this).addClass("active")
    $("#repository .tabs .current").removeClass("active")
    $("#repository > .history").show()
    $("#repository > .current").hide()
