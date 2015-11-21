var RiotControl = require('riotcontrol');

<editor>
  <div class="form-group">
    <label class="col-sm-2 control-label" for="content">Content:</label>
    <div class="col-lg-5">
      <textarea name="content"
                value="{ opts.content }"
                class="form-control"
                rows="20"
                oninput="{ change }">
      </textarea>
    </div>
    <div class="col-lg-5">
      <div class="panel panel-default">
        <div class="panel-heading">Preview</div>
        <div class="panel-body" name="preview"></div>
      </div>
    </div>
  </div>

  <style>
   editor img { max-width: 100% }
  </style>

  <script>
   this.on('mount', function() {
     RiotControl.trigger('render_markdown', opts.site, opts.path,
                         opts.content || "");
   });

   this.on('unmount', function() {
     RiotControl.off('markdown_rendered', this.on_markdown_rendered);
   });

   this.change = function(e) {
     RiotControl.trigger('render_markdown', opts.site, opts.path,
                         this.content.value || "");
   };

   this.on_markdown_rendered = function(html) {
     this.preview.innerHTML = html;
   }.bind(this);

   RiotControl.on('markdown_rendered', this.on_markdown_rendered);
  </script>
</editor>
