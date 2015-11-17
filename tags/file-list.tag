var RiotControl = require('riotcontrol');

require('delete-button.tag');
require('file-upload.tag');

<file-list>
  <table class="table table-striped">
    <tbody>
      <tr each="{ files }">
        <td>{ filename }</td>
        <td>
          <delete-button working="{ working }"
                         onclick="{ parent.delete_file }">
            <i class="fa fa-trash"></i> Delete
          </delete-button>
        </td>
      </tr>
    </tbody>
  </table>
  <file-upload site="{ site }" path="{ path }"></file-upload>
  </div>

  <script>
   var self = this;

   this.site = opts.site;
   this.path = opts.path;

   this.on('mount', function() {
     RiotControl.trigger('files_load', opts.site, opts.path);
   });

   this.on('unmount', function() {
     RiotControl.off('files_changed', this.on_files_changed);
     RiotControl.off('file_deleted', this.on_file_deleted);
     RiotControl.off('file_uploaded', this.on_file_uploaded);
   });

   this.on_files_changed = function(files) {
     console.log('files_changed', files);
     self.files = files;
     self.update();
   };

   RiotControl.on('files_changed', this.on_files_changed);

   // Code to handle deleting a file.
   this.delete_file = function(e) {
     if (!e.item) {
       return;
     }
     console.log("delete", e.item);
     e.item.working = true;
     // XXX Should have a modal confirmation.
     RiotControl.trigger('file_delete', self.site, opts.path, e.item.filename);
   };

   this.on_file_deleted = function(path, filename) {
     if (path != self.path) {
       return;
     }

     var n = self.files.length;
     for (var i = 0; i < n; i++) {
       if (self.files[i].filename === filename) {
         self.files.splice(i, 1);
         break;
       }
     }
     self.update();
   };

   RiotControl.on('file_deleted', this.on_file_deleted);

   this.on_file_uploaded = function(path, file) {
     if (path !== opts.path) {
       return;
     }

     this.files.push({filename: file.name});
     this.update();
   }.bind(this);

   RiotControl.on('file_uploaded', this.on_file_uploaded);
  </script>
</file-list>
