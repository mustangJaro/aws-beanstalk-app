// This file is replaced by code-generation using 'capabilities.tf.tmpl'
// This file helps app module creators define a contract for what types of capability outputs are supported.
locals {
  capabilities = {
    // settings is a list of settings that are configured on aws_elastic_beanstalk_environment
    // Reference: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html#command-options-general-ec2instances
    // These are merged with default settings inside the module to produce a final settings list that is applied to the beanstalk app in this environment
    // There is currently no logic to prevent capabilities from modifying settings in the app module or other capabilities
    settings = [
      {
        // Namespace describes the area of AWS that this settings is configuring (e.g. "aws:ec2:vpc")
        namespace = ""
        name      = ""
        value     = ""
      }
    ]

    // private_urls follows a wonky syntax so that we can send all capability outputs into the merge module
    // Terraform requires that all members be of type list(map(any))
    // They will be flattened into list(string) when we output from this module
    private_urls = [
      {
        url = ""
      }
    ]

    // public_urls follows a wonky syntax so that we can send all capability outputs into the merge module
    // Terraform requires that all members be of type list(map(any))
    // They will be flattened into list(string) when we output from this module
    public_urls = [
      {
        url = ""
      }
    ]
  }
}
