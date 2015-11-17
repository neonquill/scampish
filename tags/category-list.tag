var RiotControl = require('riotcontrol');

require('delete-button.tag');

<category-list>
  <table class="table table-striped">
    <tbody ng-model="categories">
      <tr each="{ categories }">
        <td>
          <a href="#/{ site }/category/{ slug }">{ title }</a>
        </td>
        <td>
          <delete-button working="{ working }"
                         onclick="{ parent.delete_category }">
            <i class="fa fa-trash"></i> Delete
          </delete-button>
        </td>
      </tr>
    </tbody>
  </table>
  <div class="form-actions">
    <a class="btn btn-default" href="#/{ site }/new">
      <i class="fa fa-plus"></i> Add
    </a>
  </div>

  <script>
   var self = this;

   this.site = opts.site;

   this.on('mount', function() {
     console.log("category-list mount", this.site);
     RiotControl.trigger('categories_load', this.site);
   });
   
   this.on('unmount', function() {
     RiotControl.off('categories_changed', this.on_categories_changed);
     RiotControl.off('category_deleted', this.on_category_deleted);
   });

   this.on_categories_changed = function(c) {
     console.log('categories_changed', c);
     self.categories = c;
     self.update();
   };
  
   RiotControl.on('categories_changed', this.on_categories_changed);

   // Code to handle deleting a category.
   this.delete_category = function(e) {
     if (!e.item) {
       return;
     }
     console.log("delete", e.item);
     e.item.working = true;
     // XXX Should have a modal confirmation.
     RiotControl.trigger('category_delete', self.site, e.item.slug);
   };

   this.on_category_deleted = function(slug) {
     var n = self.categories.length;
     for (var i = 0; i < n; i++) {
       if (self.categories[i].slug === slug) {
         self.categories.splice(i, 1);
         break;
       }
     }
     self.update();
   };

   RiotControl.on('category_deleted', this.on_category_deleted);

  </script>
</category-list>
