using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language
using module ..\HaloLookup.psm1

class HaloLookupCompleter : IArgumentCompleter {
    <#
        .SYNOPSIS
            Argument completer for Halo Lookup types.
        .DESCRIPTION
            Provides argument completion for Halo Lookup types.
    #>
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string]$Command,
        [string]$Parameter,
        [string]$WordToComplete,
        [CommandAST]$CommandAST,
        [IDictionary]$FakeBoundParams
    ) {
        # Initialise the HaloLookup class.
        [HaloLookup]::new()
        $LookupTypes = [HaloLookup]::GetLookupTypes()
        $Wildcard = ("*$($WordToComplete)*")
        $CompletionResults = [List[CompletionResult]]::new()
        $LookupTypes | Where-Object { $_.name -like $Wildcard } | ForEach-Object {
            $CompletionResults.Add(
                [CompletionResult]::new(
                    $_.name,
                    $_.name,
                    'ParameterValue',
                    $_.name
                )
            )
        }
        return $CompletionResults
    }
}