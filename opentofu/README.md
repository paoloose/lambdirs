# IaC with OpenTofu

Automated multi-environment infrastructure for Lambdirs using
[OpenTofu](https://opentofu.org/).

> [!NOTE]
> The components in this architecture were designed to met the AWS Free Tier
> requirements. You may want to adjust the resources to fit your needs.

## Quick start

Requirements: See
[Installing Opentofu](https://opentofu.org/docs/intro/install/) and
[Setting up the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html).

### Bootstrapping

This infrastructure and its components (such as lambda deployment files)
heavy rely on an internal bucket called `internal_s3_bucket`, that is maintained
separately, in the `/bootstrap` directory.

This is because we also use this bucket as a backend for the OpenTofu state,
and in order to solve the
[🐔🥚 problem](https://www.monterail.com/blog/chicken-or-egg-terraforms-remote-backend)
we need to maintain this "bootstrap resources" separately.

```bash
# Name your internal backend in the vars file
cp template.tfvars .tfvars
vim .tfvars

# Bootstrap the resources
tofu -chdir bootstrap init
tofu -chdir bootstrap apply -var-file=../.tfvars
```

### Deploying the infrastructure

Authenticate to AWS (if not already)

```bash
aws configure
```

Create a `.tfvars` following the `template.tfvars` specification. See
[variables.tf](./variables.tf) for details.

```bash
cp template.tfvars .tfvars
vim .tfvars
```

This infrastructure has designed to support multi-environment deployments
using [OpenTofu workspaces](https://opentofu.org/docs/cli/workspaces/).
Create a workspace for each environment you want to deploy to.

```bash
tofu init
tofu workspace new dev
```

Finally, deploy the infrastructure

```bash
tofu plan -var-file=.tfvars
tofu apply -var-file=.tfvars
```

Resources in the same environment will be grouped in a Resource Group.

## Additional notes per service

### Amazon Cognito

The `terraform-provider-aws` provider does not yet support the Managed Login feature
(See [#40297](https://github.com/hashicorp/terraform-provider-aws/issues/40297)).

You will need to activate it manually in the AWS Console at
`Amazon Cognito > User pools > [pool] > Managed Login` in the `Hosted UI (classic)` tab,
select Update Version and confirm. Then create a style and assign it to your client.

This feature is not mandatory for the application to work.
