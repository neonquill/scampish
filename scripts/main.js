require('riot');
require('app.tag');

// XXX startsWith polyfill.
// XXX Put this somewhere else...
if (!String.prototype.startsWith) {
  String.prototype.startsWith = function(searchString, position) {
    position = position || 0;
    return this.indexOf(searchString, position) === position;
  };
}

// XXX endsWith polyfill.
// XXX Put this somewhere else...
if (!String.prototype.endsWith) {
  String.prototype.endsWith = function(searchString, position) {
      var subjectString = this.toString();
      if (typeof position !== 'number' || !isFinite(position) || Math.floor(position) !== position || position > subjectString.length) {
        position = subjectString.length;
      }
      position -= searchString.length;
      var lastIndex = subjectString.indexOf(searchString, position);
      return lastIndex !== -1 && lastIndex === position;
  };
}

var RiotControl = require('riotcontrol');
var GoogleLoginStore = require('google_login_store.js');
var AwsStore = require('aws_store');

// Create store instances.
var aws_store = new AwsStore();
// Register the store in the central dispatcher.
RiotControl.addStore(aws_store);

var google_login_store = new GoogleLoginStore();
RiotControl.addStore(google_login_store);

riot.mount('app');

// Re-broadcast the aws_login event.
// XXX This belongs somewhere else.
RiotControl.on('aws_login', function() {
  RiotControl.trigger('aws_login');
});
