<router>

  <script>
   var self = this;

   this._routes = [];
   this.active = null;

   // Specs match the flask style.
   // http://flask.pocoo.org/docs/0.10/quickstart/#routing
   // <name> matches a variable -> name
   // <path:name> matches a path -> name (possibly includes '/'s)
   // TODO: <int:name>, <float:name>
   function Route(spec, tag) {
     this.spec = spec;
     this.tag = tag;
     this.var_names = [];

     // Remove any leading '/'.
     var components = spec.replace(/^\//, '').split('/');
     var n = components.length;
     var tmp_regex = []
     for (var i = 0; i < n; i++) {
       var c = components[i];
       if (c.startsWith('<') && c.endsWith('>')) {
         // Variable parameter.
         c = c.slice(1, -1);
         var names = c.split(':');
         if (names.length === 2 && names[0] == 'path') {
           // Path converter variable.
           this.var_names.push(names[1]);
           tmp_regex.push('([\\w\-.\/]*)');
         } else if (names.length === 1) {
           // Regular variable.
           this.var_names.push(c);
           tmp_regex.push('([\\w\-.]*)');
         } else {
           throw new Error("Can't parse component: " + components[i]);
         }
       } else {
         // Literal.
         tmp_regex.push(c);
       }
     }

     this.regex = new RegExp('^' + tmp_regex.join('/') + '$');

     this.match = function(url) {
       var matches = url.match(this.regex);
       if (matches === null) {
         return null;
       }

       var variables = {};
       var n = matches.length;
       for (var i = 1; i < n; i++) {
         variables[this.var_names[i - 1]] = matches[i];
       }

       return variables;
     }
   }

   function route_match(path) {
     var num_routes = self._routes.length;

     for (var i = 0; i < num_routes; i++) {
       var route = self._routes[i];
       var match = route.match(path);

       if (match !== null) {
         console.log('Match!', self._routes[i]);
         if (self.active) {
           self.active.unmount();
         }

         var node = document.createElement("div");
         self.root.appendChild(node);
         self.active = riot.mount(node, route.tag, match)[0];
         break;
       }
     }
   }

   this.on('mount', function() {
     var num_routes = opts.routes.length;
     for (var i = 0; i < num_routes; i++) {
       var route = new Route(opts.routes[i].path,
                             opts.routes[i].tag);
       this._routes.push(route);
     }

     riot.route.exec(route_match);
   });

   riot.route(route_match);

   // Change the default parser.
   riot.route.parser(function(path) {
     // Delete leading '/'.
     // Must return an array.
     return [path.replace(/^\//, '')];
   });
  </script>
</router>
