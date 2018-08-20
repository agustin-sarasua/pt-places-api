####################################################################
# Create the Rest API
####################################################################

aws apigateway create-rest-api --name 'Places API' --region us-east-1
# {
#     "apiKeySource": "HEADER",
#     "name": "Places API",
#     "createdDate": 1534443255,
#     "endpointConfiguration": {
#         "types": [
#             "EDGE"
#         ]
#     },
#     "id": "22e4ux5fed"
# }

####################################################################
# Create the Resources
####################################################################

aws apigateway get-resources --rest-api-id 22e4ux5fed --region us-east-1
# {
#     "items": [
#         {
#             "path": "/",
#             "id": "reahfnbguh"
#         }
#     ]
# }

# Create resource /places
aws apigateway create-resource --rest-api-id 22e4ux5fed \
      --region us-east-1 \
      --parent-id reahfnbguh \
      --path-part places
# {
#     "path": "/places",
#     "pathPart": "places",
#     "id": "mnhrio",
#     "parentId": "reahfnbguh"
# }

# Create resource /places/{placeId}
aws apigateway create-resource --rest-api-id 22e4ux5fed \
      --region us-east-1 \
      --parent-id mnhrio \
      --path-part '{placeId}'
# {
#     "path": "/places/{placeId}",
#     "pathPart": "{placeId}",
#     "id": "9fq64m",
#     "parentId": "mnhrio"
# }

####################################################################
# Create Authorizer for the endpoints (cognito user pool)
####################################################################

# Create Authorizer (AUTH)
aws apigateway create-authorizer --rest-api-id 22e4ux5fed \
        --name 'Places_API_Authorizer' \
        --type COGNITO_USER_POOLS \
        --provider-arns 'arn:aws:cognito-idp:us-east-1:161262005667:userpool/us-east-1_3IwH7mpoM' \
        --identity-source 'method.request.header.Authorization' \
        --authorizer-result-ttl-in-seconds 300
# {
#     "authType": "cognito_user_pools",
#     "identitySource": "method.request.header.Authorization",
#     "name": "Places_API_Authorizer",
#     "providerARNs": [
#         "arn:aws:cognito-idp:us-east-1:161262005667:userpool/us-east-1_3IwH7mpoM"
#     ],
#     "type": "COGNITO_USER_POOLS",
#     "id": "3tdsp6"
# }

# Get AUTHORIZERS
aws apigateway get-authorizers --rest-api-id 22e4ux5fed

####################################################################
# Create Method Request and enable responses on Resources
####################################################################

# Enable GET (AUTH) for /places
aws apigateway put-method --rest-api-id 22e4ux5fed \
       --resource-id mnhrio \
       --http-method GET \
       --authorization-type COGNITO_USER_POOLS \
       --authorizer-id 3tdsp6 \
       --region us-east-1
# {
#     "apiKeyRequired": false,
#     "httpMethod": "GET",
#     "authorizationType": "COGNITO_USER_POOLS",
#     "authorizerId": "3tdsp6"
# }

# Enable GET (AUTH) for /places/{placeId}
aws apigateway put-method --rest-api-id 22e4ux5fed \
       --resource-id 9fq64m --http-method GET \
       --authorization-type COGNITO_USER_POOLS \
       --authorizer-id 3tdsp6 \
       --region us-east-1 \
       --request-parameters method.request.path.placeId=true
# {
#     "apiKeyRequired": false,
#     "httpMethod": "GET",
#     "requestParameters": {
#         "method.request.path.placeId": true
#     },
#     "authorizationType": "COGNITO_USER_POOLS",
#     "authorizerId": "3tdsp6"
# }

# Enable 200 OK to /places
aws apigateway put-method-response --rest-api-id 22e4ux5fed \
       --resource-id mnhrio --http-method GET \
       --status-code 200  --region us-east-1
# {
#     "statusCode": "200"
# }

# Enable 200 OK to /places/{placeId}
aws apigateway put-method-response --rest-api-id 22e4ux5fed \
       --resource-id 9fq64m --http-method GET \
       --status-code 200  --region us-east-1
# {
#     "statusCode": "200"
# }


####################################################################
# Now Integrate with the Backend
# NOTE: Create the backend Lambda
####################################################################
# Create Rol for the lambda function
./create_rol.sh

