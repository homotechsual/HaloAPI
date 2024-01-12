#Requires -Version 7
function Get-HaloAttachment {
    <#
        .SYNOPSIS
            Gets attachments from the Halo API.
        .DESCRIPTION
            Retrieves attachments from the Halo API - supports a variety of filtering parameters.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Multi' )]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Attachment ID
        [Parameter( ParameterSetName = 'Single', Mandatory = $True )]
        [Parameter( ParameterSetName = 'SingleFile', Mandatory = $True )]
        [Parameter( ParameterSetName = 'SinglePath', Mandatory = $True )]
        [int64]$AttachmentID,
        # Returns attachments from the ticket ID specified
        [Parameter( ParameterSetName = 'Multi', Mandatory = $True )]
        [Alias('ticket_id')]
        [int64]$TicketID,
        # Returns attachments from the action ID specified (requires ticket_id)
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('action_id')]
        [int64]$ActionID,
        # Returns attachments of the specified type
        [Parameter( ParameterSetName = 'Multi' )]
        [int64]$Type,
        # Returns an attachment with the unique ID specified
        [Parameter( ParameterSetName = 'Multi' )]
        [Alias('unique_id')]
        [int64]$UniqueID,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$IncludeDetails,
        # Allow Writing Directly to File, using the specified path and file name eg c:\temp\myfile.txt
        [Parameter( ParameterSetName = 'SingleFile', Mandatory = $True )]
        [String]$OutFile,
        # Allow Writing Directly to File, using the specified path and the original file name eg c:\temp\
        [Parameter( ParameterSetName = 'SinglePath', Mandatory = $True )]
        [String]$OutPath,
        # Return the attachment as a base64 encoded string
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$AsBase64,
        # Get the token for accessing the image using the token parameter(s).
        [Parameter( ParameterSetName = 'Single' )]
        [Switch]$GetToken
    )
    Invoke-HaloPreFlightCheck
    $CommandName = $MyInvocation.MyCommand.Name
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'attachmentid=' parameter by removing it from the set parameters.
    if ($AttachmentID) {
        $Parameters.Remove('AttachmentID') | Out-Null
    }
    $QSCollection = New-HaloQuery -CommandName $CommandName -Parameters $Parameters
    try {
        if ($AttachmentID) {
            Write-Verbose "Running in single-asset mode because '-AttachmentID' was provided."
            $Resource = "api/attachment/$($AttachmentID)"
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                RawResult = $True
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'attachments'
            }
        } else {
            Write-Verbose 'Running in multi-asset mode.'
            $Resource = 'api/attachment'
            $RequestParams = @{
                Method = 'GET'
                Resource = $Resource
                AutoPaginateOff = $True
                QSCollection = $QSCollection
                ResourceType = 'attachments'
            }
        }
        $AttachmentResults = New-HaloGETRequest @RequestParams
        if ($AttachmentID) {
            Write-Verbose 'Processing single mode response'
            if ($OutFile -or $OutPath) {
                # Get the file name or set it
                if ($OutPath) {
                    Write-Verbose "Attempting to output to path $OutPath"
                    $ContentDisposition = $AttachmentResults.Headers.'Content-Disposition'
                    $Disposition = [System.Net.Mime.ContentDisposition]::new($ContentDisposition)
                    $FileName = $Disposition.FileName
                    $Path = Join-Path $OutPath $FileName
                } else {
                    Write-Verbose "Attempting to output to file $OutFile"
                    $Path = $OutFile
                }
                Write-Verbose "Writing File $Path"
                $File = [System.IO.FileStream]::new($Path, [System.IO.FileMode]::Create)
                $File.write($AttachmentResults.Content, 0, $AttachmentResults.RawContentLength)
                $File.close()
            } elseif ($AsBase64) {
                Write-Verbose 'Returning base64 encoded string'
                $Base64String = [System.Convert]::ToBase64String($AttachmentResults.Content)
                Return $Base64String
            } else {
                return $AttachmentResults.Content
            }
        } else {
            Return $AttachmentResults
        }
    } catch {
        New-HaloError -ErrorRecord $_
    }
}