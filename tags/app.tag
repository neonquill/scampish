var RiotControl = require('riotcontrol');

require('router.tag');

require('login.tag');
require('navbar.tag');
require('sites.tag');
require('site-main.tag');
require('category.tag');
require('page-main.tag');

<missing>
  <h1>Missing!</h1>
</missing>

<app>
  <navbar></navbar>
  <login></login>
  <router routes="{ routes }">
  </router>

  <script>
   this.routes = [
     {path: "/", tag: "sites"},
     {path: "/<site>", tag: "site-main"},
     {path: "/<site>/new", tag: "category"},
     {path: "/<site>/category/<category_slug>", tag: "category"},
     {path: "/<site>/category/<category_slug>/new", tag: "page-main"},
     {path: "/<site>/category/<category_slug>/page/<page_slug>",
      tag: "page-main"},
     {path: "<path:url>", tag: "missing"}];
  </script>
</app>
