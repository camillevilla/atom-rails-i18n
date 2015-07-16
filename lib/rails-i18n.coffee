{CompositeDisposable} = require 'atom'
{SelectListView} = require 'atom-space-pen-views'

YamlKeyReader = require './yaml-key-reader'
child = require 'child_process'
fs = require 'fs'
findLocales = require './find-locales'

class Finder extends SelectListView
  initialize: (items, key, addInfo) ->
    super
    @filterKey = key
    @addInfo = addInfo
    @addClass('overlay from-top')
    i = for k, item of items
      item
    @setItems(i)

    atom.workspaceView.append(this)
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
      new Finder(@findLocalesSync(), 'key')

    atom.commands.add 'atom-workspace', 'rails-i18n:search-translation', =>
      finder = new Finder(@findLocalesSync(), 'value', 'key')

  findLocalesSync: ->
    projectPath = atom.project.getPaths()[0]
    ymls = child.spawnSync('find', ['-L', projectPath, '-name', '*.yml']).stdout.toString().trim()
    return Promisse.resolve([]) if ymls == ''

    keys = []
    for yml in ymls.split("\n")
      contents = fs.readFileSync(yml).toString()
      reader = new YamlKeyReader(contents)
      for [key, value, line] in reader.keysWithRow()
        keys.push(key: key, value: value, file: yml, line: line)
    keys

  provide: ->
    items = []
    promise = null
    fuzzaldrin = null

    name: 'rails-i18n',
    function: (query) -> Promise.all([promise]).then ([elements]) ->
      if fuzzaldrin?
        elements.map (e) ->
          element = Object.create(e)
          element.score = fuzzaldrin.score(element.queryString, query) / 5
          element

      else
        elements

    shouldRun: (query) -> query.length > 3

    onStart: (evry) ->
      fuzzaldrin = evry.fuzzaldrin
      promise = new Promise (resolve) ->
        findLocales().then (values) ->
          items = values.map (item) ->
            fn = ->
              items = []
              loaded = false
              atom.workspace.open(item.file, initialLine: item.line)

            displayName: item.value
            queryString: "#{item.key} #{item.value}"
            function: fn
            additionalInfo: item.key
            commands: {
              "Open File": fn
              "Copy Key to Clipboard": =>
                atom.clipboard.write(item.key.replace(/.*?\./, ''))
            }
          resolve(items)
