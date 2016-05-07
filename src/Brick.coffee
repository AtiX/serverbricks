Promise = require 'bluebird'

module.exports = class Brick

  # @param [Object] config configuration object that holds user defined configuration
  constructor: (config = {}) -> @

  # Called before any modules are initialized. Perform all work that is necessary
  # to set this brick up here.
  # @param [express] @expressApp a reference to the express webapp
  # @param @log a logger. Functionality depends on the logger specified by the user
  prepareInitialization: (@expressApp, @log) => return Promise.resolve()
  
  # Called on each module folder. Perform all per-module logic/initialization here
  # @param [String] moduleFolder Absolute path of the module
  initializeModule: (moduleFolder) -> return Promise.resolve()

  # Called after all modules are initialized. Perform post-init logic here.
  finishInitialization: () -> return Promise.resolve()

