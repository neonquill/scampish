// XXX Document
define(['exports?AWS!aws-sdk-2.2.6.js', 'bluebird'], function(sAWS, Promise) {
  var myAWS = {
    promises: [],

    // Dummy function to defer calling an aws function until we're logged in.
    wait_for_login: function(counter, obj, func, args) {
      return new Promise(function(resolve) {
        this.promises.push(resolve);
      }.bind(this))
      .bind(this)
      .then(function() {
        return this[obj][func].apply(this[obj], args);
      });
    },

    login: function() {
      this.lambda = new sAWS.Lambda();
      this.lambda.invokePromise = Promise.promisify(this.lambda.invoke);

      this.s3 = new sAWS.S3();
      Promise.promisifyAll(Object.getPrototypeOf(this.s3));

      // Unblock anything waiting.
      while (this.promises.length) {
        var resolve = this.promises.pop();
        resolve();
      }
    },

    // Dummy values to indicate we haven't logged in yet.
    lambda: {dummy: true},
    s3: {dummy: true}    
  };

  // Create default functions that wait until lambda is initialized.
  ['invokePromise'].forEach(function(api) {
    myAWS.lambda[api] = function() {
      return myAWS.wait_for_login(10, 'lambda', api, arguments);
    };
  });

  // Create default values that wait until s3 is initialized.
  var s3_cmds = ['getObjectAsync', 'uploadAsync', 'deleteObjectAsync',
                 'deleteObjectsAsync'];
  s3_cmds.forEach(function(api) {
    myAWS.s3[api] = function() {
      return myAWS.wait_for_login(10, 's3', api, arguments);
    };
  });

  return myAWS;
});
