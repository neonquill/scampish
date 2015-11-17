<!-- Wrap an input field with form validation helpers. -->
<!-- http://alistapart.com/article/forward-thinking-form-validation -->
<valid-input>
  <div class="form-group { has-error: !valid }">
    <label class="col-sm-2 control-label" for="{ name }">{ label }:</label>
    <div class="col-sm-3">
      <input type="{ type }"
             name="{ name }"
             title="{ invalid_help }"
             required="{ required }"
             pattern="{ pattern }"
             placeholder="{ placeholder }"
             class="form-control"
             value="{ opts.value }"
             oninput="{ change }">
    </div>
    <div class="help-block col-sm-7">
      <span>{ help }</span>
      <span show="{ missing }">(Required)</span>
      <span show="{ !valid && !missing }">{ invalid_help }</span>
    </div>
  </div>

  <script>
   this.type = opts.type || "text";
   this.name = opts.name || "input";
   this.label = opts.label || "Input";
   this.placeholder = opts.placeholder || this.label;
   this.required = opts.required || false;
   this.pattern = opts.pattern || "*";
   this.help = opts.help || "";
   this.invalid_help = opts.invalid_help || "";

   this.valid = true;
   this.missing = false;

   this.change = function(e) {
     var element = e.target;

     this.value = element.value;
     this.valid = element.validity.valid;
     this.missing = element.validity.valueMissing;
   };
  </script>
</valid-input>
