aws iam create-role \
--role-name 'PlacesAPILambdaRole' \
--assume-role-policy-document 'file://assume-role-policy-document.json' \
--description 'Allows Lambda functions to call AWS services on your behalf.'
# {
#     "Role": {
#         "AssumeRolePolicyDocument": {
#             "Version": "2012-10-17",
#             "Statement": [
#                 {
#                     "Action": "sts:AssumeRole",
#                     "Effect": "Allow",
#                     "Principal": {
#                         "Service": "lambda.amazonaws.com"
#                     }
#                 }
#             ]
#         },
#         "RoleId": "AROAIDF4KHTQLK7FSY24K",
#         "CreateDate": "2018-08-20T16:47:09Z",
#         "RoleName": "PlacesAPILambdaRole",
#         "Path": "/",
#         "Arn": "arn:aws:iam::161262005667:role/PlacesAPILambdaRole"
#     }
# }

# Attach managed policy AWSLambdaBasicExecutionRole to the Rol
aws iam attach-role-policy \
--policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole \
--role-name PlacesAPILambdaRole

# Create the dynamodb table
./create_table.sh

# Embed inline policy to Role so it can update the databse
aws iam put-role-policy \
--role-name PlacesAPILambdaRole \
--policy-name DynamoDBPolicy \
--policy-document file://dynamodb-inline-policy.json