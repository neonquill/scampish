var RiotControl = require('riotcontrol');

require('valid-input.tag');

<main-config>
  <form class="form-horizontal" onsubmit="{ save_config }">
    <fieldset>
      <valid-input name="author"
                   label="Author"
                   placeholder="Bob Smith"
                   value="{ config.author }">
      </valid-input>
      <valid-input name="description"
                   label="Description"
                   value="{ config.description }">
      </valid-input>
      <valid-input name="title"
                   label="Title"
                   value="{ config.title }">
      </valid-input>
      <valid-input name="s3_bucket_name"
                   label="Amazon S3 bucket"
                   placeholder="www-example-com"
                   value="{ config.s3_bucket_name }">
      </valid-input>
    </fieldset>
    <div class="form-group">
      <div class="col-sm-offset-2 col-sm-10">
        <!-- XXX Don't hard code this as valid. -->
        <save-button saving="{ saving }" valid="true">
          Save config
        </save-button>
      </div>
    </div>
  </form>

  <script>
   var self = this;

   this.saving = false;

   this.on('mount', function() {
     RiotControl.trigger('site_main_config_load', opts.site);
   });

   this.on('unmount', function() {
     RiotControl.off('site_main_config_changed', this.on_config_changed);
     RiotControl.off('site_main_config_saved', this.on_config_saved);
   });

   this.on_config_changed = function(c) {
     console.log('site_main_config_changed', c);
     self.config = c;
     self.update();
   };

   RiotControl.on('site_main_config_changed', this.on_config_changed);

   this.save_main_config = function(e) {
     self.main_config_saving = true;

     var form = $(e.target).serializeArray();
     for (var i = 0; i < form.length; i++) {
       self.main_config[form[i].name] = form[i].value;
     }

     RiotControl.trigger('site_main_config_save', self.site, self.main_config);
   };

   this.on_config_saved = function() {
     self.main_config_saving = false;
     self.update();
   };

   RiotControl.on('site_main_config_saved', this.on_config_saved);

  </script>
</main-config>
