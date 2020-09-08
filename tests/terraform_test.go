package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestTerraformModules(t *testing.T) {
	t.Parallel()

	// The folder where we have our Terraform code
	workingDir := "../infra/modules"

	// A unique ID we can use to namespace resources so we don't clash with anything already in the AWS account or
	// tests running in parallel
	uniqueID := random.UniqueId()

	// Pick a random AWS region to test in. This helps ensure your code works in all regions.
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	// At the end of the test, undeploy the web app using Terraform
	defer test_structure.RunTestStage(t, "cleanup", func() {
		destroyTerraform(t, workingDir)
	})

	// Stage to Deploy Terraform
	test_structure.RunTestStage(t, "deploy", func() {
		test_structure.SaveString(t, workingDir, savedAwsRegion, awsRegion)
		deployUsingTerraform(t, awsRegion, workingDir, uniqueID)
	})

	// Validate that subnets are public and private
	test_structure.RunTestStage(t, "validate", func() {
		validateVpc(t, workingDir, awsRegion)
	})


	// Validate that the web app deployed and is responding to HTTP requests
	test_structure.RunTestStage(t, "validate", func() {
		validateAlb(t, workingDir, awsRegion, uniqueID)
	})

}


// Deploy the app using Terraform
func deployUsingTerraform(t *testing.T, awsRegion string, workingDir string, uniqueID string) {

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"region":    awsRegion,
			"unique_id": uniqueID,
		},
	}

	// Save the Terraform Options struct, instance name, and instance text so future test stages can use it
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}