# Create the lambda
./create_lambda.sh
# {
#     "TracingConfig": {
#         "Mode": "PassThrough"
#     },
#     "CodeSha256": "O8ujoNdILyEpBLaizG9FGed0XaUxZI0NRNNA1mylaYw=",
#     "FunctionName": "places-api",
#     "CodeSize": 5587279,
#     "RevisionId": "b7482a83-5a59-4cb4-ba91-d64a10646b6d",
#     "MemorySize": 128,
#     "FunctionArn": "arn:aws:lambda:us-east-1:161262005667:function:places-api",
#     "Version": "$LATEST",
#     "Role": "arn:aws:iam::161262005667:role/PeopleTrackingLambda",
#     "Timeout": 3,
#     "LastModified": "2018-08-18T13:19:51.856+0000",
#     "Handler": "main",
#     "Runtime": "go1.x",
#     "Description": ""
# }

# Integrate GET /places with Lambda function
aws apigateway put-integration --rest-api-id 22e4ux5fed \
        --resource-id mnhrio \
        --http-method GET \
        --type AWS_PROXY \
        --integration-http-method POST \
        --region us-east-1 \
        --uri 'arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:161262005667:function:places-api/invocations'
# {
#     "passthroughBehavior": "WHEN_NO_MATCH",
#     "timeoutInMillis": 29000,
#     "uri": "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:161262005667:function:places-api/invocations",
#     "httpMethod": "POST",
#     "cacheNamespace": "mnhrio",
#     "type": "AWS_PROXY",
#     "cacheKeyParameters": []
# }

# Integrate GET /places/{placeId} with Lambda function
aws apigateway put-integration --rest-api-id 22e4ux5fed \
        --resource-id 9fq64m \
        --http-method GET \
        --type AWS_PROXY \
        --integration-http-method POST \
        --region us-east-1 \
        --uri 'arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:161262005667:function:places-api/invocations'

# {
#     "passthroughBehavior": "WHEN_NO_MATCH",
#     "timeoutInMillis": 29000,
#     "uri": "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:161262005667:function:places-api/invocations",
#     "httpMethod": "POST",
#     "cacheNamespace": "9fq64m",
#     "type": "AWS_PROXY",
#     "cacheKeyParameters": []
# }  

#### NOTE
# Retrive previous integration
aws apigateway get-integration --rest-api-id 22e4ux5fed --resource-id 9fq64m --http-method GET

# Create Integration Response for /places
aws apigateway put-integration-response --rest-api-id 22e4ux5fed \
       --resource-id mnhrio --http-method GET \
       --status-code 200 --selection-pattern ""  \
       --region us-east-1
# {
#     "selectionPattern": "",
#     "statusCode": "200"
# }

# Create Integration Response for /places/{placeId}
aws apigateway put-integration-response --rest-api-id 22e4ux5fed \
       --resource-id 9fq64m --http-method GET \
       --status-code 200 --selection-pattern ""  \
       --region us-east-1
# {
#     "selectionPattern": "",
#     "statusCode": "200"
# }

# Add Execution Permision API - Lambda to /places
aws lambda add-permission \
--function-name places-api \
--statement-id 'places_allow_permission' \
--action lambda:InvokeFunction \
--principal apigateway.amazonaws.com \
--source-arn 'arn:aws:execute-api:us-east-1:161262005667:22e4ux5fed/*/*/places' \
--region us-east-1
# {
#     "Statement": "{\"Sid\":\"6bac57d3-79b7-4def-b4cf-5255dbd80f5b\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"apigateway.amazonaws.com\"},\"Action\":\"lambda:InvokeFunction\",\"Resource\":\"arn:aws:lambda:us-east-1:161262005667:function:places-api\",\"Condition\":{\"ArnLike\":{\"AWS:SourceArn\":\"arn:aws:execute-api:us-east-1:161262005667:22e4ux5fed/*/POST/places\"}}}"
# }

####################################################################
# Deploy de API to stage
# NOTE: Create the backend Lambda
####################################################################

aws apigateway create-deployment --rest-api-id 22e4ux5fed \
       --region us-east-1 \
       --stage-name test \
       --stage-description 'Test stage' \
       --description 'First deployment'
# {
#     "description": "First deployment",
#     "id": "o2vbql",
#     "createdDate": 1534607154
# }

