# IaC with OpenTofu

Automated multi-environment infrastructure for Lambdirs

## Quick start

> [!NOTE]
> This setup remotely stores your different states in S3. Make sure you review
> the [main.tf](./main.tf).`terraform.backend` config block for details.
>
> If you prefer to maintain your state locally, remove the `backend` block.

Authenticate to AWS (if not already)

```bash
aws configure
```

Create a `dev.tfvars` following the `template.tfvars` format. See
[variables.tf](./variables.tf) for details.

```bash
cp template.tfvars dev.tfvars
```

Deploy the resources

```bash
tofu init

tofu workspace new dev
tofu plan -var-file=dev.tfvars
tofu apply -var-file=dev.tfvars
```

The workspace name you choose is the environment you are deploying to.
Resources in the same environment will be grouped in a Resource Group.
