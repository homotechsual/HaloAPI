using namespace System.Collections.Generic
function New-HaloErrorRecord {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Private function - no need to support.')]
    param (
        [Parameter(Mandatory = $true)]
        [type]$ExceptionType,
        [Parameter(Mandatory = $true)]
        [string]$ErrorMessage,
        [exception]$InnerException = $null,
        [Parameter(Mandatory = $true)]
        [string]$ErrorID,
        [Parameter(Mandatory = $true)]
        [errorcategory]$ErrorCategory,
        [object]$TargetObject = $null,
        [object]$ErrorDetails = $null,
        [switch]$BubbleUpDetails
    )
    $ExceptionMessage = [list[string]]::New()
    $ExceptionMessage.Add($ErrorMessage)
    if ($ErrorDetails.Message) {
        if ($ErrorDetails.Message | Test-Json -ErrorAction Ignore) {
            $HaloError = $ErrorDetails.Message | ConvertFrom-Json -Depth 5
        } else {
            $HaloError = $ErrorDetails.Message
        }
        if ($HaloError.Message) {
            $ExceptionMessage.Add("Halo's API said $($HaloError.ClassName): $($HaloError.Message).")
        }
    }
    if ($InnerException.Response) {
        $Response = $InnerException.Response
    }
    if ($InnerException.InnerException.Response) {
        $Response = $InnerException.InnerException.Response
    }
    if ($InnerException.InnerException.InnerException.Response) {
        $Response = $InnerException.InnerException.InnerException.Response
    }
    if ($Response) {
        $ExceptionMessage.Add("Halo's API provided the status code $($Response.StatusCode.Value__): $($Response.ReasonPhrase).")
    }
    $ExceptionMessage.Add('You can use "Get-Error" for detailed error information.')
    $HaloError = [ErrorRecord]::New(
        $ExceptionType::New(
            $ExceptionMessage,
            $InnerException
        ),
        $ErrorID,
        $ErrorCategory,
        $TargetObject
    )
    if ($BubbleUpDetails) {
        $HaloError.ErrorDetails = $ErrorDetails
    }
    Return $HaloError
}