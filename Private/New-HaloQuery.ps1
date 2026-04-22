function New-HaloQuery {
    [CmdletBinding()]
    [OutputType([String], [Hashtable])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Private function - no need to support.')]
    param (
        # The calling command name whose bound parameters are being converted into a query object.
        [Parameter(
            Mandatory = $True
        )]
        [String]$CommandName,
        # The command parameter metadata collection to inspect when building the query.
        [Parameter(
            Mandatory = $True
        )]
        [Hashtable]$Parameters,
        # Indicates that the target request can return multiple results and should enable pagination defaults.
        [Switch]$IsMulti,
        # Indicates that array values should be joined into comma-separated query values.
        [Switch]$CommaSeparatedArrays,
        # Returns the query as a string instead of a hashtable.
        [Switch]$AsString
    )
    Write-Verbose ('Building parameters for {0}. Use ''-Debug'' with ''-Verbose'' to see parameter values as they are built.' -f $CommandName)
    $QSCollection = [Hashtable]@{}
    foreach ($Parameter in $Parameters.Values) {
        # Skip system parameters.
        if (([System.Management.Automation.Cmdlet]::CommonParameters).Contains($Parameter.Name)) {
            Write-Debug ('Excluding system parameter {0}.' -f $Parameter.Name)
            continue
        }
        # Skip optional system parameters.
        if (([System.Management.Automation.Cmdlet]::OptionalCommonParameters).Contains($Parameter.Name)) {
            Write-Verbose ('Excluding optional system parameter {0}.' -f $Parameter.Name)
            continue
        }
        $ParameterVariable = Get-Variable -Name $Parameter.Name -ErrorAction SilentlyContinue
        if (($Parameter.ParameterType.Name -eq 'String') -or ($Parameter.ParameterType.Name -eq 'String[]') -or ($Parameter.ParameterType.Name -eq 'Object') -or ($Parameter.ParameterType.Name -eq 'Object[]')) {
            Write-Debug ('Found String or String Array param {0}' -f $ParameterVariable.Name)
            if ([String]::IsNullOrEmpty($ParameterVariable.Value)) {
                Write-Debug ('Skipping unset param {0}' -f $ParameterVariable.Name)
                continue
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
                    Write-Debug 'Building comma separated array string.'
                    $QueryValue = $Value -join ','
                    $QSCollection.Add($Query, $QueryValue)
                    Write-Debug ('Adding parameter {0} with value {1}' -f $Query, $QueryValue)
                } else {
                    $QSCollection.Add($Query, $Value)
                    Write-Debug ('Adding parameter {0} with value {1}' -f $Query, $Value)
                }
            }
        }
        if ($Parameter.ParameterType.Name -eq 'SwitchParameter') {
            Write-Debug ('Found Switch param {0}' -f $ParameterVariable.Name)
            if ($ParameterVariable.Value -eq $False) {
                Write-Debug ('Skipping unset param {0}' -f $ParameterVariable.Name)
                continue
            } else {
                if ($Parameter.Aliases) {
                    # Use the first alias as the query string name.
                    $Query = ([String]$Parameter.Aliases[0]).ToLower()
                } else {
                    # If no aliases then use the name in lowercase.
                    $Query = ([String]$ParameterVariable.Name).ToLower()
                }
                $Value = ([String]$ParameterVariable.Value).ToLower()
                $QSCollection.Add($Query, $Value)
                Write-Debug ('Adding parameter {0} with value {1}' -f $Query, $Value)
            }
        }
        if (($Parameter.ParameterType.Name -eq 'Int32') -or ($Parameter.ParameterType.Name -eq 'Int64') -or ($Parameter.ParameterType.Name -eq 'Int32[]') -or ($Parameter.ParameterType.Name -eq 'Int64[]')) {
            Write-Debug ('Found Int or Int Array param {0}' -f $ParameterVariable.Name)
            if (($ParameterVariable.Value -eq 0) -or ($null -eq $ParameterVariable.Value)) {
                Write-Debug ('Skipping unset param {0}' -f $ParameterVariable.Name)
                continue
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
                    Write-Debug 'Building comma separated array string.'
                    $QueryValue = $Value -join ','
                    $QSCollection.Add($Query, $QueryValue)
                    Write-Debug ('Adding parameter {0} with value {1}' -f $Query, $QueryValue)
                } else {
                    $QSCollection.Add($Query, $Value)
                    Write-Debug ('Adding parameter {0} with value {1}' -f $Query, $Value)
                }
            }
        }
        if (($Parameter.ParameterType.Name -eq 'DateTime') -or ($Parameter.ParameterType.Name -eq 'DateTime[]')) {
            Write-Debug ('Found DateTime or DateTime Array param {0}' -f $ParameterVariable.Name)
            if ($null -eq $ParameterVariable.Value) {
                Write-Debug ('Skipping unset param {0}' -f $ParameterVariable.Name)
                continue
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
                    Write-Debug 'Building comma separated DateTime array string.'
                    $QueryValue = ($Value | ForEach-Object { $_.ToString('o') }) -join ','
                    $QSCollection.Add($Query, $QueryValue)
                    Write-Debug ('Adding parameter {0} with value {1}' -f $Query, $QueryValue)
                } else {
                    $QueryValue = $Value.ToString('o')
                    $QSCollection.Add($Query, $QueryValue)
                    Write-Debug ('Adding parameter {0} with value {1}' -f $Query, $QueryValue)
                }
            }
        }
    }
    if ('count' -in $QSCollection.Keys) {
        Write-Verbose "Halo recommend use of pagination with the '-Paginate' parameter instead of '-Count'."
    }
    if ((('pageinate' -notin $QSCollection.Keys) -and ('count' -notin $QSCollection.Keys)) -and ($IsMulti)) {
        Write-Verbose "Running in 'multi' mode but neither '-Paginate' or '-Count' was specified. All results will be returned."
        $QSCollection.Add('pageinate', 'true')
        if (-not($QSCollection.page_size)) {
            $QSCollection.Add('page_size', $Script:HAPIDefaultPageSize)
        }
        $QSCollection.Add('page_no', 1)
    }
    if (('pageinate' -in $QSCollection.Keys) -and ('page_size' -notin $QSCollection.Keys) -and ($IsMulti)) {
        Write-Verbose ('Parameter ''-PageSize'' was not provided for a paginated request. Using default value of {0}' -f $Script:HAPIDefaultPageSize)
    }
    if (('pageinate' -in $QSCollection.Keys) -and ('page_no' -notin $QSCollection.Keys) -and ($IsMulti)) {
        Write-Error "When using pagination you must specify an initial page number with '-PageNo'."
        break
    }
    Write-Debug ('Query collection contains {0}' -f ($QSCollection | Out-String))
    if ($AsString) {
        $QSBuilder.Query = $QSCollection.ToString()
        $Query = $QSBuilder.Query.ToString()
        Return $Query
    } else {
        Return $QSCollection
    }
}