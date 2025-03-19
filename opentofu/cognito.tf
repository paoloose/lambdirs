/* Cognito User Pool */

resource "aws_cognito_user_pool" "lambdirs" {
  name = "Lambdirs-${local.env} user pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length  = 8
    require_numbers = true
  }

  # You would want to prevent deletion in production environments
  deletion_protection = "INACTIVE"

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  # See <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool#schema-defaults-for-standard-attributes>
  # for documentation on schema attributes

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
  }

  tags = {
    Name        = "Lambdirs-${local.env} user pool"
    Environment = local.env
  }
}

/* Cognito User Pool Lambdirs Client */

resource "aws_cognito_user_pool_client" "lambdirs" {
  name         = "Lambdirs-${local.env} user pool client"
  user_pool_id = aws_cognito_user_pool.lambdirs.id

  access_token_validity  = 24
  refresh_token_validity = 90

  prevent_user_existence_errors = "ENABLED"

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]

  callback_urls = ["http://localhost:6969/callback"]
  logout_urls   = ["http://localhost:6969/logout"]


  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
  ]

  supported_identity_providers = ["COGNITO"]
}

/* The domain name for the user pool */

resource "aws_cognito_user_pool_domain" "lambidrs" {
  domain       = "lambdirs-${local.env}"
  user_pool_id = aws_cognito_user_pool.lambdirs.id
}
