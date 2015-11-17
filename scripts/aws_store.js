// Important config notes, including CORS config.
// https://docs.aws.amazon.com/AWSJavaScriptSDK/guide/browser-configuring.html

define(function(require) {
  var riot = require('riot'),
      Promise = require('bluebird'),
      matter = require('gray-matter-browser'),
      yaml = require('js-yaml'),
      myAWS = require('my-aws');

  var AwsCache = {
    files: {},

    normalize_path: function(path) {
      if (path.endsWith('/')) {
        path = path + '.dir';
      }

      return path;
    },

    save: function(path, value) {
      path = this.normalize_path(path);
      this.files[path] = value;
    },

    get: function(path) {
      path = this.normalize_path(path);
      return this.files[path];
    },

    delete: function(path) {
      path = this.normalize_path(path);
      delete this.files[path];
    },

    delete_prefix: function(prefix) {
      var items = Object.keys(this.files);
      var n = items.length;

      for (var i = 0; i < n; i++) {
        if (items[i].startsWith(prefix)) {
          console.log("cache delete", items[i]);
          this.delete(items[i]);
        }
      }
    }
  };

  // Class for a single site.
  function AwsSite(s3_site) {
    this.name = s3_site.name;
    this.bucket = s3_site.bucket;
    this.slug = s3_site.slug;

    // Get a list of files in a directory.
    this.get_dir_listing = function(path) {
      // XXX Make sure path ends in a /.
      var cache_path = '/' + this.bucket + '/' + path;
      console.log("get_dir_listing_cache", cache_path);
      var value = AwsCache.get(cache_path);
      if (typeof value !== 'undefined') {
        return Promise.resolve(value);
      }

      var params = {
        Bucket: this.bucket,
        Delimiter: '/',
        Prefix: path
      };
      return myAWS.s3.listObjectsAsync(params).bind(this)
        .then(function(data) {
          // XXX ceck data.IsTruncated.
          // XXX Probably a better way to prune this data.
          AwsCache.save(cache_path, data);
          return data;
        });
    };

    // Delete all files in a given directory.
    this.delete_dir = function(path) {
      var params = {
        Bucket: this.bucket,
        Prefix: path
      };
      return myAWS.s3.listObjectsAsync(params).bind(this)
        .then(function(data) {
          var objs = data.Contents.map(function(obj) {
            return {Key: obj.Key};
          });
          var params = {
            Bucket: this.bucket,
            Delete: {
              Objects: objs,
              Quiet: true
            }
          };
          // XXX Check for errors?  Doesn't seem throw any...
          return myAWS.s3.deleteObjectsAsync(params);
        });
    };

    // Load a file from s3.
    this.get_file = function(path, parser) {
      var cache_path = '/' + this.bucket + '/' + path;
      var value = AwsCache.get(cache_path);
      if (typeof value !== 'undefined') {
        return Promise.resolve(value);
      }

      var params = {
        Bucket: this.bucket,
        Key: path
      };
      return myAWS.s3.getObjectAsync(params).bind(this)
        .then(function(data) {
          var doc = parser(data.Body);
          AwsCache.save(cache_path, doc);
          return doc;
        });
    };

    // Load a yaml file.
    this.get_yaml_file = function(path) {
      return this.get_file(path, yaml.safeLoad);
    };

    // Load a file with yaml front matter.
    this.get_yaml_frontmatter_file = function(path) {
      return this.get_file(path, function(data) {
        return matter(data.toString('utf8'));
      });
    };

    // Save a file.
    this.save_file = function(path, data, old_path) {
      var delete_path;

      if (typeof old_path !== 'undefined') {
        // The old path exists, delete the caching there.
        delete_path = old_path;
      } else {
        // This is a new insert or updating an existing entry.
        delete_path = path;
      }

      // Delete the cached version of this file.
      var cache_path = '/' + this.bucket + '/' + delete_path;
      console.log("save_file_delete_cache_file", cache_path);
      AwsCache.delete(cache_path);
      // Also, need to delete the directory listing.
      var cache_dir = cache_path.slice(0, cache_path.lastIndexOf('/') + 1);
      console.log("save_file_delete_cache_dir", cache_dir);
      AwsCache.delete(cache_dir);

      var params = {
        Bucket: this.bucket,
        Key: path,
        Body: data
      };

      // XXX track upload?
      return myAWS.s3.uploadAsync(params)
        .then(function() {
          console.log("Sucessfully uploaded file!");
        });
    };

    // Upload a new file.
    this.upload_file = function(path, file) {
      // Delete the cached directory listing.
      AwsCache.delete(path);

      var params = {
        Bucket: this.bucket,
        Key: path + file.name,
        Body: file
      };

      // XXX track upload?
      return myAWS.s3.uploadAsync(params)
        .then(function() {
          console.log("Sucessfully uploaded file!");
        });
    };

    // Save a yaml config file.
    this.save_yaml_file = function(path, obj, old_path) {
      var data = yaml.safeDump(obj);
      return this.save_file(path, data, old_path);
    };

    // Delete a file.
    this.delete_file = function(path) {
      // XXX Code is duplcated in save_file().
      var cache_path = '/' + this.bucket + '/' + path;
      AwsCache.delete(cache_path);
      // Delete the parent directory listing.
      var cache_dir = cache_path.slice(0, cache_path.lastIndexOf('/') + 1);
      AwsCache.delete(cache_dir);

      var params = {
        Bucket: this.bucket,
        Key: path
      };
      // XXX Doesn't appear to throw an error with a bad filename!
      return myAWS.s3.deleteObjectAsync(params);
    };

    // Get info about a single category.
    this.get_category = function(prefix) {
      return this.get_yaml_file(prefix + '_config.yaml')
        .then(function(doc) {
          // XXX first param should really be 'src/'.length.
          doc.slug = prefix.slice(4, -1);
          doc.orig_slug = doc.slug;
          console.log("category!", doc);
          return doc;
        });
    };

    // Unwrap an s3 prefix when getting a category.
    this.get_s3_category = function(s3_prefix) {
      return this.get_category(s3_prefix.Prefix);
    };

    // Save a category.
    this.save_category = function(prefix, category, old_prefix) {
      if (typeof old_prefix !== 'undefined') {
        var old_path = old_prefix + '_config.yaml';
      }
      this.save_yaml_file(prefix + '_config.yaml',
                          category, old_path);

      // Need to delete the directory listing at the top level.
      var cache_dir = '/' + this.bucket + '/src/';
      console.log("save_category_delete_cache_dir", cache_dir);
      AwsCache.delete(cache_dir);
    };

    // Delete a category.
    this.delete_category = function(prefix) {
      var cache_dir = '/' + this.bucket + '/' + prefix;
      AwsCache.delete_prefix(cache_dir);
      // Delete the src dir to remove this category.
      AwsCache.delete('/' + this.bucket + '/src/');

      return this.delete_dir(prefix);
    };

    // Get the list of categories for this site.
    this.get_categories = function() {
      return this.get_dir_listing('src/').bind(this)
        .then(function(data) {
          console.log("Got listing:", data);
          return Promise.all(
            data.CommonPrefixes.map(this.get_s3_category, this));
        })
        .then(function(data) {
          var categories = Object.keys(data)
            .map(function(key) { return data[key]; }, this);

          // Sort by order parameter.
          categories.sort(function(a, b) {
            return a.order - b.order;
          });

          console.log("Categories!", categories);
          return categories;
        });
    };

    // Get and parse a page file from s3.
    this.get_page = function(path) {
      return this.get_yaml_frontmatter_file(path).bind(this)
        .then(function(doc) {
          doc.slug = path.slice(path.lastIndexOf('/') + 1,
                                path.lastIndexOf('.'));
          doc.orig_slug = doc.slug;
          console.log("New page", doc);
          return doc;
        });
    };

    // Decode an s3 listObjects return value and call get_page.
    this.get_s3_page = function(s3_page) {
      return this.get_page(s3_page.Key);
    };

    // Save a page.
    this.save_page = function(old_path, new_path, page) {
      var doc = {layout: page.layout,
                 title: page.title,
                 order: page.order,
                 content: page.content};

      // XXX Handle renames.

      var data = matter.stringify(page);
      console.log("Matter", data);

      return this.save_file(new_path, data, old_path);
    };

    // Get a list of pages from s3 based on a prefix.
    this.get_pages = function(prefix) {
      return this.get_dir_listing(prefix).bind(this)
        .then(function(data) {
          var filtered = data.Contents.filter(function(object) {
            return (object.Key.endsWith('.markdown'));
          });

          return Promise.all(
            filtered.map(this.get_s3_page, this));
        })
        .then(function(pages) {
          // Sort by order parameter.
          pages.sort(function(a, b) {
            return a.order - b.order;
          });

          console.log("get_pages found", pages);
          return pages;
        });
    };

    // Get a list of files from s3 based on a prefix.
    this.get_files = function(prefix) {
      return this.get_dir_listing(prefix).bind(this)
        .then(function(data) {
          var filtered = data.Contents.filter(function(object) {
            // Don't include markdown and yaml files.
            if (object.Key.endsWith('.markdown') ||
                object.Key.endsWith('.yaml')) {
              return false;
            } else {
              return true;
            }
          });

          return filtered.map(function(s3_obj) {
            var fn = s3_obj.Key.slice(s3_obj.Key.lastIndexOf('/') + 1);
            return {filename: fn};
          });
        });
    };

    // Render.
    this.render = function(type) {
      var options = {
        bucket: this.bucket,
        type: type
      };

      var params = {
        FunctionName: 'cms_render_test',
        Payload: JSON.stringify(options)
      };
      return myAWS.lambda.invokePromise(params)
        .then(function(data) {
          console.log("Ran render!", data);
          return data;
        });
    };
  }

  // Global AWS state object.
  // As things are loaded, they will be cached in here.
  var AwsState = {
    // XXX Clean up this entire object, and that ^ caching comment.

    // XXX format?
    sites: {},
    sites_loaded: false,

    // Get the list of buckets.
    get_buckets: function() {
      var cache_path = '/';
      var value = AwsCache.get(cache_path);
      if (typeof value !== 'undefined') {
        return Promise.resolve(value);
      }

      var params = {
        FunctionName: 'getBucketList'
      };

      if (this.get_buckets_promise instanceof Promise) {
        return this.get_buckets_promise;
      }

      var p = myAWS.lambda.invokePromise(params).bind(this)
        .then(function(data) {
          console.log("Buckets:", data);

          if (data.FunctionError) {
            console.log(data.Payload);
            throw new Error('Failed to fetch bucket list.');
          }

          // Should have succeeded by now.
          var obj = JSON.parse(data.Payload);
          console.log(obj);
          AwsCache.save(cache_path, obj.Buckets);
          this.get_buckets_promise = null;
          return(obj.Buckets);
        });

      this.get_buckets_promise = p;
      return p;
    },

    // Check a given bucket to see if it's a site.
    lookup_bucket_site: function(bucket) {
      var cache_path = '/' + bucket.Name + '/scampish_config.yaml';
      var value = AwsCache.get(cache_path);
      if (typeof value !== 'undefined') {
        return Promise.resolve(value);
      }

      var params = {
        Bucket: bucket.Name,
        Key: 'scampish_config.yaml'
      };
      return myAWS.s3.getObjectAsync(params).bind(this)
        .then(function(data) {
          console.log("Got scampish config:", data);
          var doc = yaml.safeLoad(data.Body);
          // XXX Should this just be saved?
          doc.bucket = bucket.Name;
          AwsCache.save(cache_path, doc);
          return doc;
        })
        .catch(function(e) {
          console.log("Scampish config error:", e);
          return null;
        });
    },

    // Get the list of sites.
    get_sites: function() {
      if (this.sites_loaded) {
        return Promise.resolve(this.sites);
      }

      if (this.get_sites_promise instanceof Promise) {
        return this.get_sites_promise;
      }

      var p = this.get_buckets().bind(this)
        .then(function(buckets) {
          return Promise.all(buckets.map(this.lookup_bucket_site));
        })
        .then(function(sites) {
          var filtered = sites.filter(function(site) {
            return (site !== null);
          });

          var n = filtered.length;
          this.sites = [];
          for (var i = 0; i < n; i++) {
            var s = filtered[i];
            this.sites.push(new AwsSite(s));
          }

          // XXX Use a better flag.
          this.sites_loaded = true;
          this.get_sites_promise = null;
          return this.sites;
        });

      this.get_sites_promise = p;
      return p;
    },

    // Get an individual site.
    get_site: function(site_slug) {
      var p;

      if (this.sites_loaded) {
        p = Promise.resolve();
      } else {
        p = this.get_sites();
      }

      return p.bind(this).then(function() {
        var n = this.sites.length;
        for (var i = 0; i < n; i++) {
          if (this.sites[i].slug === site_slug) {
            return this.sites[i];
          }
        }

        // Didn't find the site!
        throw new Error('Unknown site:', site_slug);
      });
    }

    // End of AwsState.
  };

  function AwsStore() {
    riot.observable(this);

    var self = this;

    // Once we've logged in, we can create real objects.
    self.on('aws_login', function() {
      myAWS.login();
    });

    // Load a set of pages.
    self.on('pages_load', function(site_slug, category_slug) {
      console.log("pages_load", site_slug, category_slug);

      // Don't try to reload if we're already fetching.
      var memo_path = site_slug + '/' + category_slug;
      if (self.requested_pages === memo_path) {
        console.log("pages_load dupe");
        return;
      }

      self.requested_pages = memo_path;
      AwsState.get_site(site_slug)
        .then(function(site) {
          return site.get_pages('src/' + category_slug + '/');
        })
        .then(function(pages) {
          self.requested_pages = null;
          self.trigger('pages_changed', pages);
        });
    });

    // Load a requested page.
    self.on('page_load', function(site_slug, path, page_slug) {
      if (typeof page_slug === "undefined") {
        // This is a new page, return an empty config.
        var page = {title: '',
                    slug: '',
                    order: '',
                    layout: 'post',
                    content: ''};
        self.trigger('page_changed', page);
        return;
      }

      var page_path = path + page_slug;
      page_path = 'src/' + page_path + '.markdown';

      // Don't try to reload if we're already getting the page.
      // XXX use a saved promise instead of this.
      var memo_path = site_slug + '/' + page_path;
      if (self.requested_page === memo_path) {
        console.log("page_load dupe");
        return;
      }

      self.requested_page = memo_path;

      AwsState.get_site(site_slug)
      .then(function(site) {
        return site.get_page(page_path);
      })
      .then(function(page) {
        self.requested_page = null;
        self.trigger('page_changed', page);
      });
    });

    // Save a page.
    self.on('page_save', function(site_slug, path, page) {
      console.log("Saving:", page);

      var new_path = 'src/' + path + page.slug + '.markdown';
      var old_path = 'src/' + path + page.orig_slug + '.markdown';

      AwsState.get_site(site_slug)
        .then(function(site) {
          return site.save_page(old_path, new_path, page);
        })
        .then(function() {
          self.trigger('page_saved');
        });
    });

    // Delete a page.
    self.on('page_delete', function(site_slug, page_path, page_slug) {
      var path = 'src/' + page_path + page_slug + '.markdown';
      AwsState.get_site(site_slug)
        .then(function(site) {
          return site.delete_file(path);
        })
      .then(function() {
        self.trigger('page_deleted', page_slug);
      });
    });


    // Load a list of sites.
    self.on('sites_load', function() {
      if (self.sites_loading) {
        // Don't try to load again.
        return;
      }

      self.sites_loading = true;

      AwsState.get_sites()
        .then(function(sites) {
          self.trigger('sites_changed', sites);
          self.sites_loading = false;
        });
    });

    self.on('render', function(site_slug, type) {
      AwsState.get_site(site_slug)
        .then(function(site) {
          return site.render(type);
        })
        .then(function(data) {
          self.trigger('render_done', data);
        });
    });

    self.on('site_main_config_load', function(site_slug) {
      console.log("aws loading main config", site_slug);

      // Don't try to reload if we're already getting the page.
      if (self.requested_main_config === site_slug) {
        console.log("site_main_config dupe");
        return;
      }

      self.requested_main_config = site_slug;
      AwsState.get_site(site_slug)
        .then(function(site) {
          return site.get_yaml_file('src/_config.yaml');
        })
        .then(function(c) {
          self.requested_main_config = null;
          self.trigger('site_main_config_changed', c);
        });
    });

    // Save the main site config.
    self.on('site_main_config_save', function(site_slug, config) {
      console.log("Saving:", config);

      AwsState.get_site(site_slug)
        .then(function(site) {
          return site.save_yaml_file('src/_config.yaml', config);
        })
        .then(function() {
          self.trigger('site_main_config_saved');
        });
    });

    self.on('categories_load', function(site_slug) {
      console.log("categories_load", site_slug);

      // Don't try to reload if we're already fetching.
      if (self.requested_categories === site_slug) {
        console.log("categories_load dupe");
        return;
      }

      self.requested_categories = site_slug;
      AwsState.get_site(site_slug)
        .then(function(site) {
          return site.get_categories();
        })
        .then(function(categories) {
          self.requested_categories = null;
          self.trigger('categories_changed', categories);
        });
    });

    self.on('category_load', function(site_slug, category_slug) {
      console.log("category_load", site_slug, category_slug);

      if (typeof category_slug === "undefined") {
        // This is a new category, return an empty config.
        var category = {title: '',
                        slug: '',
                        order: 1};
        self.trigger('category_changed', category);
        return;
      }

      var memo_path = site_slug + '/' + category_slug;
      // Don't try to reload if we're already fetching.
      if (self.requested_category === memo_path) {
        console.log("category_load dupe");
        return;
      }

      self.requested_category = memo_path;
      AwsState.get_site(site_slug)
        .then(function(site) {
          return site.get_category('src/' + category_slug + '/');
        })
        .then(function(category) {
          self.requested_category = null;
          self.trigger('category_changed', category);
        });
    });

    // Save a category
    self.on('category_save', function(site_slug, category) {
      console.log("Saving:", category);

      AwsState.get_site(site_slug)
        .then(function(site) {
          if (typeof category.orig_slug !== 'undefined') {
            var old_path = 'src/' + category.orig_slug + '/';
          }
          return site.save_category('src/' + category.slug + '/',
                                    category, old_path);
        })
        .then(function() {
          self.trigger('category_saved');
        });
    });

    // Delete a category.
    self.on('category_delete', function(site_slug, category_slug) {
      console.log("Deleting:", category_slug);

      AwsState.get_site(site_slug)
        .then(function(site) {
          return site.delete_category('src/' + category_slug + '/');
        })
        .then(function() {
          self.trigger('category_deleted', category_slug);
        });
    });

    // Load a set of files.
    self.on('files_load', function(site_slug, path) {
      console.log("files_load", site_slug, path);

      // Don't try to reload if we're already fetching.
      var memo_path = site_slug + '/' + path;
      if (self.requested_files === memo_path) {
        console.log("files_load dupe");
        return;
      }

      self.requested_files = memo_path;
      AwsState.get_site(site_slug)
        .then(function(site) {
          return site.get_files('src/' + path);
        })
        .then(function(files) {
          self.requested_files = null;
          self.trigger('files_changed', files);
        });
    });

    // Delete a file.
    self.on('file_delete', function(site_slug, path, filename) {
      AwsState.get_site(site_slug)
        .then(function(site) {
          return site.delete_file('src/' + path + filename);
        })
        .then(function() {
          self.trigger('file_deleted', path, filename);
        });
    });

    // Upload a file.
    self.on('file_upload', function(site_slug, path, file) {
      AwsState.get_site(site_slug)
        .then(function(site) {
          return site.upload_file('src/' + path, file);
        })
        .then(function() {
          self.trigger('file_uploaded', path, file);
        });
    });
  }

  return AwsStore;

});
