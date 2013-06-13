# encapsulate plugin
do ($=jQuery, window=window, document=document) ->

  ns = {}

  # ============================================================
  # DotItem

  class ns.DotItem extends window.EveEve

    @defaults =
      index: null
      class_activeItem: null
      class_inactiveItem: null

    constructor: (@$el, options) ->

      @active = null
      @options = $.extend {}, ns.DotItem.defaults, options
      @_eventify()
      @deactivate()

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
      if @options.class_inactiveItem
        @$el.addClass @options.class_inactiveItem
      return this

    activate: ->

      return this if @active is true
      @active = true
      @$el.addClass @options.class_activeItem
      if @options.class_inactiveItem
        @$el.removeClass @options.class_inactiveItem
      return this


  # ============================================================
  # DotCollection

  class ns.DotCollection extends window.EveEve

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
        if @options.class_inactiveItem
          itemOptions.class_inactiveItem = @options.class_inactiveItem
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

