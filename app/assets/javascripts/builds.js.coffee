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
      if $(this).attr("checked")
        $("."+$(this).val()).show()
      else
        $("."+$(this).val()).hide()

$ ->
  $("#history table tr").click ->
    url = $(this).data("url")
    window.location.href = url
    return false

$ ->
  if $("#buildsChart").length > 0
    categories = $("#buildsChart").data("categories").reverse()
    data = $("#buildsChart").data("data").reverse()
    repository = $("#buildsChart").data("repository")
    buildsChart = new Highcharts.Chart(
      chart:
        renderTo: "buildsChart"
        defaultSeriesType: "line"

      title:
        text: "Builds History"

      xAxis:
        categories: categories

      yAxis:
        title:
          text: "Warning count"
        plotLines: [
          value: 0
          width: 1
          color: "#808080"
        ]

      tooltip:
        formatter: ->
          @x

      series: [
        name: repository
        data: data
        point:
          events:
            click: ->
              window.location.href = window.location.href + "?position=" + @category
              return false
      ]
    )

$ ->
  if $("#build").length > 0
    $("#build table thead tr").append("<th class='report'></th>")
    $("#build table tbody tr").append("<td class='report'><a class='btn' title='report wrong analyze result'>Report</a></td>")
