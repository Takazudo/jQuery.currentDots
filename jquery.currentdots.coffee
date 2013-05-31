# encapsulate plugin
do ($=jQuery, window=window, document=document) ->

  ns = {}

  # ============================================================
  # event module

  class ns.Event

    on: (ev, callback) ->
      @_callbacks = {} unless @_callbacks?
      evs = ev.split(' ')
      for name in evs
        @_callbacks[name] or= []
        @_callbacks[name].push(callback)
      return this

    once: (ev, callback) ->
      @on ev, ->
        @off(ev, arguments.callee)
        callback.apply(@, arguments)
      return this

    trigger: (args...) ->
      ev = args.shift()
      list = @_callbacks?[ev]
      return unless list
      for callback in list
        if callback.apply(@, args) is false
          break
      return this

    off: (ev, callback) ->
      unless ev
        @_callbacks = {}
        return this

      list = @_callbacks?[ev]
      return this unless list

      unless callback
        delete @_callbacks[ev]
        return this

      for cb, i in list when cb is callback
        list = list.slice()
        list.splice(i, 1)
        @_callbacks[ev] = list
        break

      return this

  # ============================================================
  # DotItem

  class ns.DotItem extends ns.Event

    @defaults =
      index: null
      class_activeItem: null

    constructor: (@$el, options) ->

      @active = false
      @options = $.extend {}, ns.DotItem.defaults, options
      @_eventify()

    _eventify: ->

      @$el.bind 'click', (e) =>
        e.preventDefault()
        data =
          index: @options.index
        @trigger 'click', data

      return this

    deactivate: ->

      return this if @active is false
      @active = false
      @$el.removeClass @options.class_activeItem
      return this

    activate: ->

      return this if @active is true
      @active = true
      @$el.addClass @options.class_activeItem
      return this


  # ============================================================
  # DotCollection

  class ns.DotCollection extends ns.Event

    @defaults =
      selector_item: null
      class_activeItem: null
      initialActiveIndex: 0

    constructor: (@$el, options) ->

      @options = $.extend {}, ns.DotCollection.defaults, options
      @_createItems()
      if ($.type @options.initialActiveIndex) is 'number'
        @to @options.initialActiveIndex

    _createItems: ->

      @_items = []

      (@$el.find @options.selector_item).each (i, el) =>
        itemOptions =
          class_activeItem: @options.class_activeItem
          index: i
        item = new ns.DotItem $(el), itemOptions
        item.on 'click', (data) =>
          @to data.index
          @trigger 'itemclick', data
        @_items.push item
        return

      return this

    deactivateWithout: (itemToIgnore) ->

      for item in @_items
        if item isnt itemToIgnore
          item.deactivate()

      return this

    activate: (itemToActivate) ->
      
      for item in @_items
        if item is itemToActivate
          item.activate()
          break

      return this

    to: (index) ->

      item = @_items[index]
      @deactivateWithout item
      @activate item
      return this

  # ============================================================
  # bridge to plugin

  $.fn.currentDots = (options) ->
    return @each (i, el) ->
      $el = $(el)
      instance = new ns.DotCollection $el, options
      $el.data 'currentDots', instance
      return

  # ============================================================
  # globalify

  $.CurrentDotsNs = ns
  $.CurrentDots = ns.DotCollection

