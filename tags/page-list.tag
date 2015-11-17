var RiotControl = require('riotcontrol');

require('delete-button.tag');

<page-list>
  <table class="table table-striped">
    <tbody>
      <tr each="{ pages }">
        <td><a href="#/{ site }/category/{ category_slug }/page/{ slug }">
          { title }</a>
        </td>
        <td>
          <delete-button working="{ working }"
                         onclick="{ parent.delete_page }">
            <i class="fa fa-trash"></i> Delete
          </delete-button>
        </td>
      </tr>
    </tbody>
  </table>
  <div class="form-group">
    <a class="btn btn-default" href="#/{ site }/category/{ category_slug }/new">
      <i class="fa fa-plus"></i> Add
    </a>
  </div>

  <script>
   var self = this;

   this.site = opts.site;
   this.category_slug = opts.category_slug

   this.on('mount', function() {
     RiotControl.trigger('pages_load', opts.site, opts.category_slug);
   });

   this.on('unmount', function() {
     RiotControl.off('pages_changed', this.on_pages_changed);
     RiotControl.off('page_deleted', this.on_page_deleted);
   });

   this.on_pages_changed = function(pages) {
     console.log('pages_changed', pages);
     self.pages = pages;
     self.update();
   };

   RiotControl.on('pages_changed', this.on_pages_changed);

   // Code to handle deleting a page.
   this.delete_page = function(e) {
     if (!e.item) {
       return;
     }
     console.log("delete", e.item);
     e.item.working = true;
     // XXX Should have a modal confirmation.
     RiotControl.trigger('page_delete',
                         self.site,
                         opts.category_slug + '/',
                         e.item.slug);
   };

   this.on_page_deleted = function(slug) {
     var n = self.pages.length;
     for (var i = 0; i < n; i++) {
       if (self.pages[i].slug === slug) {
         self.pages.splice(i, 1);
         break;
       }
     }
     self.update();
   };

   RiotControl.on('page_deleted', this.on_page_deleted);
  </script>
</page-list>
