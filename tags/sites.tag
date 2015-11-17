var RiotControl = require('riotcontrol');

<sites>
  <div class="row">
    <loading if="{ loading }" label="sites"></loading>
    <div if="{ !loading }">
      <h2>Sites:</h2>
      <ul>
        <li each="{ sites }">
          <a href="#/{ slug }">{ name }</a>
        </li>
      </ul>
    </div>
  </div>

  <script>
   var self = this;

   self.loading = true;

   this.on('mount', function() {
     console.log("sites mounted!");
     RiotControl.trigger('sites_load');
   });

   this.on('unmount', function() {
     RiotControl.off('sites_changed', this.on_sites_changed);
   });

   this.on_sites_changed = function(sites) {
     console.log("Sites", sites);
     self.sites = sites;
     self.loading = false;
     self.update();
   };

   RiotControl.on('sites_changed', this.on_sites_changed);

  </script>
</sites>
