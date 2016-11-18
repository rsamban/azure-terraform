# azure-terraform
Terraform scripts to create prerequisite resources for PCF install

### Requirements
The following software needs to be installed before pcf resources can be created

azure: Install azure cli from "https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-install/"

Terraform: Install from "https://www.terraform.io/intro/getting-started/install.html"

jq: Install from https://stedolan.github.io/jq/

azure-sp-tools: Install from https://stedolan.github.io/jq/

### Usage
   azure-terraform <requirements | setup | showenv | setenv>"

### Note
Set username/password needed for the jumpbox virtual machinne in the azure-terraform.tf script.

