path = require 'path'
express = require 'express'
sassMiddleware = require 'node-sass-middleware'
Promise = require 'bluebird'
directoryUtils = require '../utils/directoryUtils'

module.exports = class PublicAssets
  # called before any modules are initialized
  prepareInitialization: (@expressApp, @log, @environment) =>
    # static Fontawesome in node modules
    @expressApp.use express.static('node_modules/font-awesome/')

  # called on each module
  initializeModule: (parentDir, moduleFolder, module) =>
    p = Promise.resolve()
    p = p.then =>
      # If there is a public/styles folder, autogenerate css out of sass
      pubStylesFolder = path.join parentDir, moduleFolder, 'public', 'styles'
      return directoryUtils.directoryExists(pubStylesFolder)
      .then (doesExist) =>
        if doesExist
          @expressApp.use sassMiddleware({
            src: pubStylesFolder
            debug: false
            outputStyle: 'compressed'
            prefix: '/styles'
            indentedSyntax: true,
            sourceMap: true
          })
    p.finally =>
      # Check if public folder exists, serve it staticly
      pubFolder = path.join parentDir, moduleFolder, 'public'
      return directoryUtils.directoryExists(pubFolder)
      .then (doesExist) =>
        if doesExist
          @expressApp.use express.static(pubFolder)

    return p

  # called after all modules are initialized
  # Actually set up browserify bundle with all collected files
  finishInitialization: ->
    return
