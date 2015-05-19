{CompositeDisposable} = require 'atom'
{SelectListView} = require 'atom-space-pen-views'
YamlKeyReader = require './yaml-key-reader'
child = require 'child_process'
fs = require 'fs'

class Finder extends SelectListView
  initialize: (items, key) ->
    super
    @filterKey = key
    @addClass('overlay from-top')
    i = for k, item of items
      item
    # console.log(i)
    @setItems(i)

    atom.workspaceView.append(this)
    @focusFilterEditor()

  viewForItem: (item) ->
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
      new Finder(@findLocales(), 'value')

  findLocales: ->
    projectPath = atom.project.getPath()
    ymls = child.spawnSync('find', [projectPath, '-name', '*.yml']).stdout.toString().trim()

    keys = {}
    for yml in ymls.split("\n")
      contents = fs.readFileSync(yml).toString()
      reader = new YamlKeyReader(contents)
      for [key, value, line] in reader.keysWithRow()
        keys[key] = {key: key, value: value, file: yml, line: line}
    keys
