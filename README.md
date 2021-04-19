# bulk-apply-report-config-C1C-Conformity
Apply report configurations across your Conformity accounts in bulk

## Implements
Create Report Config https://github.com/cloudconformity/documentation-api/blob/master/ReportConfigs.md#create-report-config 

## Requires
- A Trend Micro Cloud One(TM) Conformity account   
- Conformity API access (with appropriate permissions) https://www.cloudconformity.com/help/public-api/api-keys.html  
- A shell terminal with jq installed - https://stedolan.github.io/jq/  

## Usage
The script will loop through the defined list of accounts and apply the same report configuration to each account.  
You must define the configuration directly in the script.  
The payload can be modified to accept groupId instead of accountId arguments, if desired.

### Steps:  
1. Edit the script's report configuration payload 
2. Ensure jq is installed and script is executable
3. Do an initial run of the script with no arguments - you will be prompted if you would like to display a list of Conformity accountIds against their account name and AWS account number (to help you identify which accounts are of interest).
4. For your initial run, select not to proceed when prompted or cancel (ctrl + c)
5. Run the script for real with either comma separated list of accountId arguments, or leave blank to apply a config accross all accounts, e.g.  
`$ ./generate-report-config.sh` - apply to all accounts  
`$ ./generate-report-config.sh acbds2347,sdlccn287` - will apply to only the listed accounts  
6. Follow the prompts and confirmation to apply the report configurations
