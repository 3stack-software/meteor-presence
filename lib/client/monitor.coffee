
class ClientMonitor

  constructor: ->
    @started = false
    @computation = null
    @heartbeat = null
    @options =
      state: 'online'
      reactive: true
      heartbeat: null


  configure: (options)->
    wasStarted = @started
    if @started
      @stop()

    _.extend(@options, options)

    if @options.heartbeat?
      @heartbeat = new Heartbeat(@options.heartbeat)
    else
      @heartbeat = null

    if wasStarted
      @start()
    return

  start: ->
    if @started
      return
    @started = true
    @computation = Tracker.autorun(@setPresence)
    @heartbeat?.start(@pulse)
    return

  pulse: =>
    if @computation == null or @computation.invalidated
      return
    @computation.invalidate()
    return

  stop: ->
    @started = false
    @heartbeat?.stop()
    @computation?.stop()
    @computation = null
    return

  setPresence: =>
    if Meteor.status().connected
      state = @readState()
      Meteor.apply('setPresence', [state], {wait: false}, @setPresenceComplete)
    return

  readState: ->
    unless _.isFunction(@options.state)
      return @options.state

    unless @options.reactive
      return Tracker.nonreactive(@options.state)

    return @options.state()

  setPresenceComplete: (err)=>
    if err?
      console.error("Error from Presence_setPresence", err)
      return
    @heartbeat?.tock()
    return

@ClientMonitor = ClientMonitor
