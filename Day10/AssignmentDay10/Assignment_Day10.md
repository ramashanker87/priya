Assignment:
============================================================================

    Create three EC2 multienvironment dev test prod
    example: rama-dev-web-server,rama-test-web-server,rama-prod-web-server

    Each of EC2 should have web server installed and have index.html

    When access dev it should display
        Welcome to Dev server
    Similarly for test and prod
    Make sure its accessible through http IP address.
===============================================================================
# Validate the stack:
aws cloudformation validate-template \
--template-body file://day10-assignment-priya-stack.yaml \
--profile devops

# dev:
    aws cloudformation create-stack \
    --stack-name priya-dev-ec2-web-stack \
    --template-body file://day10-assignment-priya-stack.yaml \
    --parameters \
      ParameterKey=KeyName,ParameterValue=priya-ec2 \
      ParameterKey=Environment,ParameterValue=dev \
    --capabilities CAPABILITY_NAMED_IAM --profile devops

# stg:
    aws cloudformation create-stack \
    --stack-name priya-stg-ec2-web-stack \
    --template-body file://day10-assignment-priya-stack.yaml \
    --parameters \
      ParameterKey=KeyName,ParameterValue=priya-ec2 \
      ParameterKey=Environment,ParameterValue=stg \
    --capabilities CAPABILITY_NAMED_IAM --profile devops

# prod:
    aws cloudformation create-stack \
    --stack-name priya-prod-ec2-web-stack \
    --template-body file://day10-assignment-priya-stack.yaml \
    --parameters \
      ParameterKey=KeyName,ParameterValue=priya-ec2 \
      ParameterKey=Environment,ParameterValue=prod \
    --capabilities CAPABILITY_NAMED_IAM --profile devops





