# Looks for code in the module/client directory and requires each top level file in
# the 'client.js' bundle

directoryUtils = require '../utils/directoryUtils'
path = require 'path'
fs = require 'fs'

# Configure browserify
coffeeify = require 'coffeeify'
browserify = require 'browserify-middleware'
browserify.settings({
  transform: [coffeeify]
})

module.exports = class BrowserifyCode
  constructor: ->
    @bundledFiles = []

  # called before any modules are initialized
  prepareInitialization: (@expressApp, @log, @environment) =>
    return

  # called on each module
  initializeModule: (parentDir, moduleFolder, module) =>
    codeDir = path.join parentDir, moduleFolder, 'client'

    p = directoryUtils.listFiles codeDir, '.coffee'
    p = p.then (codeFiles) =>
      for file in codeFiles
        @bundledFiles.push path.join codeDir, file
    p = p.catch (error) =>
      # Ignore it if the client subfolder does not exist
      if error.code == 'ENOENT'
        return

      @log.warn "Unable to create client code bundle for module '#{module}':"
      @log.warn error

  # called after all modules are initialized
  # Actually set up browserify bundle with all collected files
  finishInitialization: =>
    # General browserify settings
    browserify.settings.production 'cache', '1 hour'
    if @environment.developmentMode
      browserify.settings.mode = 'development'
    else
      browserify.settings.mode = 'production'

    # Shared modules that are used by others
    shared = [
      'angular'
      'angular-resource'
      'angular-ui-bootstrap'
    ]

    @expressApp.get '/shared.js', browserify(shared, {
      cache: true
      precompile: true
      noParse: shared
    })

    # Build up file that requires everything
    tempSourceFile = ''
    for sourceFile in @bundledFiles
      tempSourceFile += "require './#{sourceFile}'\n"
    # Escape backslash for windows paths
    tempSourceFile = tempSourceFile.replace(/\\/g, '\\\\')

    fileName = path.join process.cwd(), 'browserifyClientBundle.coffee'
    fs.writeFileSync fileName, tempSourceFile

    # Define it as bundle
    @expressApp.get '/client.js', browserify(fileName, {
      extensions: ['.coffee']
      external: shared
    })
