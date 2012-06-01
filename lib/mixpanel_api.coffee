http = require 'http'
querystring = require 'querystring'
crypto = require 'crypto'
util = require 'util'

class MixpanelAPI
  constructor: (options) ->
    @options =
      api_key: null
      api_secret: null
      default_valid_for: 60 # seconds
      log_fn: @log
    @options[key] = val for key, val of options
    if not @options.api_key and @options.api_secret
      throw new Error 'MixpanelAPI needs token and secret parameters'

  # duration is optional
  signedUrl: (endpoint, params, valid_for, cb) ->
    cb or= @options.log_fn
    try
      if typeof params isnt 'object' or typeof endpoint isnt 'string'
        throw new Error 'request(endpoint, params, [valid_for], [cb]) expects an object params'

      if arguments.length is 3 and typeof arguments[2] is 'function'
        cb = valid_for
        valid_for = null

      valid_for or= @options.default_valid_for
      cb or= @options.log_fn

      params.api_key = @options.api_key
      params.expire = Math.floor(Date.now()/1000) + valid_for

      params_qs = querystring.stringify @_sign_params params
      cb 'http://mixpanel.com/api/2.0/' + endpoint + '?' + params_qs

    catch e then cb e
    
  # duration is optional
  request: (endpoint, params, valid_for, cb) ->
    cb or= @options.log_fn
    try
      if typeof params isnt 'object' or typeof endpoint isnt 'string'
        throw new Error 'request(endpoint, params, [valid_for], [cb]) expects an object params'

      if arguments.length is 3 and typeof arguments[2] is 'function'
        cb = valid_for
        valid_for = null
        
      valid_for or= @options.default_valid_for
      cb or= @options.log_fn

      params.api_key = @options.api_key
      params.expire = Math.floor(Date.now()/1000) + valid_for

      params_qs = querystring.stringify @_sign_params params
      req_opts =
        host: 'mixpanel.com'
        port: 80
        path: '/api/2.0/'+ endpoint + '?' + params_qs

      req = http.get req_opts, (res) =>
        res.setEncoding 'utf8'
        body = []
        res.on 'data', (chunk) -> body.push chunk
        res.addListener 'end', ->
          try
            result = JSON.parse body.join('')
            error = null
            if result.error
              error = new Error result.error
            else if res.statusCode isnt 200
              error = new Error "Bad res code #{res.statusCode} but no error"
            cb error, result
          catch e then cb e

      req.on 'error', cb

    catch e then cb e

  # takes parameters and returns parameters with added sig property
  _sign_params: (params) ->
    if not params?.api_key or not params?.expire
      throw new Error 'all requests must have api_key and expire'
    keys = Object.keys(params).sort()
    to_be_hashed = ''
    for key in keys
      continue if key is 'callback' or key is 'sig'
      param = {}
      param[key] = params[key]
      to_be_hashed += querystring.stringify param
    hash = crypto.createHash 'md5'
    hash.update to_be_hashed + @options.api_secret
    params.sig = hash.digest 'hex'
    return params
  
  
  log: (err, other_stuff...) ->
    if err instanceof Error
      console.error 'Error in MixpanelAPI: ' + err.message
      return console.error err 
    console.log arguments...
    
module.exports = MixpanelAPI
