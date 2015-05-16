{CompositeDisposable} = require 'atom'
{SelectListView} = require 'atom-space-pen-views'


class Finder extends SelectListView
  initialize: (items, key) ->
    super
    @addClass('overlay from-top')
    i = for item in items
      item[key]
    @setItems(i)

    atom.workspaceView.append(this)
    @focusFilterEditor()

  viewForItem: (item) ->
    "<li>#{item}</li>"

  confirmed: (item) ->
    console.log("#{item} was selected")
    @hide()

module.exports = RailsI18n =
  activate: (state) ->
    atom.commands.add 'atom-workspace', 'rails-i18n:search-key', ->
      new Finder([["a"],["b"],["c"]], 0)
