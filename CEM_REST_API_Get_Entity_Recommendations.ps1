
$locCEMHeader = $args[0]
$locCEMURL = $args[1]

#
# Read Target Username
#
[Int]$targetplatform = 44
do {
    write-host "`r`n-------------------------------"
    write-host "Select your platform:"
    write-host "[0] AWS"
    write-host "[1] Azure"
    write-host "[2] GCP"
    write-host "[3] EKS"
    write-host "-------------------------------"
    $targetplatform = Read-Host -Prompt 'Choose your destiny > '
} while ($targetplatform -lt 0 -or $targetplatform -gt 3)
#
# Get needed parameters
#
[Int]$varAccountIDChoice = 100
do {
    write-host "`r`n-------------------------------"
    write-host "Do you know your connected account id?"
    write-host "[0] Yes"
    write-host "[1] No"
    write-host "------------------------------"
    $varAccountIDChoice = Read-Host -Prompt ' Answer > '

    if ($varAccountIDChoice -eq 0) {
        $varAccountID = Read-Host -Prompt 'Type in or Copy/Paste your platform Id > '
    }
    elseif($varAccountIDChoice -eq 1) {
        write-host "Run Get Accounts first"
        exit 0
    }
    else {
        write-host "Choice not available! Please try again"
    }
} while ($varAccountIDChoice -ne 0 -and $varAccountIDChoice -ne 1)

#
# Get needed parameters
#
[Int]$varEntityIDChoice = 100
do {
    write-host "`r`n-------------------------------"
    write-host "Do you know your entity id?"
    write-host "[0] Yes"
    write-host "[1] No"
    write-host "------------------------------"
    $varEntityIDChoice = Read-Host -Prompt ' Answer > '

    if ($varEntityIDChoice -eq 0) {
        $varEntityID = Read-Host -Prompt 'Type in or Copy/Paste your entity Id > '
    }
    elseif($varEntityIDChoice -eq 1) {
        write-host "Run Get Entities first"
        exit 0
    }
    else {
        write-host "Choice not available! Please try again"
    }
} while ($varEntityIDChoice -ne 0 -and $varEntityIDChoice -ne 1)

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

$varCEMEntityRecommendations = ""
#
# Get Entity Details
#
try {
    #
	# Get Entity Details
	#
    
    switch ($targetplatform) {
        0 {
            write-host "`r`nSelected: AWS"
            write-host "-------------"
            $varCEMEntityRecommendations= Invoke-RestMethod -Uri "$varCEMURL/recommendations/api/metadata?platform=aws&account_id=$varAccountID&entity_id=$varEntityID" -Method GET -ContentType "application/json" -Headers $CEMHeader
            write-host "Entity Details: "
            write-host "----------------"
        }
        1 {
            write-host "`r`nSelected: Azure"
            write-host "-------------"
            $varCEMEntityRecommendations = Invoke-RestMethod -Uri "$varCEMURL/recommendations/api/metadata?platform=azure&account_id=$varAccountID&entity_id=$varEntityID" -Method GET -ContentType "application/json" -Headers $CEMHeader
            write-host "Entity Details: "
            write-host "----------------"
        }
        2 {
            write-host "`r`nSelected: GCP"
            write-host "-------------"
            $varCEMEntityRecommendations = Invoke-RestMethod -Uri "$varCEMURL/recommendations/api/metadata?platform=gcp&account_id=$varAccountID&entity_id=$varEntityID" -Method GET -ContentType "application/json" -Headers $CEMHeader
            write-host "Entity Details: "
            write-host "----------------"
        }
        3 {
            write-host "`r`nSelected: EKS"
            write-host "-------------"
            $varCEMEntityRecommendations = Invoke-RestMethod -Uri "$varCEMURL/recommendations/api/metadata?platform=eks&account_id=$varAccountID&entity_id=$varEntityID" -Method GET -ContentType "application/json" -Headers $CEMHeader
            write-host "Entity Details: "
            write-host "----------------"
        }
    }
} catch {
	ParseErrorForResponseBody($_)
} finally {
    Write-Host "`r`nPlatform: " $varCEMEntityRecommendations.platform
    Write-Host "Account ID: " $varCEMEntityRecommendations.account_id
    Write-Host "Entity ID: " $varCEMEntityRecommendations.entity_id
    if ($varCEMEntityRecommendations.recommendations.Count -ne 0) {
        Write-Host ">> Recommendation: " $varCEMEntityRecommendations.recommendations.active_recommendations
        Write-Host ">> Recommendation Status: " $varCEMEntityRecommendations.recommendations.status
        Write-Host ">> Recommendation Created Time: " $varCEMEntityRecommendations.recommendations.created_date
    }
}