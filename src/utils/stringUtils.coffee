# Add endsWith
if (typeof String.prototype.endsWith != 'function')
  String.prototype.endsWith = (suffix) ->
    return @indexOf(suffix, @length - suffix.length) != -1

# Adds random
if (typeof String.getRandomAlphanum != 'function')
  String.getRandomAlphanum = (length) ->
    result = ''
    validChars = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'

    for i in [0...length]
      index = Math.round(Math.random() * (validChars.length - 1))
      result += validChars[index]

    return result
