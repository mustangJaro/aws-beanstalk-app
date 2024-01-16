locals {
  // Private and public URLs are shown in the Nullstone UI
  // Typically, they are created through capabilities attached to the application
  // If this module has URLs, add them here as list(string)
  additional_private_urls = []

  additional_public_urls = [
    "http://${aws_elastic_beanstalk_environment.this.cname}",
    "http://${aws_elastic_beanstalk_environment.this.endpoint_url}",
  ]

  public_urls  = compact(concat([for url in try(local.capabilities.public_urls, []) : url["url"]], local.additional_public_urls))
  private_urls = compact(concat([for url in try(local.capabilities.private_urls, []) : url["url"]], local.additional_private_urls))
}
