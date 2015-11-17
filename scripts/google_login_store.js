define(['exports?AWS!aws-sdk-2.2.6.js', 'riot'], function(sAWS, riot) {
  function GoogleLoginStore() {
    riot.observable(this);

    var self = this;

    var IdentityPoolId = 'us-east-1:4bed1e4d-4a13-4105-b771-df3b31de9b48';
    var roleArn = 'arn:aws:iam::<AWS_ACCOUNT_ID>:role/<WEB_IDENTITY_ROLE_NAME>';

    // Stuff to do on login.
    self.on('google_signin', function(googleUser) {
      // set the Amazon Cognito region
      sAWS.config.region = 'us-east-1';

      sAWS.config.credentials = new sAWS.CognitoIdentityCredentials({
        IdentityPoolId: IdentityPoolId,
        Logins: {
          'accounts.google.com': googleUser.getAuthResponse().id_token
        }
      });

      // https://mobile.awsblog.com/post/TxBVEDL5Z8JKAC/Use-Amazon-Cognito-in-your-website-for-simple-AWS-authentication

      // We can set the get method of the Credentials object to retrieve
      // the unique identifier for the end user (identityId) once the provider
      // has refreshed itself
      sAWS.config.credentials.get(function(err) {
        if (err) {
          console.log("Error: "+err);
          return;
        }
        console.log("Cognito Identity Id: " +
                    sAWS.config.credentials.identityId);
        self.trigger('aws_login');
      });

      console.log('You are now logged in.');

      gapi.client.load('plus', 'v1', function(){
        var request = gapi.client.plus.people.get({
          'userId' : 'me'
        });

        request.execute(function(resp) {
          console.log(resp);
          console.log('ID: ' + resp.id);
          console.log('Email: ' + resp.emails[0].value);
          console.log('Display Name: ' + resp.displayName);
          console.log('Image URL: ' + resp.image.url);
          console.log('Profile URL: ' + resp.url);

          self.trigger('google_signed_in', resp);
        });
      });
    });

    // On failure.
    self.on('google_failure', function() {
     console.log('There was a problem logging you in.', error);
    });

    // To signout.
    self.on('google_signout', function() {
     var auth2 = gapi.auth2.getAuthInstance();
     auth2.signOut().then(function () {
       console.log('User signed out.');
       self.trigger('google_signed_out');
     });
    });

  }

  return GoogleLoginStore;

});
