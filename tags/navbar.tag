var RiotControl = require('riotcontrol');

<navbar>
  <nav class="navbar navbar-default">
    <div class="container-fluid">
      <div class="navbar-header">
        <a class="navbar-brand" href="#">Scampish</a>
      </div>

      <div class="navbar-collapse">
        <p class="navbar-text navbar-right">
          <a href="#" onclick="{ sign_in_out }">{ sign_text }</a>
        </p>
      </div>
    </div>
  </nav>

  <script>
   this.sign_text = "Sign in"
   this.signed_in = false;

   this.on('unmount', function() {
     RiotControl.off('google_signed_in', this.on_google_signed_in);
     RiotControl.off('google_signed_out', this.on_google_signed_out);
   });

   this.sign_in_out = function() {
     if (this.signed_in) {
       RiotControl.trigger('google_signout');
     }
   }

   this.on_google_signed_in = function(user) {
     this.signed_in = true;
     this.sign_text = "Sign out " + user.displayName;
     this.update();
   }.bind(this);

   RiotControl.on('google_signed_in', this.on_google_signed_in);

   this.on_google_signed_out = function() {
     this.signed_in = false;
     this.sign_text = "Sign in";
     this.update();
   }.bind(this);

   RiotControl.on('google_signed_out', this.on_google_signed_out);
  </script>
</navbar>
