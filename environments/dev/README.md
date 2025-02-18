```
aws s3api create-bucket --bucket terraform-state-bucket --region us-east-1 --create-bucket-configuration LocationConstraint=us-east-1
```
```
aws s3api put-bucket-versioning --bucket terraform-state-bucket --versioning-configuration Status=Enabled
```
```
aws dynamodb create-table --table-name terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
```

```
cat <<EOF > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:sub": "repo:your-org/your-repo:ref:refs/heads/main"
        }
      }
    }
  ]
}
EOF
```
```
aws iam create-role --role-name GitHubOIDC-Terraform --assume-role-policy-document file://trust-policy.json

```

```
cat <<EOF > terraform-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::my-terraform-state-bucket",
        "arn:aws:s3:::my-terraform-state-bucket/dev/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/terraform-lock"
    }
  ]
}
EOF

```

```
aws iam create-policy --policy-name TerraformS3StatePolicy --policy-document file://terraform-policy.json
```

```
aws iam list-policies --query "Policies[?PolicyName=='TerraformS3StatePolicy'].Arn" --output text
```

```
aws iam attach-role-policy --role-name GitHubOIDC-Terraform --policy-arn arn:aws:iam::123456789012:policy/TerraformS3StatePolicy
```
