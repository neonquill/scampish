var RiotControl = require('riotcontrol');

<login>
  <div if="{ show }">
    <div id="google-login"></div>
  </div>

  <script>
   this.show = true;

   this.onSignIn = function(googleUser) {
     RiotControl.trigger('google_signin', googleUser);
   }

   this.onFailure = function(error) {
     RiotControl.trigger('google_failure');
   }

   this.signOut = function() {
     RiotControl.trigger('google_signout');
   }

   this.on('mount', function() {
     gapi.signin2.render('google-login', {
       onsuccess: this.onSignIn,
       onfailure: this.onFailure,
       scope: "profile",
       width: 120,
       height: 36,
       theme: "dark"
     });
   });

   this.on('unmount', function() {
     RiotControl.off('google_signed_in', this.on_google_signed_in);
     RiotControl.off('google_signed_out', this.on_google_signed_out);
   });

   this.on_google_signed_in = function(user) {
     this.show = false;
     this.update();
   }.bind(this);

   RiotControl.on('google_signed_in', this.on_google_signed_in);

   this.on_google_signed_out = function() {
     this.show = true;
     this.update();
   }.bind(this);

   RiotControl.on('google_signed_out', this.on_google_signed_out);
  </script>
</login>
