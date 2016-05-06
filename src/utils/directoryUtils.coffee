fs = require 'fs'
require './stringUtils'

module.exports.listFiles = (path, fileExtension = '') ->
# add a . to file extension if it is specified
  if fileExtension.length > 0 and fileExtension.indexOf('.') != 0
    fileExtension = '.' + fileExtension

  return new Promise (resolve, reject) ->
    fs.readdir path, (error, files) ->
      if error?
        reject error
        return

      # resolve without filtering when no filter is specified
      if fileExtension.length == 0
        resolve(files)
        return

      filteredFiles = []

      for file in files
        if file.endsWith fileExtension
          filteredFiles.push file

      resolve(filteredFiles)

module.exports.readFile = (file) ->
  return new Promise (resolve, reject) ->
    fs.readFile file, 'utf8', (error, data) ->
      if error?
        reject(error)
        return

      resolve(data)

# Lists subfolders in a directory
module.exports.listDirectories = (rootDir) ->
  return new Promise (resolve, reject) ->
    fs.readdir rootDir, (err, files) ->
      if err?
        reject err
        return

      _checkDirectory = (filePath, file) ->
        return new Promise (resolve, reject) ->
          fs.stat filePath, (err, stat) ->
            if err?
              reject err
              return
            if stat.isDirectory()
              resolve(file)
            else
              resolve(null)

      promises = []
      for file, index in files
        if file[0] != '.'
          filePath = "#{rootDir}/#{file}"
          promises.push _checkDirectory(filePath, file)

      p = Promise.all(promises)
      p = p.then (folders) ->
        withoutNull = folders.filter (f) -> return f?
        return withoutNull
      p = p.then (folders) -> resolve folders
      p = p.catch (err) -> reject err

# Resolves with a true/false boolean stating if the given directory exists
module.exports.directoryExists = (directory) ->
  return new Promise (resolve, reject) ->
    fs.lstat directory, (error, stats) ->
      # Only reject if the error is other than "folder does not exist"
      if error?
        if error.code != 'ENOENT'
          return reject error
        return resolve(false)

      if stats.isDirectory()
        return resolve(true)
      else
        return resolve(false)
