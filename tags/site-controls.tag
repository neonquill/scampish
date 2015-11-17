var RiotControl = require('riotcontrol');

<site-controls>
  <div class="col-md-3">
    <div class="well">
      <h3>Controls</h3>
      <button class="btn btn-default btn-block" onclick="{ render_test }">
        Render test</button>
      <button class="btn btn-default btn-block" onclick="{ render_prod }">
        Render production</button>
    </div>
  </div>

  <script>
   this.render_test = function(e) {
     console.log("Render test!");
     RiotControl.trigger('render', opts.site, 'test');
   };

   this.render_prod = function(e) {
     console.log("Render prod!");
     RiotControl.trigger('render', opts.site, 'prod');
   };
  </script>
</site-controls>

