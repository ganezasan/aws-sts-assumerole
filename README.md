# aws-sts-assumerole

This example creates iam user and S3 bucket and iam role which is assumable and it has read and write access to the s3 bucket.
The iam user doesn't have any permission, but it can assume the iam role.

# Set up

1. install the following tools 
- aws cli 
- terraform 

2. configure aws default profile which has permission to create a iam user and s3 bucket and iam role.

```
$ aws configure
```

# Apply

```
terraform init
terraform plan
terraform apply
```

# Test

Test whether the iam user can call the assumerole and generate a temp credential which has a permission to access to the S3 bucket.

1. generate a new AccessKey of `taka_assume_role_bucket_executor` on [AWS console](https://console.aws.amazon.com/iamv2/home#/users)
2. add a new aws profile

```
aws --profile executor configure
```

3. call the assumerole and generate a temp credential

```
aws --profile executor sts assume-role --role-arn arn:aws:iam::123456789012:role/taka_assume_role_bucket_maintainer --role-session-name "RoleSession1" > assume-role-output.txt
cat assume-role-output.txt

{
    "AssumedRoleUser": {
        "AssumedRoleId": "XXXXXXXXXXXXXXXXXXXXX:RoleSession1",
        "Arn": "arn:aws:sts::123456789012:assumed-role/taka_assume_role_bucket_maintainer/RoleSession1"
    },
    "Credentials": {
        "SecretAccessKey": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXx",
        "SessionToken": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=",
        "Expiration": "2021-11-17T07:50:54Z",
        "AccessKeyId": "XXXXXXXXXXXXXXXXXXX"
    }
}
```

4. create a new aws profile

```
aws --profile temp configure
aws --profile temp configure set aws_session_token <SessionToken>

# check permission
aws --profile temp sts get-caller-identity

{
    "Account": "123456789012",
    "UserId": "XXXXXXXXXXXXXXXXXXXXX:RoleSession1",
    "Arn": "arn:aws:sts::123456789012:assumed-role/taka_assume_role_bucket_maintainer/RoleSession1"
}
```

5. upload file to the s3 bucket and list

```
touch foobar
aws --profile temp s3 cp foobar s3://taka-assume-role-test
aws --profile temp s3 ls s3://taka-assume-role-test
```
