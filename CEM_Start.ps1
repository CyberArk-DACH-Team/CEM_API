cls
write-host '                   ______      __              ___         __  
                  / ____/_  __/ /_  ___  _____/   |  _____/ /__Æ
                 / /   / / / / __ \/ _ \/ ___/ /| | / ___/ //_/
                / /___/ /_/ / /_/ /  __/ /  / ___ |/ /  / ,<   
                \____/\___ /_____/\___/_/  /_/  |_/_/  /_/|_|  
                      ____/' -ForegroundColor blue
write-host "#################################################################################"-ForegroundColor blue
write-host -nonewline -f blue "# ";write-host -nonewline "  Example of using the CyberArk CEM SaaS REST-API with Powershell >= v3      ";write-host -f blue "#"
write-host -nonewline -f blue "# ";write-host -nonewline "  Sample by CyberArk - feel free to adopt                                    ";write-host -f blue "#"
write-host -nonewline -f blue "# ";write-host -nonewline "  v1.0 (modified by Fabian Hotarek)                                          ";write-host -f blue "#"
write-host "#################################################################################"-ForegroundColor blue

#
# Define variables
#
[Int]$selection = 0
$varCEMURL="https://api.cem.cyberark.com"
$varCEMOrg = "cybr-dach" ## Put in your Org-Name here
$varCEMAccessKey = "" ## Put in your CEM API Key here

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
# Function to show the Start Menu
#
function ShowStartMenu(){
    write-host "-------------------------------"
    write-host "Start Menu:"
    write-host "[1] Get Entities"
    write-host "[2] Get Entity Details"
    write-host "[3] Get Entity Recommendations"
    write-host "[4] Get Entity Remediations"
    write-host "[5] Get Accounts"
    write-host "[99] Exit"
    write-host "-------------------------------"
    [Int]$userSelection = Read-Host -Prompt 'What do you want to do? > '
    write-host "`r`n"
    return $userSelection
}


#
# Main Run
#
try {
    write-host "`r`nWelcome to some CEM SaaS API samples`r`n"
    $LogonBody = @{organization = $varCEMOrg; accessKey = $varCEMAccessKey} | ConvertTo-JSON

    #
    # Attempt to login
    #
    try {
	    $varCEMLogonResult = Invoke-RestMethod -Uri "$varCEMURL/apis/login" -Method Post -ContentType "application/json" -Body $LogonBody
        
        #
	    # Build the header to get the sets for this user
        #
        $FullToken = "Bearer " + $varCEMLogonResult.token
        $CEMHeader = @{}
	    $CEMHeader.Add("Authorization", $FullToken)
        
        #
        # Selected Action and Run corresponding Script
        #
        do {
            $selection = ShowStartMenu
            if ($selection -gt 0) {
                if ($selection -lt 6) {
                    switch ($selection) {
                        1 { 
                            write-host "------------------"
                            write-host "   Get Entities   "
                            write-host "------------------" 
                            & $PSScriptRoot\CEM_REST_API_GET_Entities.ps1 $CEMHeader $CEMURL
                        }
                        2 { 
                            write-host "-----------------------------"
                            write-host "   Get Details from Entity   "
                            write-host "-----------------------------"
                            & $PSScriptRoot\CEM_REST_API_GET_Entity_Details.ps1 $CEMHeader $CEMURL
                        }
                        3 { 
                            write-host "-------------------------"
                            write-host "   Get Entity Recommendations   "
                            write-host "-------------------------" 
                            & $PSScriptRoot\CEM_REST_API_GET_Entity_Recommendations.ps1 $CEMHeader $CEMURL
                        }
                        4 { 
                            write-host "-------------------------------------"
                            write-host "   Get Remediations for Entity   "
                            write-host "-------------------------------------"
                            & $PSScriptRoot\CEM_REST_API_GET_Entity_Recommendations.ps1 $CEMHeader $CEMURL
                        }
                        5 { 
                            write-host "------------------"
                            write-host "   Get Accounts   "
                            write-host "------------------"
                            & $PSScriptRoot\CEM_REST_API_GET_Accounts.ps1 $CEMHeader $CEMURL
                        } 
                    }
                }
                elseif ($selection -eq 99) {
                    write-host "`r`nHope you enjoyed some CEM REST-API samples."
                    write-host "See ya soon."
                    exit 0
                }
                else {
                    write-host "`r`n--- !!! ---"
                    write-host "Input invalid. Please start again."
                    write-host "--- !!! ---`r`n"
                }
            }
            else {
                write-host "`r`n--- !!! ---"
                write-host "Input invalid. Please start again."
                write-host "--- !!! ---`r`n"
            }
        } while($selection -ne 99)
    }
    catch{
        ParseErrorForResponseBody($_)
    }
}
catch{
    ParseErrorForResponseBody($_)
}
