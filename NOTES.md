http://stackoverflow.com/a/18089783
http://stackoverflow.com/a/29950510

It's not possible to limit listing all buckets.  Several alternatives
exist, I'm going to just ignore it for now.  This means that this
doesn't really work as a hosting solution.

To use the amazon generated lambda api (this is documented with the
README that comes with the generated code):

      var config = {
        accessKey: AWS.config.credentials.accessKeyId,
        secretKey: AWS.config.credentials.secretAccessKey,
        sessionToken: AWS.config.credentials.sessionToken
      };
      self.api = apigClientFactory.newClient(config);
