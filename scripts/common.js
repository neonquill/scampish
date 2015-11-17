define([], function() {
  var Common = {
    slugify: function(text) {
      return text.toString().toLowerCase()
        // Replace spaces with -
        .replace(/\s+/g, '-')
        // Remove all non-word chars
        .replace(/[^\w\-]+/g, '')
        // Replace multiple - with single -
        .replace(/\-\-+/g, '-')
        // Trim - from start of text
        .replace(/^-+/, '')
        // Trim - from end of text
        .replace(/-+$/, '');
    }
  };

  return Common;
});
