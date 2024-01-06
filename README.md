# Elastic Beanstalk App

This is a Nullstone application module to create an Elastic Beanstalk Application.

## When to use

AWS Elastic Beanstalk is a great choice for applications that want an EC2-optimized execution of common deployment environments.

## Network Access

Nullstone places the Beanstalk app into private subnets for the connected network.
While this enables routing to private services, you need to add capabilities to gain access to internal resources like databases.

## Logs

Logs are automatically emitted to several AWS Cloudwatch Log Groups: `/aws/elasticbeanstalk/<beanstalk-app-name>/...`.
To access through the Nullstone CLI, use `nullstone logs` CLI command. (See [`logs`](https://docs.nullstone.io/getting-started/cli/docs.html#logs) for more information)

## Secrets

Nullstone cannot automatically inject secrets into your Lambda application.
Instead, Nullstone injects environment variables that refer to secrets stored in AWS Secrets Manager.
If the Nullstone app has a secret `POSTGRES_URL`, Nullstone will inject `POSTGRES_URL_SECRET_ID` that contains the Secrets Manager Secret ID to retrieve.

For more information on how to retrieve secrets for your language, check out [Retrieve secrets from AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/retrieving-secrets.html).
