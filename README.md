MixpanelAPI
===========

Queries the [Mixpanel Data API](http://mixpanel.com/api/docs/guides/api/v2). Requires node 0.4.0 or higher.


Show me the code
================

Note: All examples and the implementation are in [coffee-script](http://jashkenas.github.com/coffee-script/). CoffeeScript is great and you should probably use it. If you don't want to use CoffeeScript, you can easily convert these examples using the 'Try CoffeeScript' button on the aforementioned website or using the `coffee` command-line utility.

    MixpanelAPI = require 'lib/mixpanel_api'

    mixpanel = new MixpanelAPI
      
      # required
      api_key: 'ABC'
      api_secret: 'XYZ'
      
      # optional
      default_valid_for: 60 # seconds a request signature is valid for
      
    req =
      event: 'my_button.click'
      name: 'color'
      type: 'general'
      unit: 'hour'
      interval: 100
      limit: 100
    
    # queries the events/properties endpoint
    mixpanel.request 'events/properties', req, (err, res) ->
      return console.error err if err
      
      # `res` is the JSON-parsed response from the server.
      # example:
      # {
      #   legend_size: 3
      #   data:
      #     series: [ '2011-02-10 14:00:00' ]
      #     values: {...}
      # }
      console.log res

