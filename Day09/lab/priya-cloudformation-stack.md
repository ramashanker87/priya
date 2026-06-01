## Command to create cloudformation

    aws cloudformation create-stack \
    --stack-name priya-ec2-stack \
    --template-body file://priya-ec2-template.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile devops

## Delete cloudformation command

    aws cloudformation delete-stack \
    --stack-name priya-ec2-stack \
    --profile devops

## Command to create cloudformation for EC2 Web Server

    aws cloudformation create-stack \
    --stack-name priya-ec2-web-stack \
    --template-body file://ec2-web-server-template.yaml \
    --parameters \
      ParameterKey=KeyName,ParameterValue=priya-ec2 \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile devops

    Delete

    aws cloudformation delete-stack \
    --stack-name priya-ec2-web-stack \
    --profile devops


## Command to create cloudformation for S3 Bucket

    aws cloudformation create-stack \
    --stack-name priya-s3-stack \
    --template-body file://priya-s3-template.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile devops

    Delete

    aws cloudformation delete-stack \
    --stack-name priya-s3-stack \
    --profile devops