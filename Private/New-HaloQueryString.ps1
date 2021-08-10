function New-HaloQueryString {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True
        )]
        [String]$CommandName,
        [Parameter(
            Mandatory = $True
        )]
        [Hashtable]$Parameters,
        [Switch]$IsMulti
    )
    Write-Verbose "Building parameters for $($CommandName). Use '-Debug' with '-Verbose' to see parameter values as they are built."
    $QSCollection = [Hashtable]@{}
    foreach ($Parameter in $Parameters.Values) {
        # Skip system parameters.
        if (([System.Management.Automation.Cmdlet]::CommonParameters).Contains($Parameter.Name)) {
            Write-Debug "Excluding system parameter $($Parameter.Name)."
            Continue
        }
        $ParameterVariable = Get-Variable -Name $Parameter.Name -ErrorAction SilentlyContinue
        if (($Parameter.ParameterType.Name -eq "String") -or ($Parameter.ParameterType.Name -eq "String[]")) {
            Write-Debug "Found String or String Array param $($ParameterVariable.Name)"
            if ([String]::IsNullOrEmpty($ParameterVariable.Value)) {
                Write-Debug "Skipping unset param $($ParameterVariable.Name)"
                Continue
            } else {
                if ($Parameter.Aliases) {
                    # Use the first alias as the query.
                    $Query = ([String]$Parameter.Aliases[0]).ToLower()
                } else {
                    # If no aliases then use the name in lowercase.
                    $Query = ([String]$ParameterVariable.Name).ToLower()
                }
                $Value = $ParameterVariable.Value
                if ($Value -is [array]) {
                    foreach ($ArrayValue in $Value) {
                        $QSCollection.Add($Query, $ArrayValue)
                        Write-Debug "Adding parameter $($Query) with value $($ArrayValue)"
                    }
                } else {
                    $QSCollection.Add($Query, $Value)
                    Write-Debug "Adding parameter $($Query) with value $($Value)"
                }
            }
        }
        if ($Parameter.ParameterType.Name -eq "SwitchParameter") {
            Write-Debug "Found Switch param $($ParameterVariable.Name)"
            if ($ParameterVariable.Value -eq $False) {
                Write-Debug "Skipping unset param $($ParameterVariable.Name)"
                Continue
            } else {
                if ($Parameter.Aliases) {
                    # Use the first alias as the query string name.
                    $Query = ([String]$Parameter.Aliases[0]).ToLower()
                } else {
                    # If no aliases then use the name in lowercase.
                    $Query = ([String]$ParameterVariable.Name).ToLower()
                }
                $Value = ([String]$ParameterVariable.Value).ToLower()
                if ($Value -is [array]) {
                    foreach ($ArrayValue in $Value) {
                        $QSCollection.Add($Query, $ArrayValue)
                        Write-Debug "Adding parameter $($Query) with value $($ArrayValue)"
                    }
                } else {
                    $QSCollection.Add($Query, $Value)
                    Write-Debug "Adding parameter $($Query) with value $($Value)"
                }
            }
        }
        if (($Parameter.ParameterType.Name -eq "Int32") -or ($Parameter.ParameterType.Name -eq "Int64") -or ($Parameter.ParameterType.Name -eq "Int32[]") -or ($Parameter.ParameterType.Name -eq "Int64[]")) {
            Write-Debug "Found Int or Int Array param $($ParameterVariable.Name)"
            if (($ParameterVariable.Value -eq 0) -or ($null -eq $ParameterVariable.Value)) {
                Write-Debug "Skipping unset param $($ParameterVariable.Name)"
                Continue
            } else {
                if ($Parameter.Aliases) {
                    # Use the first alias as the query string name.
                    $Query = ([String]$Parameter.Aliases[0]).ToLower()
                } else {
                    # If no aliases then use the name in lowercase.
                    $Query = ([String]$ParameterVariable.Name).ToLower()
                }
                $Value = $ParameterVariable.Value
                if ($Value -is [array]) {
                    foreach ($ArrayValue in $Value) {
                        $QSCollection.Add($Query, $ArrayValue)
                        Write-Debug "Adding parameter $($Query) with value $($ArrayValue)"
                    }
                } else {
                    $QSCollection.Add($Query, $Value)
                    Write-Debug "Adding parameter $($Query) with value $($Value)"
                }
            }
        }
    }
    if ("count" -in $QSCollection) {
        Write-Warning "Halo recommend use of pagination with the '-Paginate' parameter instead of '-Count'."
    }
    if ((('pageinate' -notin $QSCollection) -and ('count' -notin $QSCollection)) -and ($IsMulti)) {
        Write-Warning "Running in 'multi' mode but neither '-Paginate' or '-Count' was specified. All results will be returned."
        $QSCollection.Add('pageinate', 'true')
        if (-not($QSCollection.page_size)) {
            $QSCollection.Add('page_size', $Script:HAPIDefaultPageSize)
        }
        $QSCollection.Add('page_no', 1)
    }
    if (('pageinate' -in $QSCollection) -and ('page_size' -notin $QSCollection) -and ($IsMulti)) {
        Write-Warning "Parameter '-PageSize' was not provided for a paginated request. Using default value of $($Script:HAPIDefaultPageSize)"
    }
    if (('pageinate' -in $QSCollection) -and ('page_no' -notin $QSCollection) -and ($IsMulti)) {
        Write-Error "When using pagination you must specify an initial page number with '-PageNo'."
        Break
    }
    Write-Debug "Query collection contains $($QSCollection | Out-String)"
    Return $QSCollection
}