{CompositeDisposable} = require 'atom'
{SelectListView} = require 'atom-space-pen-views'

YamlKeyReader = require './yaml-key-reader'
child = require 'child_process'
fs = require 'fs'

class Finder extends SelectListView
  initialize: (items, key, addInfo) ->
    super
    @filterKey = key
    @addInfo = addInfo
    @addClass('overlay from-top')
    i = for k, item of items
      item
    @setItems(i)

    atom.workspace.addModalPanel(item: this, visible: false)
    @focusFilterEditor()
    @on 'keypress', (evt) =>
      if evt.ctrlKey
        atom.clipboard.write @getSelectedItem().key


  viewForItem: (item) ->
    if @addInfo
      "<li>#{item[@filterKey]} <div class='pull-right key-binding'>" +
        item[@addInfo] + "</div></li>"
    else
      "<li>#{item[@filterKey]}</li>"

  getFilterKey: -> @filterKey

  cancel: -> @hide()

  confirmed: (item) ->
    atom.workspace.open(item.file, initialLine: item.line)
    @hide()

module.exports = RailsI18n =
  activate: (state) ->
    atom.commands.add 'atom-workspace', 'rails-i18n:search-key', =>
      new Finder(@findLocales(), 'key')

    atom.commands.add 'atom-workspace', 'rails-i18n:search-translation', =>
      finder = new Finder(@findLocalesSync(), 'value', 'key')
      # finder.viewForItem = (item) ->
      #   "<li>#{item.value} <div class='pull-right key-binding'>#{item.key}</div></li>"

  findLocalesSync: ->
    projectPath = atom.project.getPath()
    ymls = child.spawnSync('find', ['-L', projectPath, '-name', '*.yml']).stdout.toString().trim()
    return Promisse.resolve([]) if ymls == ''

    keys = []
    for yml in ymls.split("\n")
      contents = fs.readFileSync(yml).toString()
      reader = new YamlKeyReader(contents)
      for [key, value, line] in reader.keysWithRow()
        keys.push(key: key, value: value, file: yml, line: line)
    keys

  findLocales: ->
    projectPath = atom.project.getPaths()[0]
    ymls = child.spawnSync('find', ['-L', projectPath, '-name', '*.yml']).stdout.toString().trim()
    ymls = ymls.split("\n").filter (e) -> e.match(/\/\w{2}(-\w{2})?\./)

    keys = []
    ymls.forEach (yml) ->
      keys.push new Promise (resolve) ->
        fs.readFile yml, (_, contents) ->
          reader = new YamlKeyReader(contents.toString())
          result = reader.keysWithRow().map ([key, value, line]) ->
            {key: key, value: value, file: yml, line: line}
          resolve(result)
    Promise.all(keys)

  provide: ->
    loaded = false
    items = []

    loadAndResolve = (resolve) =>
      @findLocales().then (values) ->
        values.forEach (value) -> value.forEach (item) ->
          fn = ->
            console.log("Bar")
            console.log(item)
            items = []
            loaded = false
            atom.workspace.open(item.file, initialLine: item.line)

          items.push(
            displayName: item.value
            queryString: "#{item.key} #{item.value}"
            function: fn
            additionalInfo: item.key
            commands: {
              "Open File": fn
              "Copy Key to Clipboard": => atom.clipboard.write(item.key)
            }
          )
        loaded = true
        resolve(items)

    {
      name: 'rails-i18n',

      function: (query) -> new Promise (resolve) ->
        if loaded
          resolve(items)
        else
          loadAndResolve(resolve)

      shouldRun: (query) -> query.length > 5
    }

window.F = Finder
