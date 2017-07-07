DEFAULT_TTL = 5*60*1000
DEFAULT_HEARTBEAT = 60*1000

class ServerMonitor
  constructor: ->
    @serverId = Random.id()
    console.log("Presence started serverId=#{@serverId}")
    @options =
      ttl: null
      heartbeatInterval: null
      checksum: null
    @heartbeat = null
    @started = false
    Meteor.startup(@onStartup)

  configure: (options)->
    if @started
      throw new Error("Must configure Presence on the server before Meteor.startup()")
    _.extend(@options, options)

    @heartbeat = new Heartbeat(@options.heartbeatInterval ? DEFAULT_HEARTBEAT)
    return

  getTtl: -> new Date(+(new Date()) + (@options.ttl ? DEFAULT_TTL))

  onStartup: =>
    @started = true
    @heartbeat.start(@onBeat)
    return

  onBeat: =>
    presences.update({
      serverId: @serverId
    }, {
      $set: {
        ttl: @getTtl()
      }
    }, {
      multi: true
    })
    @heartbeat.tock()
    return

  checksum: (userId, value)->
    if @options.checksum?
      return @options.checksum(userId, value)
    else
      return value

@ServerMonitor = ServerMonitor
