function Measure-RequiredCommentBasedHelp {
    <#
        .SYNOPSIS
            Ensure functions have required comment-based help sections.
        .DESCRIPTION
            This rule verifies that functions contain required comment-based help sections.
            Public functions should have .SYNOPSIS, .DESCRIPTION, and .EXAMPLE sections.
            Private functions should at least have .SYNOPSIS.
        .INPUTS
            [System.Management.Automation.Language.ScriptBlockAst]
        .OUTPUTS
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
    #>
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param(
        # The script block AST provided by PSScriptAnalyzer for inspection.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]$ScriptBlockAst
    )

    process {
        try {
            $scriptPath = $ScriptBlockAst.Extent.File
            $normalizedScriptPath = if ($scriptPath) { $scriptPath -replace '\\', '/' } else { $null }
            if ($normalizedScriptPath -like '*/CustomRules/*') {
                return
            }

            $scriptContent = $ScriptBlockAst.Extent.Text
            $functions = $ScriptBlockAst.FindAll({
                    param([System.Management.Automation.Language.Ast]$Ast)
                    $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst]
                }, $false)
            $classes = $ScriptBlockAst.FindAll({
                    param([System.Management.Automation.Language.Ast]$Ast)
                    $Ast -is [System.Management.Automation.Language.TypeDefinitionAst]
                }, $false)

            $classNames = foreach ($classAst in $classes) {
                $classAst.Name
            }

            foreach ($function in $functions) {
                $functionName = $function.Name
                $isPublic = $normalizedScriptPath -like '*/Public/*'

                if ($functionName -match '^(Get|Invoke|WriteMessage|InvokeTask|GetModulePath|GetFunctions|AssertOutputBinariesUnlocked|Push|Publish|Clean)$') {
                    continue
                }

                if ($functionName -in $classNames) {
                    continue
                }

                $funcBody = $function.Body
                if (-not $funcBody) {
                    continue
                }

                $functionText = $function.Extent.Text
                $functionStartLine = $function.Extent.StartLineNumber
                $scriptLines = $scriptContent -split "`n"
                $searchStart = [Math]::Max(0, $functionStartLine - 50 - 1)
                $searchEnd = $functionStartLine - 1
                $precedingText = ($scriptLines[$searchStart..$searchEnd] -join "`n")
                $searchText = $precedingText + "`n" + $functionText

                if (-not ($searchText -match '(?s)\<#.*?\.SYNOPSIS.*?#\>')) {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new(
                        "Function '$functionName' is missing comment-based help. Add a <# .SYNOPSIS ... #> help block.",
                        $function.Extent,
                        'PSRequiredCommentBasedHelp',
                        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticSeverity]::Warning,
                        $null,
                        $null,
                        $null
                    )
                    continue
                }

                $hasSynopsis = $searchText -match '\.SYNOPSIS'
                $hasDescription = $searchText -match '\.DESCRIPTION'
                $hasExample = $searchText -match '\.EXAMPLE'

                if (-not $hasSynopsis) {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new(
                        "Function '$functionName' help is missing .SYNOPSIS section.",
                        $function.Extent,
                        'PSRequiredCommentBasedHelp',
                        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticSeverity]::Warning,
                        $null,
                        $null,
                        $null
                    )
                }

                if ($isPublic -and -not $hasDescription) {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new(
                        "Public function '$functionName' help is missing .DESCRIPTION section.",
                        $function.Extent,
                        'PSRequiredCommentBasedHelp',
                        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticSeverity]::Warning,
                        $null,
                        $null,
                        $null
                    )
                }

                if ($isPublic -and -not $hasExample) {
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new(
                        "Public function '$functionName' help is missing .EXAMPLE section.",
                        $function.Extent,
                        'PSRequiredCommentBasedHelp',
                        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticSeverity]::Information,
                        $null,
                        $null,
                        $null
                    )
                }
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}

