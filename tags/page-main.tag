var RiotControl = require('riotcontrol');

require('page.tag');

<page-main>
  <ol class="breadcrumb">
    <li><a href="#">Home</a></li>
    <li><a href="#/{ opts.site }">{ opts.site }</a></li>
    <li>
      <a href="#/{ opts.site }/category/{ opts.category_slug }">
        { opts.category_slug }
      </a>
    </li>
    <li class="active">{ opts.page_slug }</li>
  </ol>
  <div class="col-md-12">
    <h2>Page configuration</h2>
    <page site="{ opts.site }"
          page_path="{ opts.category_slug + '/' }"
          page_slug="{ opts.page_slug }"
          done_redirect="#/{ opts.site }/category/{ opts.category_slug }">
    </page>
  </div>

  <script>
  </script>
</page-main>
