# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
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
    ]
  )
