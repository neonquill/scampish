var RiotControl = require('riotcontrol');

require('site-controls.tag');
require('main-config.tag');
require('category-list.tag');
require('page.tag');

require('save-button.tag');
require('delete-button.tag');

<site-main>
  <div class="row">
    <ol class="breadcrumb">
      <li><a href="#">Home</a></li>
      <li class="active">{ site }</li>
    </ol>

    <site-controls site="{ site }"></site-controls>

    <div class="col-md-9">

      <div>{ upload_status }</div>

      <h2>Main config</h2>
      <main-config site="{ site }"></main-config>

      <h2>Categories</h2>
      <category-list site="{ site }"></category-list>

      <h2>Front page</h2>
      <page site="{ opts.site }"
            page_path=""
            page_slug="index"
            static_page="true"
            save_button_text="Save front page">
      </page>
    </div>
  </div>

  <script>
   this.site = opts.site;
  </script>
</site-main>
