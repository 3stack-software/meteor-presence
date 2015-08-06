# Presence

A very simple presence package, to track who's online, etc.

## Installation

`meteor add 3stack:presence`

## Related

`3stack:presence-colours` - Assigns a colour to each distinct user in the `presences` collection

`3stack:presence-single-session` - Detects concurrent usage of a user with different login tokens;

## Usage

By default, the package will track users connected to the Meteor server.

The user's online state can be tracked via the `presences` collection, referenced by `userId`

NOTE: The package doesn't publish the presences by default, you'll need to do something like:
```js
Meteor.publish('userPresence', function() {
  // Setup some filter to find the users your logged in user
  // cares about. It's unlikely that you want to publish the
  // presences of _all_ the users in the system.
  var filter = {
    _id: {
      $ne: this.connection.sessionKey // don't publish the current user
    },
    status: 'online' // publish only clients that called 'setPresence'
  };
  // ProTip: unless you need it, don't send lastSeen down as it'll make your
  // templates constantly re-render (and use bandwidth)
  return presences.find(filter, {fields: {state: true, userId: true}});
});
```

To use that presence, you can inspect the `presences` collection in the client.

## Advanced Usage

### Custom State
If you want to track more than just what a user is doing (but instead what they are up to), you can set a custom state function. (The default state function return just `'online'`):

```js
Presence.configure({
  state: function() {
    return {
      online: true,
      currentRoomId: Session.get('currentRoomId');
    }
  }
});
```

Of course presence will call your function reactively, so everyone will know as soon as things change.

### Client Heartbeat

If you want the 'lastSeen' to update at a fixed interval, pass a heartbeat value

```js
Presence.configure({
  heartbeat: 60000 // 60s
});
```

### Non-Reactive State

You can disable reactivity on the state function, useful when using a heartbeat only.

```js
Presence.configure({
  reactive: false,
  state: myExtremelyVolatileFunction
});
```

### Emboxed state

You can ensure that the reactive state function is only called when it's output is changed by wrapping it in an embox.

include the `3stack:embox-value` package and wrap your state function:

```js
Presence.configure({
  state: emboxValue(function(){
    if (Session.get('myValue') > 10){
      return 'good';
    } else {
      return 'bad'
    }
  })
});
```

### Clustering / Server Heartbeat

If you have multiple servers - you will notice that starting a new server will clear all presences.

You'll need to enable a server-heartbeat to clear presences from servers that don't respond within a heartbeat / timeout period.

```js
if (Meteor.isServer){
  Presence.configure({
    heartbeat: 600000, // 10 minutes
    timeout: 1800000 // 30 minutes
  });
}
```

Note: There's currently no recovery for presence in case of a timeout.


