Presence = new ClientMonitor()

Meteor.startup ->
  Presence.start()
  return
