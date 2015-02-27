window.alpha = {}

# @type {Window}
alpha.GLOBAL = window

# Export namespace like ES6 modules.
#
# @param {string} namespace .
# @param {Function=} opt_fn .
alpha.export = (namespace, opt_fn) ->
  context = alpha.GLOBAL

  for name in namespace.split('.')
    unless context[name]?
      context[name] = {}
    context = context[name]

  if opt_fn
    fn.call context

# @param {*} obj .
# @return {string} .
alpha.getUid = (obj) ->
  # jQuery object
  if obj.selector
    obj = obj.get(0)

  return obj[alpha._UID_PROPERTY] or
         (obj[alpha._UID_PROPERTY] = ++alpha._uidCounter + '')


# Name for unique ID property.
#
# @type {string}
# @private
alpha._UID_PROPERTY = 'alpha_uid_' + ((Math.random() * 1e9) >>> 0)


# Counter for UID.
#
# @type {number}
# @private
alpha._uidCounter = 0
