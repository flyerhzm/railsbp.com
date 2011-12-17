# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  categories = $("#buildsChart").data("categories")
  data = $("#buildsChart").data("data")
  chart = new Highcharts.Chart(
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

    serials:
      data: data
  )
