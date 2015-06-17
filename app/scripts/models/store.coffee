Constants = require '../constants'
Functions = require '../functions'
MemoryStorage = require('../memory_storage')
AppDispatcher = require '../dispatcher/app_dispatcher'
{EventEmitter} = require 'events'
ActionTypes = Constants.ActionTypes
CHANGE_EVENT = 'STORE_CHANGE'
class Store
  @store: new MemoryStorage()
  @emitter: new EventEmitter()
  @_storeId: (id) ->
    "#{@name}-#{id}"
  @find: (id) ->
    return null if not id?
    json = @store.getItem(@_storeId(id))
    return null if not json?
    obj = JSON.parse(json)
    if obj then new this(obj) else null
  @findBy: (opts={}) ->
    predicate = (obj) =>
      match = (obj.type is @name)
      match &= not obj._destroy
      for key, val of opts
        match &= (obj[key] is val)
      match
    matches = []
    for id, json of @store
      if typeof json is 'string' and json isnt 'undefined'
        obj = JSON.parse(json)
        matches.push(new this(obj)) if predicate(obj)
    matches
  @all: () ->
    @findBy()
  @emitChange: () ->
    @emitter.emit(CHANGE_EVENT)
  @addChangeListener: (callback) ->
    @emitter.on(CHANGE_EVENT, callback)
  @removeChangeListener: (callback) ->
    @emitter.removeListener(CHANGE_EVENT, callback)
  constructor: (options={}) ->
    @id = options.id ? Functions.uniqueId()
    @type = @constructor.name
    @_destroy = false
  save: (options={}) ->
    if not @_destroy
      @constructor.store.setItem(@_storeId(), JSON.stringify(this))
    else
      @constructor.store.removeItem(@_storeId())
  destroy: () ->
    @_destroy = true
  _storeId: () ->
    @constructor._storeId(@id)
module.exports = Store
