using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language
using module ..\HaloCustomButton.psm1

class HaloCustomButtonCompleter : IArgumentCompleter {
    <#
        .SYNOPSIS
            Argument completer for Halo Custom Button types.
        .DESCRIPTION
            Provides argument completion for Halo Custom Button types.
    #>
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string]$Command,
        [string]$Parameter,
        [string]$WordToComplete,
        [CommandAST]$CommandAST,
        [IDictionary]$FakeBoundParams
    ) {
        $CustomButtonTypeIDs = [HaloCustomButton]::GetButtonTypes()
        $Wildcard = ("*$($WordToComplete)*")
        $CompletionResults = [List[CompletionResult]]::new()
        $CustomButtonTypeIDs.Keys -like $Wildcard | ForEach-Object {
            $CompletionResults.Add(
                [CompletionResult]::new(
                    $_,
                    $_,
                    "ParameterValue",
                    $_
                )
            )
        }
        return $CompletionResults
    }
}