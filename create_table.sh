aws dynamodb create-table --cli-input-json file://create_palces_table.json --region us-east-1
# {
#     "TableDescription": {
#         "TableArn": "arn:aws:dynamodb:us-east-1:161262005667:table/Places",
#         "AttributeDefinitions": [
#             {
#                 "AttributeName": "Name",
#                 "AttributeType": "S"
#             },
#             {
#                 "AttributeName": "Sub",
#                 "AttributeType": "S"
#             }
#         ],
#         "ProvisionedThroughput": {
#             "NumberOfDecreasesToday": 0,
#             "WriteCapacityUnits": 5,
#             "ReadCapacityUnits": 5
#         },
#         "TableSizeBytes": 0,
#         "TableName": "Places",
#         "TableStatus": "CREATING",
#         "TableId": "4fc619b4-285e-4a9c-ab22-82c73cf954a2",
#         "KeySchema": [
#             {
#                 "KeyType": "HASH",
#                 "AttributeName": "Sub"
#             },
#             {
#                 "KeyType": "RANGE",
#                 "AttributeName": "Name"
#             }
#         ],
#         "ItemCount": 0,
#         "CreationDateTime": 1534860109.297
#     }
# }