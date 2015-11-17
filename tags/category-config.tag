var RiotControl = require('riotcontrol');
var common = require('common');

require('valid-input.tag');
require('save-button.tag');

<category-config>
  <form class="form-horizontal" name="categoryForm" onsubmit="{ submit }"
        oninput="{ change }">
    <fieldset>
      <valid-input name="title"
                   label="Title"
                   required=true
                   value="{ category.title }">
      </valid-input>
      <valid-input name="slug"
                   label="Slug"
                   required=true
                   value="{ category.slug }"
                   help="URL safe version of the name."
                   pattern="[\\w-]*"
                   invalid_help="(Only letters, numbers, '-', and '_')">
      </valid-input>
      <valid-input name="order"
                   label="Order"
                   type="number"
                   required=true
                   value="{ category.order }"
                   help="Determines order in menu."
                   invalid_help="(Number)">
      </valid-input>
    </fieldset>

    <div class="form-group">
      <div class="col-sm-offset-2 col-sm-10">
        <save-button saving="{ saving }" valid="{ valid }">
          Save category
        </save-button>
        <button type="button" class="btn btn-default" onclick="{ cancel }">
          Cancel
        </button>
      </div>
    </div>
  </form>

  <script>
   var self = this;

   this.valid = false;
   this.saving = false;

   this.on('mount', function() {
     this.load();
   });

   this.on('unmount', function() {
     RiotControl.off('category_saved', this.on_category_saved);
     RiotControl.off('category_changed', this.on_category_changed);
   });

   this.change = function(e) {
     this.valid = this.categoryForm.checkValidity();

     if (e && e.target) {
       if (e.target.name == 'title') {
         var slug = common.slugify(this.tags.title.value);
         this.category.slug = slug;
       }
     }
   };

   this.cancel = function(e) {
     if (opts.done_redirect) {
       riot.route(opts.done_redirect);
     } else {
       // Just reload
       this.load();
     }
   };

   this.load = function() {
     this.category = {};
     RiotControl.trigger('category_load',
                         opts.site, opts.category_slug);
   };

   this.submit = function(e) {
     self.saving = true;

     var form = $(e.target).serializeArray();
     for (var i = 0; i < form.length; i++) {
       self.category[form[i].name] = form[i].value;
     }

     RiotControl.trigger('category_save', opts.site, self.category);
   };

   this.on_category_saved = function() {
     self.saving = false;
     if (opts.done_redirect) {
       riot.route(opts.done_redirect);
     } else {
       self.update();
     }
   };

   RiotControl.on('category_saved', this.on_category_saved);

   this.on_category_changed = function(c) {
     console.log('category_changed', c);
     self.category = c;
     self.update();
   };

   RiotControl.on('category_changed', this.on_category_changed);

  </script>
</category-config>
