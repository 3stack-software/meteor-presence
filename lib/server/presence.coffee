Presence = new ServerMonitor()

# on any connection - log the client in presences, and set the onClose handler
Meteor.onConnection (connection)->
  connection.sessionKey = Random.id()
  now = new Date()
  presences.insert
    _id: connection.sessionKey
    serverId: Presence.serverId
    ttl: Presence.getTtl()
    clientAddress: connection.clientAddress
    status: 'connected'
    connectedAt: now
    lastSeen: now
    state: {}
    userId: null

  connection.onClose ->
    presences.remove(_id: connection.sessionKey)
    return
  return

# this autopublish will be called each time the user logs out / in
# it should also be the first call after the Meteor.onConnection call
Meteor.publish null, ->
  loginToken = null
  if @userId?
    # Use user-defined digest if option provided
    loginToken = Presence.checksum(@userId, Accounts._getLoginToken(@connection.id))

  presences.update
    _id: @connection.sessionKey
  ,
    $set:
      loginToken: loginToken
      userId: @userId
      lastSeen: new Date()
  @ready()
  return

# allow the client to provide stateful information about itself
Meteor.methods
  'setPresence': (state)->
    check(state, Match.Any)
    @unblock()

    presences.update
      _id: @connection.sessionKey
    ,
      $set:
        userId: @userId
        lastSeen: new Date()
        state: state
        status: 'online'

    return null
