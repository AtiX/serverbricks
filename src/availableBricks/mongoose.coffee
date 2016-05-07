# Initializes a connection to mongodb
# Requires (and thus initializes) all models in module/db/models

directoryUtils = require '../utils/directoryUtils'
path = require 'path'
mongoose = require 'mongoose'

module.exports = class Mongoose
  prepareInitialization: (@expressApp, @log, @environment) =>
    return new Promise (resolve, reject) =>
      connectionString = "mongodb://\
        #{@environment.mongodb.host}:#{@environment.mongodb.port}/\
        #{@environment.mongodb.db}"

      @log.info "[MongoDB] Connecting to mongodb (#{connectionString})"
      mongoose.connect(connectionString)

      db = mongoose.connection
      db.on 'error', (error) =>
        @log.error "[MongoDB] #{error}"
        reject error
      db.once 'open', =>
        @log.info '[MongoDB] Connection established'
        resolve()

  initializeModule: (moduleFolder, module) =>
    modelsPath = path.join moduleFolder, 'db', 'models'

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

  finishInitialization: ->
    return
