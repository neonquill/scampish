var RiotControl = require('riotcontrol');

<file-upload>
  <div if="{ show_upload }" class="row">
    <input type="file" name="file_input" style="display:none"
           onchange="{ input_changed }">
    <div class="jumbotron col-md-8 col-md-offset-2 { hover: inside }"
         ondragenter="{ dragenter }"
         ondragleave="{ dragleave }"
         ondragover="{ dragover }"
         ondrop="{ drop }"
         onclick="{ select }">
      <h1 if="{ !inside }">Drop files here</h1>
      <h1 if="{ inside }">Let go!</h1>
      <p>Or click to select</p>
    </div>
  </div>

  <table class="table table-striped">
    <tbody>
      <tr each="{ files }">
        <td>
          <img if="{ is_img }" src="{ url }" onload="{ revoke_url }">
        </td>
        <td>
          { filename }
        </td>
        <td>
          <button class="btn btn-primary"
                  disabled="{ uploading }"
                  onclick="{ upload_file }">
            <i if="{ !uploading }" class="fa fa-cloud-upload"></i>
            <i if="{ uploading }" class="fa fa-refresh fa-spin"></i>
            Upload
          </button>
        </td>
        <td>
          <button class="btn btn-warning"
                  disabled="{ uploading }"
                  onclick="{ cancel_upload }">
            <i class="fa fa-ban"></i> Cancel upload
          </button>
        </td>
      </tr>
    </tbody>
  </table>

  <div class="form-group">
    <button if="{ !show_upload }" class="btn btn-default"
            onclick="{ on_add_click }">
      <i class="fa fa-plus"></i> Add
    </button>
    <button if="{ show_upload && files.length === 0 }"
            class="btn btn-default"
            onclick="{ on_done_click }">
      <i class="fa fa-close"></i> Done adding
    </button>
    <button if="{ show_upload && files.length > 0 }"
            class="btn btn-primary"
            onclick="{ upload_all }">
      <i class="fa fa-cloud-upload"></i> Upload all
    </button>
  </div>

  <style>
   file-upload .hover {
     background-color: #dff0d8;
     transition: background-color 1s;
   }
   file-upload .jumbotron * { pointer-events: none; }
   file-upload img { max-width: 100px }
  </style>

  <script>
   this.show_upload = false;
   this.inside = false;
   this.files = [];

   this.on('unmount', function() {
     RiotControl.off('file_uploaded', this.on_file_uploaded);
   });

   this.on_add_click = function(e) {
     this.show_upload = true;
   };

   this.on_done_click = function(e) {
     this.show_upload = false;
   };

   this.dragenter = function(e) {
     console.log("enter");
     this.inside = true;
   };

   this.dragleave = function(e) {
     console.log("leave");
     this.inside = false;
   };

   this.dragover = function(e) {
     // Dummy function to prevent propagation.
   };

   this.drop = function(e) {
     this.inside = false;

     var files = e.dataTransfer.files;
     this.handle_files(files);
   };

   // Convert the button press into a file input click.
   this.select = function(e) {
     console.log("select", e);

     this.file_input.click();
   };

   this.input_changed = function(e) {
     console.log("input_changed", e);
     this.handle_files(e.target.files);
   };

   this.handle_files = function(files) {
     console.log("handle_files", files);

     var n = files.length;
     for (var i = 0; i < files.length; i++) {
       console.log(files[i]);
       var is_img = files[i].type.startsWith("image/");
       var f = {
         filename: files[i].name,
         is_img: is_img,
         url: window.URL.createObjectURL(files[i]),
         file: files[i]
       }
       this.files.push(f);
     }
   };

   this.revoke_url = function(e) {
     if (!e.item) {
       return;
     }

     window.URL.revokeObjectURL(e.item.url);
   };

   this.upload_file = function(e) {
     if (!e.item || e.item.uploading) {
       return;
     }

     console.log("upload", e.item.file);
     e.item.uploading = true;
     RiotControl.trigger('file_upload', opts.site, opts.path, e.item.file);
   };

   this.upload_all = function(e) {
     var n = this.files.length;
     for (var i = 0; i < n; i++) {
       this.upload_file({item: this.files[i]});
     }
   };

   this.cancel_upload = function(e) {
     if (!e.item) {
       return;
     }

     var i = this.files.indexOf(e.item);
     this.files.splice(i);
   };

   this.on_file_uploaded = function(path, file) {
     if (path !== opts.path) {
       return;
     }

     this.files = this.files.filter(function(f) {
       return (f.filename !== file.name);
     });
     this.update();
   }.bind(this);

   RiotControl.on('file_uploaded', this.on_file_uploaded);
  </script>
</file-upload>
