<#
    .SYNOPSIS
        Based on the PowerShell Script Analyzer (PSSA) presets.
    .LINK
        https://github.com/PowerShell/PSScriptAnalyzer/blob/master/Engine/Settings/
#>
@{
    CustomRulePath = @(
        '.\CustomRules'
    )
    Severity = @(
        'Error',
        'Warning',
        'Information'
    )
    IncludeRules = @(
        'PSAlignAssignmentStatement',
        'PSAvoidAssignmentToAutomaticVariable',
        'PSAvoidDefaultValueForMandatoryParameter',
        'PSAvoidDefaultValueSwitchParameter',
        'PSAvoidGlobalAliases',
        'PSAvoidGlobalVars',
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingComputerNameHardcoded',
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        'PSAvoidUsingDoubleQuotesForConstantString',
        'PSAvoidUsingEmptyCatchBlock',
        'PSAvoidUsingInvokeExpression',
        'PSAvoidUsingPlainTextForPassword',
        'PSAvoidUsingPositionalParameters',
        'PSAvoidUsingUserNameAndPasswordParams',
        'PSAvoidUsingWMICmdlet',
        'PSAvoidUsingWriteHost',
        'PSAvoidUsingWMICmdlet',
        'PSDSC*',
        'PSMissingModuleManifestField',
        'PSPlaceCloseBrace',
        'PSPlaceOpenBrace',
        'PSProvideCommentHelp',
        'PSReservedCmdletChar',
        'PSReservedParams',
        'PSShouldProcess',
        'PSUseApprovedVerbs',
        'PSUseCmdletCorrectly',
        'PSUseConsistentIndentation',
        'PSUseConsistentWhitespace',
        'PSUseCorrectCasing',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSUsePSCredentialType',
        'PSUseShouldProcessForStateChangingFunctions',
        'Measure-RequiredCommentBasedHelp',
        'Measure-EmptyCommentBasedHelpSections',
        'Measure-MissingParameterDescription',
        'Measure-AvoidSelfReferentialParameterAlias'
    )
    Rules = @{
        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace = @{
            Enable = $true
            NewLineAfter = $false
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore = $false
        }

        PSUseConsistentIndentation = @{
            Enable = $true
            Kind = 'space'
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            IndentationSize = 4
        }

        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckInnerBrace = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckPipe = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator = $true
            CheckParameter = $false
            IgnoreAssignmentOperatorInsideHashTable = $true
        }

        PSUseCorrectCasing = @{
            Enable = $true
        }

        PSAvoidUsingDoubleQuotesForConstantString = @{
            Enable = $true
        }

        PSAlignAssignmentStatement = @{
            Enable = $false
        }

        # HaloAPI currently uses PascalCase parameters on its public cmdlets,
        # so the stricter naming and type-accelerator casing rules remain available
        # in CustomRules without being enabled by default.
    }
}