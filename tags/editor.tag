var ProseMirror = require("prosemirror/dist/edit").ProseMirror

<editor>
  <div id="editor"></div>

  <script>
   this.on('mount', function() {
     var editor = new ProseMirror({
       place: this.root.querySelector("#editor"),
       doc: opts.content,
       docFormat: "text"
     });
   });
  </script>
</editor>