function Measure-RequireProperTypeAcceleratorCasing {
    <#
        .SYNOPSIS
            Ensures type accelerators use proper casing.
        .DESCRIPTION
            Flags any type accelerator that is not cased to match the underlying type name.
        .INPUTS
            [System.Management.Automation.Language.ScriptBlockAst]
        .OUTPUTS
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
    #>
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param(
        # The script block AST provided by PSScriptAnalyzer for inspection.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]$ScriptBlockAst
    )

    process {
        try {
            $scriptPath = $ScriptBlockAst.Extent.File
            if ($scriptPath) {
                $normalizedScriptPath = $scriptPath -replace '\\', '/'
                if ($normalizedScriptPath -like '*/CustomRules/*') {
                    return
                }

                if ($normalizedScriptPath -notlike '*/Public/*') {
                    return
                }
            }

            $acceleratorType = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators', $false)
            if (-not $acceleratorType) {
                return
            }

            $accelerators = $null
            $method = $acceleratorType.GetMethod('Get', [System.Reflection.BindingFlags]'Public,NonPublic,Static')
            if ($method) {
                $accelerators = $method.Invoke($null, @())
            }

            if (-not $accelerators) {
                $field = $acceleratorType.GetField('typeAccelerators', [System.Reflection.BindingFlags]'NonPublic,Static')
                if ($field) {
                    $accelerators = $field.GetValue($null)
                }
            }

            if (-not $accelerators) {
                return
            }

            $acceleratorMap = @{}
            foreach ($key in $accelerators.Keys) {
                $acceleratorMap[$key.ToLowerInvariant()] = $accelerators[$key].Name
            }

            $typeAsts = $ScriptBlockAst.FindAll({
                    param([System.Management.Automation.Language.Ast]$Ast)
                    $Ast -is [System.Management.Automation.Language.TypeExpressionAst] -or
                    $Ast -is [System.Management.Automation.Language.TypeConstraintAst]
                }, $true)

            foreach ($typeAst in $typeAsts) {
                $typeName = $typeAst.TypeName
                if (-not $typeName) {
                    continue
                }

                $rawName = $typeName.Name
                if (-not $rawName) {
                    continue
                }

                $baseName = $rawName
                $suffix = ''
                $match = [regex]::Match($rawName, '^(?<base>[^\[]+)(?<suffix>\[.*\])$')
                if ($match.Success) {
                    $baseName = $match.Groups['base'].Value
                    $suffix = $match.Groups['suffix'].Value
                }

                $baseKey = $baseName.ToLowerInvariant()
                if (-not $acceleratorMap.ContainsKey($baseKey)) {
                    continue
                }

                $preferredBase = $acceleratorMap[$baseKey]
                $preferredName = $preferredBase + $suffix
                if ($rawName -ceq $preferredName) {
                    continue
                }

                [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new(
                    "Type accelerator '$rawName' should be cased as '$preferredName'.",
                    $typeAst.Extent,
                    'PSUseProperTypeAcceleratorCasing',
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticSeverity]::Warning,
                    $null,
                    $null,
                    $null
                )
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}

function Measure-EmptyCommentBasedHelpSections {
    <#
        .SYNOPSIS
            Ensure functions do not have empty comment-based help sections.
        .DESCRIPTION
            This rule verifies that functions do not contain empty comment-based help sections.
        .INPUTS
            [System.Management.Automation.Language.ScriptBlockAst]
        .OUTPUTS
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
    #>
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param(
        # The script block AST provided by PSScriptAnalyzer for inspection.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]$ScriptBlockAst
    )

    process {
        try {
            $functions = $ScriptBlockAst.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)

            foreach ($function in $functions) {
                $help = $function.GetHelpContent()
                if ($null -eq $help -or $help.Count -eq 0) {
                    continue
                }

                $helpText = $help -join "`n"
                $emptyPattern = '\.(?:SYNOPSIS|DESCRIPTION|PARAMETER|EXAMPLE|OUTPUTS|LINK|FUNCTIONALITY|NOTES|INPUTS|COMPONENT)\s*\n\s*(?=\.(?:SYNOPSIS|DESCRIPTION|PARAMETER|EXAMPLE|OUTPUTS|LINK|FUNCTIONALITY|NOTES|INPUTS|COMPONENT)|\s*#>)'

                if ($helpText -match $emptyPattern) {
                    $sectionMatches = [regex]::Matches($helpText, $emptyPattern)
                    foreach ($sectionMatch in $sectionMatches) {
                        $keywordMatch = [regex]::Match($sectionMatch.Value, '\.(\w+)')
                        $keyword = $keywordMatch.Groups[1].Value

                        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new(
                            "Function '$($function.Name)' contains an empty .$keyword section. Either add content or remove the empty keyword.",
                            $function.Extent,
                            'PSCommentBasedHelpEmptySection',
                            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticSeverity]::Warning,
                            $null,
                            $null,
                            $null
                        )
                    }
                }
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}

function Measure-MissingParameterDescription {
    <#
        .SYNOPSIS
            Ensure functions have inline comment descriptions for all parameters.
        .DESCRIPTION
            This rule verifies that all parameters in the param() block have an inline comment
            description immediately before them.
        .INPUTS
            [System.Management.Automation.Language.ScriptBlockAst]
        .OUTPUTS
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
    #>
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param(
        # The script block AST provided by PSScriptAnalyzer for inspection.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]$ScriptBlockAst
    )

    process {
        try {
            $functions = $ScriptBlockAst.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)

            foreach ($function in $functions) {
                $paramBlock = $function.Body.ParamBlock
                if ($null -eq $paramBlock -or $null -eq $paramBlock.Parameters -or $paramBlock.Parameters.Count -eq 0) {
                    continue
                }

                $scriptText = $function.Extent.Text
                foreach ($parameter in $paramBlock.Parameters) {
                    $paramName = $parameter.Name.VariablePath.UserPath
                    $paramStartOffset = $parameter.Extent.StartOffset
                    $textBeforeParam = $scriptText.Substring(0, $paramStartOffset - $function.Extent.StartOffset)
                    $lines = $textBeforeParam -split "`r?`n"
                    $hasComment = $false

                    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
                        $line = $lines[$i].Trim()

                        if ([string]::IsNullOrWhiteSpace($line)) {
                            continue
                        }

                        if ($line -match '^\s*#\s+\S+') {
                            $hasComment = $true
                            break
                        }

                        if ($line -match '^\s*\[' -or $line -match '\]') {
                            continue
                        }

                        if ($line -match '^\s*param\s*\(' -or $line -match '\$\w+\s*[,)]' -or $line -eq ',') {
                            break
                        }
                    }

                    if (-not $hasComment) {
                        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new(
                            "Parameter '`$$paramName' in function '$($function.Name)' is missing an inline comment description. Add a comment like '# The $paramName description.' before the parameter.",
                            $parameter.Extent,
                            'PSMissingParameterInlineComment',
                            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticSeverity]::Warning,
                            $null,
                            $null,
                            $null
                        )
                    }
                }
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}

function Measure-AvoidSelfReferentialParameterAlias {
    <#
        .SYNOPSIS
            Ensures parameter aliases do not duplicate the parameter name.
        .DESCRIPTION
            Flags any parameter whose Alias attribute includes the parameter's own name.
        .INPUTS
            [System.Management.Automation.Language.ScriptBlockAst]
        .OUTPUTS
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
    #>
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param(
        # The script block AST provided by PSScriptAnalyzer for inspection.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]$ScriptBlockAst
    )

    process {
        try {
            $scriptPath = $ScriptBlockAst.Extent.File
            if (-not $scriptPath) {
                return
            }

            $normalizedScriptPath = $scriptPath -replace '\\', '/'
            if ($normalizedScriptPath -like '*/CustomRules/*') {
                return
            }

            if ($normalizedScriptPath -notlike '*/Public/*') {
                return
            }

            $parameters = $ScriptBlockAst.FindAll({
                    param([System.Management.Automation.Language.Ast]$Ast)
                    $Ast -is [System.Management.Automation.Language.ParameterAst]
                }, $false)

            foreach ($parameter in $parameters) {
                $parameterName = $parameter.Name.VariablePath.UserPath
                if (-not $parameterName) {
                    continue
                }

                $functionAst = $parameter.Parent
                while ($functionAst -and $functionAst -isnot [System.Management.Automation.Language.FunctionDefinitionAst]) {
                    $functionAst = $functionAst.Parent
                }
                $functionName = if ($functionAst) { $functionAst.Name } else { '<script>' }

                foreach ($attribute in $parameter.Attributes) {
                    if (-not $attribute.TypeName) {
                        continue
                    }

                    $attributeName = $attribute.TypeName.FullName
                    if ($attributeName -notin @('Alias', 'System.Management.Automation.AliasAttribute')) {
                        continue
                    }

                    foreach ($argument in $attribute.PositionalArguments) {
                        $aliasValue = $null
                        if ($argument -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
                            $aliasValue = $argument.Value
                        } elseif ($argument -is [System.Management.Automation.Language.ConstantExpressionAst]) {
                            $aliasValue = [string]$argument.Value
                        }

                        if (-not $aliasValue) {
                            continue
                        }

                        if ($aliasValue.Equals($parameterName, [System.StringComparison]::OrdinalIgnoreCase)) {
                            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new(
                                "Parameter '$parameterName' in function '$functionName' defines alias '$aliasValue', which duplicates the parameter name and should be removed.",
                                $argument.Extent,
                                'PSAvoidSelfReferentialParameterAlias',
                                [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticSeverity]::Warning,
                                $null,
                                $null,
                                $null
                            )
                        }
                    }
                }
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}

function ConvertTo-CamelCaseParameterName {
    <#
        .SYNOPSIS
            Converts an identifier to camelCase.
        .DESCRIPTION
            Normalizes PascalCase, acronym-prefixed, and snake_case identifiers into a
            camelCase form suitable for parameter name suggestions.
        .OUTPUTS
            [string]
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The identifier value that should be normalized to camelCase.
        [Parameter(Mandatory)]
        [string]$Identifier
    )

    if ($Identifier -match '_') {
        $segments = $Identifier -split '_+' | Where-Object { $_ }
        if (-not $segments) {
            return $Identifier
        }

        $camelName = $segments[0].ToLowerInvariant()
        if ($segments.Count -gt 1) {
            $camelName += (($segments | Select-Object -Skip 1) | ForEach-Object {
                    if ($_.Length -eq 1) {
                        $_.ToUpperInvariant()
                    } else {
                        $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1).ToLowerInvariant()
                    }
                }) -join ''
        }

        return $camelName
    }

    $chars = $Identifier.ToCharArray()
    $uppercasePrefixLength = 0
    while ($uppercasePrefixLength -lt $chars.Length -and [char]::IsUpper($chars[$uppercasePrefixLength])) {
        $uppercasePrefixLength++
    }

    if ($uppercasePrefixLength -le 1) {
        if ($Identifier.Length -eq 1) {
            return $Identifier.ToLowerInvariant()
        }

        return $Identifier.Substring(0, 1).ToLowerInvariant() + $Identifier.Substring(1)
    }

    if ($uppercasePrefixLength -lt $chars.Length) {
        $uppercasePrefixLength--
    }

    $prefix = $Identifier.Substring(0, $uppercasePrefixLength).ToLowerInvariant()
    $suffix = $Identifier.Substring($uppercasePrefixLength)
    return $prefix + $suffix
}

function Measure-RequireCamelCaseParameterName {
    <#
        .SYNOPSIS
            Ensures function parameter names use camelCase.
        .DESCRIPTION
            Flags parameters declared in functions when their names do not start with a
            lowercase letter or contain unsupported characters.
        .INPUTS
            [System.Management.Automation.Language.ScriptBlockAst]
        .OUTPUTS
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
    #>
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param(
        # The script block AST provided by PSScriptAnalyzer for inspection.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]$ScriptBlockAst
    )

    process {
        try {
            $scriptPath = $ScriptBlockAst.Extent.File
            if ($scriptPath) {
                $normalizedScriptPath = $scriptPath -replace '\\', '/'
                if ($normalizedScriptPath -like '*/CustomRules/*') {
                    return
                }
            }

            $functions = $ScriptBlockAst.FindAll({
                    param([System.Management.Automation.Language.Ast]$Ast)
                    $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst]
                }, $true)

            foreach ($function in $functions) {
                $paramBlock = $function.Body.ParamBlock
                if ($null -eq $paramBlock -or $null -eq $paramBlock.Parameters -or $paramBlock.Parameters.Count -eq 0) {
                    continue
                }

                foreach ($parameter in $paramBlock.Parameters) {
                    $parameterName = $parameter.Name.VariablePath.UserPath
                    if (-not $parameterName) {
                        continue
                    }

                    if ($parameterName -cmatch '^[a-z][A-Za-z0-9]*$') {
                        continue
                    }

                    $suggestedName = ConvertTo-CamelCaseParameterName -Identifier $parameterName
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new(
                        "Parameter '`$$parameterName' in function '$($function.Name)' should use camelCase. Rename it to '`$$suggestedName'.",
                        $parameter.Extent,
                        'PSUseCamelCaseParameterName',
                        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticSeverity]::Warning,
                        $null,
                        $null,
                        $null
                    )
                }
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}


function Measure-AvoidDoubleQuoteInterpolation {
    <#
		.SYNOPSIS
			Ensures string interpolation uses single-quoted strings with the -f format operator.
		.DESCRIPTION
			Flags double-quoted strings that contain variable or sub-expression interpolation.
			The preferred style in this module is to use single-quoted format strings with the
			-f operator (e.g., '{0}' -f $variable) rather than double-quoted interpolation
			(e.g., "$variable"). Here-strings (@"..."@) are excluded from this check.
		.EXAMPLE
			Reports "$variableName" and suggests '{0}' -f $variableName.
		.INPUTS
			[System.Management.Automation.Language.ScriptBlockAst]
		.OUTPUTS
			[Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
	#>
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param(
        # The script block AST to analyze.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]$scriptBlockAst
    )

    process {
        try {
            $scriptPath = $scriptBlockAst.Extent.File
            if ($scriptPath) {
                $normalizedScriptPath = $scriptPath -replace '\\', '/'
                if ($normalizedScriptPath -like '*/CustomRules/*') {
                    return
                }
            }

            $expandableStrings = $scriptBlockAst.FindAll({
                    param([System.Management.Automation.Language.Ast]$Ast)
                    $Ast -is [System.Management.Automation.Language.ExpandableStringExpressionAst]
                }, $true)

            foreach ($expandableString in $expandableStrings) {
                # Skip double-quoted here-strings (@"..."@)
                if ($expandableString.StringConstantType -eq [System.Management.Automation.Language.StringConstantType]::DoubleQuotedHereString) {
                    continue
                }

                $result = [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new(
                    "Avoid double-quoted string interpolation. Use a single-quoted string with the -f format operator instead (e.g., '{0}' -f `$variable).",
                    $expandableString.Extent,
                    'PSAvoidDoubleQuoteInterpolation',
                    [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticSeverity]::Warning,
                    $null,
                    $null,
                    $null
                )
                $result
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}

Export-ModuleMember -Function Measure-*