directoryUtils = require '../utils/directoryUtils'
path = require 'path'
fs = require 'fs'

Brick = require '../Brick'

# Configure browserify to work with coffeescript
coffeeify = require 'coffeeify'
browserify = require 'browserify-middleware'
browserify.settings({
  transform: [coffeeify]
})

# Looks for code in the module/client directory and requires each top level file.
# Served as 'client.js' bundle
module.exports = class BrowserifyCode extends Brick
  constructor: (config = {}) ->
    @bundledFiles = []
    @externalModules = config.externalModules || []
    @externalBundleName = config.externalBundleName || '/shared.js'
    @bundleName = config.bundleName || '/client.js'
    @developmentMode = config.developmentMode || true

  # called before any modules are initialized
  prepareInitialization: (@expressApp, @log) =>
    @log.debug '[ServerBricks] initializes browserifyCode brick'
    @log.debug "[ServerBricks] (bundleName: #{@bundleName})"

    return

  # called on each module
  initializeModule: (moduleFolder) =>
    codeDir = path.join moduleFolder, 'client'

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
    if @developmentMode
      browserify.settings.mode = 'development'
    else
      browserify.settings.mode = 'production'

    @expressApp.get @externalBundleName, browserify(@externalModules, {
      cache: true
      precompile: true
      noParse: @externalModules
    })

    # Build up file that requires everything
    tempSourceFile = ''
    for sourceFile in @bundledFiles
      tempSourceFile += "require '#{path.resolve sourceFile}'\n"
    # Escape backslash for windows paths
    tempSourceFile = tempSourceFile.replace(/\\/g, '\\\\')

    fileName = path.join process.cwd(), 'browserifyClientBundle.coffee'
    fs.writeFileSync fileName, tempSourceFile

    # Define it as bundle
    @expressApp.get @bundleName, browserify(fileName, {
      extensions: ['.coffee', '.js']
      external: @externalModules
    })
