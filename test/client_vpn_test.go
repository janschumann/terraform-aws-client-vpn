package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

type vpcOutput struct {
	VpcId                     string
	SubnetIdsThis             []string
	SubnetIdsThisDuplicateAz  []string
	SubnetIdsOther            []string
	SubnetIdsOtherDuplicateAz []string
}

type fixture struct {
	T       *testing.T
	Options *terraform.Options
	Output  vpcOutput
}

var vpcFixture = &fixture{
	Options: &terraform.Options{
		TerraformDir: "./fixtures/vpc",
	},
}

func TestMain(m *testing.M) {
	retCode := m.Run()

	terraform.Destroy(vpcFixture.T, vpcFixture.Options)

	os.Exit(retCode)
}

func TestPrepare(t *testing.T) {
	vpcFixture.T = t

	terraform.InitAndApply(vpcFixture.T, vpcFixture.Options)

	vpcFixture.Output = vpcOutput{
		VpcId:                     terraform.Output(vpcFixture.T, vpcFixture.Options, "vpc_id_this"),
		SubnetIdsThis:             terraform.OutputList(vpcFixture.T, vpcFixture.Options, "subnet_ids_this"),
		SubnetIdsThisDuplicateAz:  terraform.OutputList(vpcFixture.T, vpcFixture.Options, "subnet_ids_this_duplicate_az"),
		SubnetIdsOther:            terraform.OutputList(vpcFixture.T, vpcFixture.Options, "subnet_ids_other"),
		SubnetIdsOtherDuplicateAz: terraform.OutputList(vpcFixture.T, vpcFixture.Options, "subnet_ids_other_duplicate_az"),
	}
}

func TestFailsEmptySubnets(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"name":                    "testvpn",
			"vpc_id":                  vpcFixture.Output.VpcId,
			"subnet_ids":              make([]string, 0),
			"server_certificate_name": "vpn-server-prod",
			"client_certificate_name": "vpn.af-prod.rocknitive.com",
			"client_cidr":             "10.100.200.0/22",
		},
	}
	terraform.InitAndApply(t, terraformOptions)

	assert.Fail(t, "foo")
	terraform.Destroy(t, terraformOptions)
}

func TestFailsUnknownTransport(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic",
		Vars: map[string]interface{}{
			"name":                    "testvpn",
			"vpc_id":                  vpcFixture.Output.VpcId,
			"subnet_ids":              vpcFixture.Output.SubnetIdsThis,
			"server_certificate_name": "vpn-server-prod",
			"client_certificate_name": "vpn.af-prod.rocknitive.com",
			"client_cidr":             "10.100.200.0/22",
			"transport_type":          "http",
		},
	}
	terraform.InitAndApply(t, terraformOptions)

	assert.Fail(t, "foo")
	terraform.Destroy(t, terraformOptions)
}

/*
 * These tests keep retrying. They should fail fast, to report errors, so commented out for now

func TestMultipleSubnetsFromSingleAz(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic",
		RetryableTerraformErrors: make(map[string]string),
		Vars: map[string]interface{}{
			"name":                    "testvpn",
			"vpc_id":                  vpcFixture.Output.VpcId,
			"subnet_ids":              append(vpcFixture.Output.SubnetIdsThis[:1], vpcFixture.Output.SubnetIdsThisDuplicateAz...),
			"server_certificate_name": "vpn-server-prod",
			"client_certificate_name": "vpn.af-prod.rocknitive.com",
			"client_cidr":             "10.100.200.0/22",
		},
	}
	_, err := terraform.InitAndApplyE(t, terraformOptions)
	if err != nil {
		assert.Fail(t, "foo")
	}
	assert.Fail(t, "foo")
	terraform.Destroy(t, terraformOptions)
}

func TestSubnetsFromMultipleVpcs(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic",
		RetryableTerraformErrors: make(map[string]string),
		Vars: map[string]interface{}{
			"name":                    "testvpn",
			"vpc_id":                  vpcFixture.Output.VpcId,
			"subnet_ids":              append(vpcFixture.Output.SubnetIdsThis[:1], vpcFixture.Output.SubnetIdsOther[:1]...),
			"server_certificate_name": "vpn-server-prod",
			"client_certificate_name": "vpn.af-prod.rocknitive.com",
			"client_cidr":             "10.100.200.0/22",
		},
	}
	_, err := terraform.InitAndApplyE(t, terraformOptions)
	if err != nil {
		assert.Fail(t, "foo")
	}
	assert.Fail(t, "foo")
	terraform.Destroy(t, terraformOptions)
}

func TestSubnetsFromDifferentVpc(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic",
		RetryableTerraformErrors: make(map[string]string),
		Vars: map[string]interface{}{
			"name":                    "testvpn",
			"vpc_id":                  vpcFixture.Output.VpcId,
			"subnet_ids":              vpcFixture.Output.SubnetIdsOther[:1],
			"server_certificate_name": "vpn-server-prod",
			"client_certificate_name": "vpn.af-prod.rocknitive.com",
			"client_cidr":             "10.100.200.0/22",
		},
	}
	_, err := terraform.InitAndApplyE(t, terraformOptions)
	if err != nil {
		assert.Fail(t, "foo")
	}
	assert.Fail(t, "foo")
	terraform.Destroy(t, terraformOptions)
}
*/
