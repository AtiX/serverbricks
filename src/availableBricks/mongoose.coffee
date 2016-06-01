directoryUtils = require '../utils/directoryUtils'
path = require 'path'
mongoose = require 'mongoose'

Brick = require '../Brick'

# Initializes a connection to mongodb
# Then initializes (requires) all mongoose models found in the modules
module.exports = class Mongoose extends Brick
  constructor: (config = {}) ->
    @mongoConnectionInfo = {
      host: config.host || 'localhost'
      port: config.port || 27017
      db: config.db || 'default-db'
    }
    @modelSubpath = config.modelSubpath || 'db/models'

  prepareInitialization: (@expressApp, @log) =>
    @log.debug '[ServerBricks] initializes mongoose brick'
    @log.debug "[ServerBricks] (host: #{@mongoConnectionInfo}, models: #{@modelSubpath})"

    return new Promise (resolve, reject) =>
      connectionString = "mongodb://\
        #{@mongoConnectionInfo.host}:#{@mongoConnectionInfo.port}/\
        #{@mongoConnectionInfo.db}"

      @log.info "[MongoDB] Connecting to mongodb (#{connectionString})"
      mongoose.connect(connectionString)

      db = mongoose.connection
      db.on 'error', (error) =>
        @log.error "[MongoDB] #{error}"
        reject error
      db.once 'open', =>
        @log.info '[MongoDB] Connection established'
        resolve()

  initializeModule: (moduleFolder) =>
    modelsPath = path.join moduleFolder, @modelSubpath

    return directoryUtils.listFiles modelsPath
    .then (files) =>
      # Load all models by requiring them
      for modelDefinition in files
        model = require path.join modelsPath, modelDefinition
        @log.debug "[MongoDB] Loaded model '#{model.modelName}'"
    .catch (error) ->
      # Ignore it if the db/models subfolder does not exist
      if error.code == 'ENOENT'
        return
      throw error
