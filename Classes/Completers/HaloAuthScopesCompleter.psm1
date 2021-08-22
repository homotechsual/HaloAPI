using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language
using module ..\HaloAuth.psm1

class HaloAuthScopesCompleter : IArgumentCompleter {
    <#
        .SYNOPSIS
            Argument completer for Halo authentication scopes.
        .DESCRIPTION
            Provides argument completion for Halo authentication scopes.
    #>
    [IEnumerable[CompletionResult]] CompleteArgument(
        [string]$Command,
        [string]$Parameter,
        [string]$WordToComplete,
        [CommandAST]$CommandAST,
        [IDictionary]$FakeBoundParams
    ) {
        $Scopes = [HaloAuth]::GetScopes()
        $Wildcard = ("*$($WordToComplete)*")
        $CompletionResults = [List[CompletionResult]]::new()
        $Scopes -like $Wildcard | ForEach-Object {
            $CompletionResults.Add(
                [CompletionResult]::new(
                    $_,
                    $_,
                    'ParameterValue',
                    $_
                )
            )
        }
        return $CompletionResults
    }
}