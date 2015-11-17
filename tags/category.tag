var RiotControl = require('riotcontrol');

require('category-config.tag');
require('page-list.tag');
require('file-list.tag');

<category>
  <ol class="breadcrumb">
    <li><a href="#">Home</a></li>
    <li><a href="#/{ opts.site }">{ opts.site }</a></li>
    <li class="active">{ opts.category_slug }</li>
  </ol>

  <div class="col-md-12">

    <h2>Category configuration</h2>
    <category-config site="{ opts.site }"
                     category_slug="{ opts.category_slug }"
                     done_redirect="{ done_redirect }">
    </category-config>

    <div if="{ !new }">
      <h2>Pages</h2>
      <page-list site="{ opts.site }"
                 category_slug="{ opts.category_slug }">
      </page-list>

      <h2>Files</h2>
      <file-list site="{ opts.site }"
                 path="{ opts.category_slug + '/' }">
      </file-list>

    </div>
  </div>

  <script>
   var self = this;

   this.new = (typeof opts.category_slug === 'undefined');

   if (this.new) {
     this.done_redirect = '#/' + opts.site;
   }
  </script>
</category>
