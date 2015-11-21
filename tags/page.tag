var RiotControl = require('riotcontrol');
var common = require('common');

require('valid-input.tag');
require('loading.tag');
require('editor.tag');

//
// Arguments:
//  site: slug for the site we're editing.
//  page_path: Path to the page we're editing
//  page_slug: Filename for the page without extension.
//  static_page: (optional) True if we don't want to show the slug and
//    order fields.
//  save_button_text: (optional) Text for the save button.
//  done_redirect: (optiona) Path to redirect to after saving, or if
//    the user hits the Cancel button.
//
// NOTE: File in bucket will be 'src/' + page_path + page_slug + '.markdown'

<page>
  <loading if="{ loading }" label="{ opts.page_slug }"></loading>
  <div if="{ !loading }" class="row">
    <form class="form-horizontal" name="pageForm" onsubmit={ submit }
          oninput="{ change }">
      <fieldset>
        <valid-input name="title"
                     label="Title"
                     required=true
                     value="{ page.title }">
        </valid-input>
        <valid-input if="{ !static_page }"
                     name="slug"
                     label="Slug"
                     required=true
                     value="{ page.slug }"
                     help="URL safe version of the name."
                     pattern="[\\w-]*"
                     invalid_help="(Only letters, numbers, '-', and '_')">
        </valid-input>
        <valid-input if="{ !static_page }"
                     name="order"
                     label="Order"
                     type="number"
                     required=true
                     value="{ page.order }"
                     help="Determines order in menu."
                     invalid_help="(Number)">
        </valid-input>
        <valid-input name="layout"
                     label="Layout"
                     required=true
                     value="{ page.layout }"
                     help="Page template version (usually 'post').">
        </valid-input>
        <editor site="{ opts.site }"
                path="{ opts.page_path }"
                content="{ page.content }">
        </editor>
      </fieldset>
      <div class="form-group">
        <div class="col-sm-offset-2 col-sm-10">
          <save-button saving="{ saving }" valid="{ valid }">
            { parent.save_button_text }
          </save-button>
          <button class="btn btn-default" onclick="{ cancel }">Cancel</button>
        </div>
      </div>
    </form>
  </div>

  <script>
   var self = this;

   this.page = {};
   this.valid = false;

   this.loading = true;
   this.saving = false;

   this.save_button_text = opts.save_button_text || "Save page";
   this.static_page = opts.static_page || false;

   this.on('mount', function() {
     this.load();
   });

   this.on('unmount', function() {
     RiotControl.off('page_changed', this.on_page_changed);
     RiotControl.off('page_saved', this.on_page_saved);
   });

   this.load = function() {
     console.log("page reloading");

     this.loading = true;
     this.page = {};
     RiotControl.trigger('page_load', opts.site, opts.page_path,
                         opts.page_slug);
   };

   this.submit = function(e) {
     console.log("Submit");

     self.saving = true;

     var form = $(this.pageForm).serializeArray();
     for (var i = 0; i < form.length; i++) {
       self.page[form[i].name] = form[i].value;
     }

     RiotControl.trigger('page_save', opts.site, opts.page_path, self.page);
   };

   this.on_page_saved = function() {
     self.saving = false;
     if (opts.done_redirect) {
       riot.route(opts.done_redirect);
     } else {
       self.update();
     }
   };

   RiotControl.on('page_saved', this.on_page_saved);

   this.change = function(e) {
     this.valid = this.pageForm.checkValidity();

     // If we're not a static page, update the slug when the title changes.
     if (!this.static_page && e && e.target && e.target.name == 'title') {
       var slug = common.slugify(this.tags.title.value);
       this.page.slug = slug;
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

   this.on_page_changed = function(page) {
     console.log("page_changed", page);
     self.loading = false;
     self.page = page;
     self.update();
   };

   RiotControl.on('page_changed', this.on_page_changed);

  </script>
</page>
