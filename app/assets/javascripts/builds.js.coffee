# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  if $("#build").length > 0
    checks = []
    $("#build table tr").each (index, item) ->
      if index > 0 && $.inArray($(item).attr("class"), checks) == -1
        checks.push $(item).attr("class")
    checksPanel = $("#checksPanel")
    checksPanel.hide()
    $.each(checks, (index, check) ->
      checksPanel.append($("<li><input id='"+check+"' type='checkbox' value='"+check+"' /><label for='"+check+"'>"+check+"</label></li>"))
    )
    $("#customizeChecks").click ->
      if $(this).hasClass("minus_icon")
        checksPanel.hide()
        $(this).removeClass("minus_icon").addClass("plus_icon")
      else
        checksPanel.show()
        $(this).addClass("minus_icon").removeClass("plus_icon")
      return false
    $("input[type=checkbox]").prop("checked", true)
    $("input[type=checkbox]").click ->
      if $(this).prop("checked")
        $("."+$(this).val()).show()
      else
        $("."+$(this).val()).hide()

$ ->
  $("#history table tr").click ->
    url = $(this).data("url")
    window.location.href = url
    return false

$ ->
  if $("#build").length > 0
    $("#build table thead tr").append("<th class='report'></th>")
    $.each $("#build table tbody tr"), ->
      message = "repository : #{$('h2').text()}<nl>" +
                "branch     : #{$(this).find('.branch').text()}<nl>" +
                "commit     : #{$('#commit_id').text()}<nl>" +
                "filename   : #{$(this).find('.filename').text()}<nl>" +
                "line       : #{$(this).find('.line').text()}<nl>" +
                "message    : #{$(this).find('.message').text()}<nl>" +
                "is not analyzing correctly"
      $(this).append("<td class='report'><a class='btn' href='/contacts/new?message=#{message}' title='report wrong analyze result'>Report</a></td>")
