# 0.2.3 (Jan 27, 2024)
* Fixed `nullstone push` by adding `s3:GetBucketLocation` to `Pusher`.

# 0.2.2 (Jan 16, 2024)
* Added support for `nullstone ssh`.

# 0.2.1 (Dec 08, 2023)
* Added support for environment variables and secrets from capability modules.

# 0.2.0 (Dec 06, 2023)
* Added support for environment variables.
* Added support for secrets (injecting `<ENV_VAR>_SECRET_ID` since Beanstalk doesn't support secrets injection).

# 0.1.7 (Dec 29, 2023)
* Expanded IAM permissions to handle more beanstalk scenarios.

# 0.1.6 (Dec 29, 2023)
* Fixed improper reference to AWS Account ID for log reader.

# 0.1.5 (Dec 29, 2023)
* Fixed log-reader permissions to use the correct Cloudwatch log groups.

# 0.1.4 (Dec 18, 2023)
* Enable CloudWatch logging

# 0.1.3 (Nov 29, 2023)
* Connect the `instance_type` input to the EC2 instance created

# 0.1.2 (Nov 28, 2023)
* Added support for configuring beanstalk environment settings through capability output `settings`.

# 0.1.1 (Nov 24, 2023)
* Upgraded terraform providers.

# 0.1.0 (Oct 17, 2023)
* Initial draft
