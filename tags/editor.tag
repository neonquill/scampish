var MarkdownIt = require('markdown-it');

<editor>
  <div class="form-group">
    <label class="col-sm-2 control-label" for="content">Content:</label>
    <div class="col-lg-5">
      <textarea name="content"
                value="{ opts.content }"
                class="form-control"
                rows="20">
      </textarea>
    </div>
    <div class="col-lg-5">
      <div class="panel panel-default">
        <div class="panel-heading">Preview</div>
        <div class="panel-body" name="preview"></div>
      </div>
    </div>
  </div>

  <script>
   var md = new MarkdownIt();

   this.on('update', function() {
     var result = md.render(opts.content || "");
     console.log("XXX", result);
     this.preview.innerHTML = result;
   });
  </script>
</editor>
