
module.exports = class YamlKeyReader
  constructor: (@string) ->

  keys: ->
    indentationRules = [-1]
    keys = []
    console.log(@string.split("\n"))
    for row in @string.split("\n") when row.indexOf(':') > -1
      spaces = row.split(/[^\s]/)[0].length
      split = row.split(":")
      key = split.shift()
      values = split.join(":").trim()

      while(spaces <= indentationRules[0])
        indentationRules.shift()
        keys.pop()

      indentationRules.unshift(spaces)
      keys.push(key.trim())
      [keys.join("."), values]
