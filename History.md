## v1.0.4, 2015-Oct-30

 * Ensure `this.ready()` is called from publication. (Thanks @mquandalle)

## v1.0.3, 2015-Feb-19

 * Added `clientAddress` and `loginToken` to presences.
 * Added `hash` and `salt` options to `Presence.configure` on the server - the hash fn will be used to
   encode the `loginToken` which is useful if you'd like to publish to the client.

   ```js
   if (Meteor.isServer){
     var CRC32 = Npm.require('crc-32');
     Presence.configure({
       hash: function(salt, value){
         return CRC32.str(salt + value);
       }
     });
   }
   ```

## v1.0.0 - v1.0.2

Initial versions & fixes.
