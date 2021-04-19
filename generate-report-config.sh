#!/bin/bash
# This is a sample script for creating new report confirgurations in TM C1 Conformity

echo "Which region is your Conformity environment hosted in?"
read -r region

echo "Enter your api key: "
read -r apikey

# function to display a list of accounts with their Conformity ID and AWS account numbers
display_accounts () {
    echo "List of possible accounts: "
    curl -L -X GET \
        "https://$region-api.cloudconformity.com/v1/accounts" \
        -H "Content-Type: application/vnd.api+json" \
        -H "Authorization: ApiKey $apikey" \
    | jq -r '.data[] | {"Account-Name": .attributes | .["name"], "Conformity-ID" : .id, "AWSAccount" : .attributes | .["awsaccount-id"]} | keys_unsorted, map(.) | @csv' | awk 'NR==1 || NR%2==0'
    echo
    echo "you can re-run the script using the ConformityIDs as a comma-separated list of arguments"
}

# Prompt user whether they would like to see a list of accounts first?
read -r -p "Do you wish to display a list of possible accounts in your environment? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        display_accounts
        ;;
    *)
        echo "proceeding..."
        ;;
esac

# arguments are used to select which Conformity accounts to run against
# if no arguments set, run against entire set of accounts
if [ "$#" -eq  "0" ]
then
    echo "No accountid arguments specified, generating report across all accounts loaded in conformity"
    export accountid=(`curl -L -X GET \
        "https://$region-api.cloudconformity.com/v1/accounts" \
        -H "Content-Type: application/vnd.api+json" \
        -H "Authorization: ApiKey $apikey" \
        | jq -r '.data | map(.id) | join(" ")'`)

else #run against only specified accountids in argument
    export arguments=$1
    IFS=',' read -r -a accountid <<< "$arguments"
fi
echo
echo "The new report configuration will be applied to the following accounts:"
    for i in "${accountid[@]}"
    do
        echo "[ $i ]"
    done
echo
read -n 1 -s -r -p "press any key"
echo

# !!! EDIT HERE to update the report configuration according to: 
# https://github.com/cloudconformity/documentation-api/blob/master/ReportConfigs.md#create-report-config 
generate-report-config () {
    curl -X POST \
    -H "Content-Type: application/vnd.api+json" \
    -H "Authorization: ApiKey $apikey" \
    -d '
    {
        "data": 
        {
            "type": "report-config",
            "attributes": {
                "accountId" : "'"$CC_ACCOUNTID"'",
                "type": "report-config",
                "configuration": {
                    "title": "Example Report - API XXXIII",
                    "scheduled": true,
                    "includeChecks": true,
                    "frequency": "* * 1",
                    "tz": "US/Central",
                    "sendEmail": true,
                    "shouldEmailIncludePdf": true,
                    "shouldEmailIncludeCsv": true,
                    "emails": [
                        "email.mcemailface@email.com"
                    ],
                    "filter": {
                        "statuses": [
                            "FAILURE"
                        ],
                        "createdDate": 0,
                        "newerThanDays": 7,
                        "withChecks": true,
                        "withoutChecks": true
                    },
                    "generateReportType": "GENERIC"
                }
            }
        }
    }' \
    https://$region-api.cloudconformity.com/v1/report-configs
}

echo "the new report configurations is as follows: "
type generate-report-config | sed '1,4d; $d'
echo

# Confirm response
read -r -p "Would you like to proceed? (y/N) " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        for i in "${accountid[@]}"
            do
                CC_ACCOUNTID=$i
                echo "generating report config for $i..."
                generate-report-config
            done
        ;;
    *)
        echo "cancelling..."
        ;;
esac