$ ->
  window.I18n = I18n = require 'i18n-js'
  require("./utils/course.coffee")
  require("./utils/router.cjsx")
  require("events").EventEmitter.defaultMaxListeners = 30

  $(".language-selector").uls

require './main-utils.coffee'
