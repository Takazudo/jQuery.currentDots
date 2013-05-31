/*! jQuery.currentDots (https://github.com/Takazudo/jQuery.currentDots)
 * lastupdate: 2013-05-31
 * version: 0.1.0
 * author: 'Takazudo' Takeshi Takatsudo <takazudo@gmail.com>
 * License: MIT */
(function() {
  var __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  (function($, window, document) {
    var ns;
    ns = {};
    ns.Event = (function() {

      function Event() {}

      Event.prototype.on = function(ev, callback) {
        var evs, name, _base, _i, _len;
        if (this._callbacks == null) {
          this._callbacks = {};
        }
        evs = ev.split(' ');
        for (_i = 0, _len = evs.length; _i < _len; _i++) {
          name = evs[_i];
          (_base = this._callbacks)[name] || (_base[name] = []);
          this._callbacks[name].push(callback);
        }
        return this;
      };

      Event.prototype.once = function(ev, callback) {
        this.on(ev, function() {
          this.off(ev, arguments.callee);
          return callback.apply(this, arguments);
        });
        return this;
      };

      Event.prototype.trigger = function() {
        var args, callback, ev, list, _i, _len, _ref;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        ev = args.shift();
        list = (_ref = this._callbacks) != null ? _ref[ev] : void 0;
        if (!list) {
          return;
        }
        for (_i = 0, _len = list.length; _i < _len; _i++) {
          callback = list[_i];
          if (callback.apply(this, args) === false) {
            break;
          }
        }
        return this;
      };

      Event.prototype.off = function(ev, callback) {
        var cb, i, list, _i, _len, _ref;
        if (!ev) {
          this._callbacks = {};
          return this;
        }
        list = (_ref = this._callbacks) != null ? _ref[ev] : void 0;
        if (!list) {
          return this;
        }
        if (!callback) {
          delete this._callbacks[ev];
          return this;
        }
        for (i = _i = 0, _len = list.length; _i < _len; i = ++_i) {
          cb = list[i];
          if (!(cb === callback)) {
            continue;
          }
          list = list.slice();
          list.splice(i, 1);
          this._callbacks[ev] = list;
          break;
        }
        return this;
      };

      return Event;

    })();
    ns.DotItem = (function(_super) {

      __extends(DotItem, _super);

      DotItem.defaults = {
        index: null,
        class_activeItem: null,
        class_inactiveItem: null
      };

      function DotItem($el, options) {
        this.$el = $el;
        this.active = null;
        this.options = $.extend({}, ns.DotItem.defaults, options);
        this._eventify();
        this.deactivate();
      }

      DotItem.prototype._eventify = function() {
        var _this = this;
        this.$el.bind('click', function(e) {
          var data;
          e.preventDefault();
          data = {
            index: _this.options.index
          };
          return _this.trigger('click', data);
        });
        return this;
      };

      DotItem.prototype.deactivate = function() {
        if (this.active === false) {
          return this;
        }
        this.active = false;
        this.$el.removeClass(this.options.class_activeItem);
        if (this.options.class_inactiveItem) {
          this.$el.addClass(this.options.class_inactiveItem);
        }
        return this;
      };

      DotItem.prototype.activate = function() {
        if (this.active === true) {
          return this;
        }
        this.active = true;
        this.$el.addClass(this.options.class_activeItem);
        if (this.options.class_inactiveItem) {
          this.$el.removeClass(this.options.class_inactiveItem);
        }
        return this;
      };

      return DotItem;

    })(ns.Event);
    ns.DotCollection = (function(_super) {

      __extends(DotCollection, _super);

      DotCollection.defaults = {
        selector_item: null,
        class_activeItem: null,
        initialActiveIndex: 0
      };

      function DotCollection($el, options) {
        this.$el = $el;
        this.options = $.extend({}, ns.DotCollection.defaults, options);
        this._createItems();
        if (($.type(this.options.initialActiveIndex)) === 'number') {
          this.to(this.options.initialActiveIndex);
        }
      }

      DotCollection.prototype._createItems = function() {
        var _this = this;
        this._items = [];
        (this.$el.find(this.options.selector_item)).each(function(i, el) {
          var item, itemOptions;
          itemOptions = {
            class_activeItem: _this.options.class_activeItem,
            index: i
          };
          if (_this.options.class_inactiveItem) {
            itemOptions.class_inactiveItem = _this.options.class_inactiveItem;
          }
          item = new ns.DotItem($(el), itemOptions);
          item.on('click', function(data) {
            _this.to(data.index);
            return _this.trigger('itemclick', data);
          });
          _this._items.push(item);
        });
        return this;
      };

      DotCollection.prototype.deactivateWithout = function(itemToIgnore) {
        var item, _i, _len, _ref;
        _ref = this._items;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          if (item !== itemToIgnore) {
            item.deactivate();
          }
        }
        return this;
      };

      DotCollection.prototype.activate = function(itemToActivate) {
        var item, _i, _len, _ref;
        _ref = this._items;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          if (item === itemToActivate) {
            item.activate();
            break;
          }
        }
        return this;
      };

      DotCollection.prototype.to = function(index) {
        var item;
        item = this._items[index];
        this.deactivateWithout(item);
        this.activate(item);
        return this;
      };

      return DotCollection;

    })(ns.Event);
    $.fn.currentDots = function(options) {
      return this.each(function(i, el) {
        var $el, instance;
        $el = $(el);
        instance = new ns.DotCollection($el, options);
        $el.data('currentDots', instance);
      });
    };
    $.CurrentDotsNs = ns;
    return $.CurrentDots = ns.DotCollection;
  })(jQuery, window, document);

}).call(this);
