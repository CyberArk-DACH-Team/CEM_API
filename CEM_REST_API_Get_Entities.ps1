
$locCEMHeader = $args[0]
$locCEMURL = $args[1]

#
# Get Platform
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
    $varCEMEntitiesResults = Invoke-RestMethod -Uri "$varCEMURL/cloudEntities/api/search" -Method GET -ContentType "application/json" -Headers $CEMHeader

    switch ($targetplatform) {
        0 {
            write-host "`r`nSelected: AWS"
            write-host "-------------"
            $varCEMEntitiesAWSResults = Invoke-RestMethod -Uri "$varCEMURL/cloudEntities/api/search?platform=aws" -Method GET -ContentType "application/json" -Headers $CEMHeader
        }
        1 {
            write-host "`r`nSelected: Azure"
            write-host "-------------"
            $varCEMEntitiesAzureResults = Invoke-RestMethod -Uri "$varCEMURL/cloudEntities/api/search?platform=azure" -Method GET -ContentType "application/json" -Headers $CEMHeader
        }
        2 {
            write-host "`r`nSelected: GCP"
            write-host "-------------"
            $varCEMEntitiesGCPResults = Invoke-RestMethod -Uri "$varCEMURL/cloudEntities/api/search?platform=gcp" -Method GET -ContentType "application/json" -Headers $CEMHeader
        }
        3 {
            write-host "`r`nSelected: EKS"
            write-host "-------------"
            $varCEMEntitiesEKSResults = Invoke-RestMethod -Uri "$varCEMURL/cloudEntities/api/search?platform=eks" -Method GET -ContentType "application/json" -Headers $CEMHeader
        }
        4 {
            write-host "`r`nSelected: All platforms"
            write-host "-------------"
        }    
    }
} catch {
	ParseErrorForResponseBody($_)
} finally {
    if ($targetplatform -eq 0) {
        write-host "Found entities for AWS: " $varCEMEntitiesAWSResults.total
        $varCEMEntitiesAWSResults.hits
    }
    if ($targetplatform -eq 1) {
        write-host "Found entities for Azure: " $varCEMEntitiesAzureResults.total
        $varCEMEntitiesAzureResults.hits
    }
    if ($targetplatform -eq 2) {
        write-host "Found entities for GCP: " $varCEMEntitiesGCPResults.total
        $varCEMEntitiesGCPResults.hits
    }
    if ($targetplatform -eq 3) {
        write-host "Found entities for EKS: " $varCEMEntitiesEKSResults.total
        $varCEMEntitiesEKSResults.hits
    }
    if ($targetplatform -eq 4) {
        write-host "Found entities: " $varCEMEntitiesResults.total
        $varCEMEntitiesResults.hits
    }
}
