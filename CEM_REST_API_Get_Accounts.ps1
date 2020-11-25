
$locCEMHeader = $args[0]
$locCEMURL = $args[1]

#
# Read Target Username
#
[Int]$targetplatform = 11
do {
    write-host "`r`n-------------------------------"
    write-host "Select your platform:"
    write-host "[0] AWS"
    write-host "[1] Azure"
    write-host "[2] GCP"
    write-host "[3] EKS"
    write-host "[4] All"
    write-host "-------------------------------"
    $targetplatform = Read-Host -Prompt 'Choose your destiny > '
} while ($targetplatform -lt 0 -or $targetplatform -gt 4)
#
# Function to parse the results of a failure after invoking the rest api
#
Function ParseErrorForResponseBody($Error) {
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        if ($Error.Exception.Response) {  
            $Reader = New-Object System.IO.StreamReader($Error.Exception.Response.GetResponseStream())
            $Reader.BaseStream.Position = 0
            $Reader.DiscardBufferedData()
            $ResponseBody = $Reader.ReadToEnd()
            if ($ResponseBody.StartsWith('{')) {
                $ResponseBody = $ResponseBody | ConvertFrom-Json
            }
            return $ResponseBody
        }
    }
    else {
        return $Error.ErrorDetails.Message
    }
}

#
# Get Accounts and display them
#
try {
    #
	#	Get All Accounts
	#
    $varCEMAccountsResults = Invoke-RestMethod -Uri "$varCEMURL/customer/platforms/accounts" -Method GET -ContentType "application/json" -Headers $CEMHeader

    switch ($targetplatform) {
        0 {
            write-host "`r`nSelected: AWS"
            write-host "-------------"
        }
        1 {
            write-host "`r`nSelected: Azure"
            write-host "-------------"
        }
        2 {
            write-host "`r`nSelected: GCP"
            write-host "-------------"
        }
        3 {
            write-host "`r`nSelected: EKS"
            write-host "-------------"
        }
        4 {
            write-host "`r`nSelected: All platforms"
            write-host "-------------"
        }    
    }
} catch {
	ParseErrorForResponseBody($_)
} finally {
    if ($targetplatform -ne 4) {
        write-host "Found accounts: " $varCEMAccountsResults.data[$targetplatform].accounts.count
        $counterAccounts = 0
        if ($varCEMAccountsResults.data[$targetplatform].accounts.count -ne 0) {
            do {
                write-host "---"
                write-host "[$counterAccounts] Account ID: " $varCEMAccountsResults.data[$targetplatform].accounts[$counterAccounts].account_id
                write-host "[$counterAccounts] Account Status: " $varCEMAccountsResults.data[$targetplatform].accounts[$counterAccounts].account_status
                write-host "[$counterAccounts] Account Name: " $varCEMAccountsResults.data[$targetplatform].accounts[$counterAccounts].account_name
                $counterAccounts = $counterAccounts + 1
            } while ($counterAccounts -lt $varCEMAccountsResults.data[$targetplatform].accounts.count)
        }
    }
    elseif ($targetplatform -eq 4) {
        $counterplatformAWS = $varCEMAccountsResults.data[0].accounts.Count
        $counterplatformAzure = $varCEMAccountsResults.data[1].accounts.count
        $counterplatformGCP = $varCEMAccountsResults.data[2].accounts.count
        $counterplatformEKS = $varCEMAccountsResults.data[3].accounts.count
        $counterAccounts = 0
        write-host "`r`nFound accounts for AWS: " $varCEMAccountsResults.data[0].accounts.Count
        if ($counterplatformAWS -ne 0) {
            do {
                write-host "---"
                write-host "[$counterAccounts] Account ID: " $varCEMAccountsResults.data[0].accounts[$counterAccounts].account_id
                write-host "[$counterAccounts] Account Status: " $varCEMAccountsResults.data[0].accounts[$counterAccounts].account_status
                write-host "[$counterAccounts] Account Name: " $varCEMAccountsResults.data[0].accounts[$counterAccounts].account_name
                $counterAccounts = $counterAccounts + 1
            } while ($counterAccounts -lt $varCEMAccountsResults.data[0].accounts.count)
        }
        $counterAccounts = 0
        write-host "`r`nFound accounts for Azure: " $varCEMAccountsResults.data[1].accounts.Count
        if ($counterplatformAzure -ne 0) {
            do {
                write-host "---"
                write-host "[$counterAccounts] Account ID: " $varCEMAccountsResults.data[1].accounts[$counterAccounts].account_id
                write-host "[$counterAccounts] Account Status: " $varCEMAccountsResults.data[1].accounts[$counterAccounts].account_status
                write-host "[$counterAccounts] Account Name: " $varCEMAccountsResults.data[1].accounts[$counterAccounts].account_name
                $counterAccounts = $counterAccounts + 1
            } while ($counterAccounts -lt $varCEMAccountsResults.data[1].accounts.count)
        }
        $counterAccounts = 0
        write-host "`r`nFound accounts for GCP: " $varCEMAccountsResults.data[2].accounts.Count
        if ($counterplatformGCP -ne 0) {
            do {
                write-host "---"
                write-host "[$counterAccounts] Account ID: " $varCEMAccountsResults.data[2].accounts[$counterAccounts].account_id
                write-host "[$counterAccounts] Account Status: " $varCEMAccountsResults.data[2].accounts[$counterAccounts].account_status
                write-host "[$counterAccounts] Account Name: " $varCEMAccountsResults.data[2].accounts[$counterAccounts].account_name
                $counterAccounts = $counterAccounts + 1
            } while ($counterAccounts -lt $varCEMAccountsResults.data[2].accounts.count)
        }
        $counterAccounts = 0
        write-host "`r`nFound accounts for EKS: " $varCEMAccountsResults.data[3].accounts.Count
        if ($counterplatformEKS -ne 0) {
            do {
                write-host "---"
                write-host "[$counterAccounts] Account ID: " $varCEMAccountsResults.data[3].accounts[$counterAccounts].account_id
                write-host "[$counterAccounts] Account Status: " $varCEMAccountsResults.data[3].accounts[$counterAccounts].account_status
                write-host "[$counterAccounts] Account Name: " $varCEMAccountsResults.data[3].accounts[$counterAccounts].account_name
                $counterAccounts = $counterAccounts + 1
            } while ($counterAccounts -lt $varCEMAccountsResults.data[3].accounts.count)
        }
    }
}
