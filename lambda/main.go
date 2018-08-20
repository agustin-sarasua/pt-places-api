package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/gin-gonic/gin"
	uuid "github.com/satori/go.uuid"
)

var ginLambda *ginadapter.GinLambda

var errorLogger = log.New(os.Stderr, "ERROR ", log.Llongfile)
var infoLogger = log.New(os.Stdout, "INFO ", log.Llongfile)

func getClaimsSub(ctx events.APIGatewayProxyRequestContext) string {
	jc, _ := json.Marshal(ctx.Authorizer)
	r := make(map[string]map[string]interface{})
	err := json.Unmarshal([]byte(jc), &r)
	if err != nil {
		fmt.Printf("Something went wrong %v", err)
	}
	fmt.Printf("Printing sub: %s ", r["claims"]["sub"].(string))
	return r["claims"]["sub"].(string)
}

func createPlace(c *gin.Context) {
	// the methods are available in your instance of the GinLambda
	// object and receive the http.Request object
	// RequestContext
	apiGwContext, _ := ginLambda.GetAPIGatewayContext(c.Request)
	sub := getClaimsSub(apiGwContext)
	// apiGwStageVars, _ := ginLambda.GetAPIGatewayStageVars(c.Request)

	// stage variables are stored in a map[string]string
	// stageVarValue := apiGwStageVars["MyStageVar"]

	newPlace := Place{}
	err := c.BindJSON(&newPlace)

	if newPlace.Name == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"message": "Name not found",
		})
		return
	}

	uid, _ := uuid.NewV4()
	newPlace.ID = uid.String()
	newPlace.Sub = sub

	if err != nil {
		return
	}

	c.JSON(http.StatusAccepted, newPlace)
}

func getPlace(c *gin.Context) {
	pets := make([]Place, 2)
	c.JSON(200, pets)
}

func getPlaces(c *gin.Context) {
	pets := make([]Place, 2)
	c.JSON(200, pets)
}

// Handler is the main entry point for Lambda. Receives a proxy request and
// returns a proxy response
func Handler(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	if ginLambda == nil {
		// stdout and stderr are sent to AWS CloudWatch Logs
		log.Printf("Gin cold start")
		r := gin.Default()
		r.GET("/places", getPlaces)
		r.GET("/places/:placeId", getPlace)
		r.POST("/places", createPlace)

		ginLambda = ginadapter.New(r)
	}

	return ginLambda.Proxy(req)
}

func main() {
	lambda.Start(Handler)
}
