# Description
#   Say the current shipping forecast
#
#   http://en.wikipedia.org/wiki/Shipping_Forecast
#
#   Set HUBOT_SHIPPING_FORECAST_SHIP_IT to also respond to "ship it"
#
# Dependencies:
#   "xml2js": "0.4.4"
#
# Configuration:
#   HUBOT_SHIPPING_FORECAST_SHIP_IT
#
# Commands:
#   hubot shipping forecast
#
# Author:
#   bfirsh

xml2js = require 'xml2js'
util = require 'util'
parser = new xml2js.Parser()

shippingForecast = (msg) ->
  msg
    .http('http://www.metoffice.gov.uk/public/data/CoreProductCache/ShippingForecast/Latest')
    .get() (err, res, body) ->
      return msg.send err.message if err
      resp = ''
      parser.parseString body, (err, result) ->
        return msg.send err.message if err
        forecasts = result?['report']?['area-forecasts']?[0]
        return if not forecasts
        areas = []
        for forecast in forecasts['area-forecast']
          areas.push forecast['area']...
        return if areas.length == 0
        area = msg.random areas
        msg.send "#{area.main[0]}. #{area.wind[0]} #{area.seastate[0]} #{area.weather[0]} #{area.visibility[0]}"

module.exports = (robot) ->
  robot.respond /shipping forecast/i, shippingForecast

  if process.env.HUBOT_SHIPPING_FORECAST_SHIP_IT
    robot.hear /ship it/i, shippingForecast
