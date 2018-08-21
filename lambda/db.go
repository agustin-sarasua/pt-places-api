package main

import (
	"fmt"
	"log"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
)

// Declare a new DynamoDB instance. Note that this is safe for concurrent
// use.
var db = dynamodb.New(session.New(), aws.NewConfig().WithRegion("us-east-1"))

func getItems(sub string) ([]Place, error) {
	// Prepare the input for the query.
	input := &dynamodb.QueryInput{
		TableName: aws.String("Places"),
		KeyConditions: map[string]*dynamodb.Condition{
			"Sub": {
				ComparisonOperator: aws.String("EQ"),
				AttributeValueList: []*dynamodb.AttributeValue{
					{
						S: aws.String(sub),
					},
				},
			},
		},
	}
	var resp1, err1 = db.Query(input)
	if err1 != nil {
		fmt.Println(err1)
		return nil, err1
	} else {
		places := []Place{}
		err1 = dynamodbattribute.UnmarshalListOfMaps(resp1.Items, &places)
		if err1 != nil {
			return nil, err1
		}
		log.Println(places)
		return places, nil
	}
}

func getItem(sub string, name string) (*Place, error) {
	// Prepare the input for the query.
	input := &dynamodb.GetItemInput{
		TableName: aws.String("Places"),
		Key: map[string]*dynamodb.AttributeValue{
			"Name": {
				S: aws.String(name),
			},
			"Sub": {
				S: aws.String(sub),
			},
		},
	}

	// Retrieve the item from DynamoDB. If no matching item is found
	// return nil.
	result, err := db.GetItem(input)
	if err != nil {
		return nil, err
	}
	if result.Item == nil {
		return nil, nil
	}

	// The result.Item object returned has the underlying type
	// map[string]*AttributeValue. We can use the UnmarshalMap helper
	// to parse this straight into the fields of a struct. Note:
	// UnmarshalListOfMaps also exists if you are working with multiple
	// items.
	bk := new(Place)
	err = dynamodbattribute.UnmarshalMap(result.Item, bk)
	if err != nil {
		return nil, err
	}

	return bk, nil
}

// Add a record to DynamoDB.
func putItem(e *Place) error {
	input := &dynamodb.PutItemInput{
		TableName: aws.String("Places"),
		Item: map[string]*dynamodb.AttributeValue{
			"name": {
				S: aws.String(e.Name),
			},
			"sub": {
				S: aws.String(e.Sub),
			},
		},
	}

	_, err := db.PutItem(input)
	return err
}
