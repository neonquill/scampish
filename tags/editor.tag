var MarkdownIt = require('markdown-it');

<editor>
  <textarea name="content"
            value="{ opts.content }"
            class="col-md-12 form-control"
            rows="20">
  </textarea>
  <div name="preview"></div>

  <script>
   var md = new MarkdownIt();

   this.on('update', function() {
     var result = md.render(opts.content || "");
     console.log("XXX", result);
     this.preview.innerHTML = result;
   });
  </script>
</editor>
