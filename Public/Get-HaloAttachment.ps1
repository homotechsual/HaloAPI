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
    [CmdletBinding( DefaultParameterSetName = "Multi" )]
    Param(
        # Attachment ID
        [Parameter( ParameterSetName = "Single", Mandatory = $True )]
        [Parameter( ParameterSetName = "SingleFile", Mandatory = $True )]
        [Parameter( ParameterSetName = "SinglePath", Mandatory = $True )]
        [int64]$AttachmentID,
        # Returns attachments from the ticket ID specified
        [Parameter( ParameterSetName = "Multi", Mandatory = $True )]
        [Alias("ticket_id")]
        [int64]$TicketID,
        # Returns attachments from the action ID specified (requires ticket_id)
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("action_id")]
        [int64]$ActionID,
        # Returns attachments of the specified type
        [Parameter( ParameterSetName = "Multi" )]
        [int64]$Type,
        # Returns an attachment with the unique ID specified
        [Parameter( ParameterSetName = "Multi" )]
        [Alias("unique_id")]
        [int64]$UniqueID,
        # Include extra objects in the result.
        [Parameter( ParameterSetName = "Single" )]
        [Switch]$IncludeDetails,
        # Allow Writing Directly to File, using the specified path and file name eg c:\temp\myfile.txt
        [Parameter( ParameterSetName = "SingleFile", Mandatory = $True )]
        [String]$OutFile,
        # Allow Writing Directly to File, using the specified path and the original file name eg c:\temp\
        [Parameter( ParameterSetName = "SinglePath", Mandatory = $True )]
        [String]$OutPath
    )
    $CommandName = $PSCmdlet.MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding a 'attachmentid=' parameter by removing it from the set parameters.
    if ($AttachmentID) {
        $Parameters.Remove("AttachmentID") | Out-Null
    }
    $QueryString = New-HaloQueryString -CommandName $CommandName -Parameters $Parameters
    try {
        if ($AttachmentID) {
            Write-Verbose "Running in single-asset mode because '-AttachmentID' was provided."
            $Resource = "api/Attachment/$($AttachmentID)$($QueryString)"
            $RequestParams = @{
                Method    = "GET"
                Resource  = $Resource
                RawResult = $True
            }
        }
        else {
            Write-Verbose "Running in multi-asset mode."
            $Resource = "api/Attachment$($QueryString)"
            $RequestParams = @{
                Method   = "GET"
                Resource = $Resource
            }
        }    
        
        $AssetResults = Invoke-HaloRequest @RequestParams

        if ($AttachmentID) {
            Write-Verbose "Processing single mode response"
            if ($OutFile -or $OutPath) {
                # Get the file name or set it
                if ($OutPath) {
                    Write-Verbose "Attempting to output to path $OutPath"
                    $contentDisposition = $AssetResults.Headers.'Content-Disposition'
                    $disposition = [System.Net.Mime.ContentDisposition]::new($contentDisposition)
                    $fileName = $disposition.FileName
                    $path = Join-Path $OutPath $fileName
                } else {
                    Write-Verbose "Attempting to output to file $OutFile"
                    $path = $OutFile
                }                                      

                Write-Verbose "Writing File $path"
                $file = [System.IO.FileStream]::new($path, [System.IO.FileMode]::Create)
                $file.write($AssetResults.Content, 0, $AssetResults.RawContentLength)
                $file.close()
            
            } else {
                return $AssetResults.Content
            }
            
        } else {
            Return $AssetResults
        }

        
    } catch {
        Write-Error "Failed to get attachments from the Halo API. You'll see more detail if using '-Verbose'"
        Write-Verbose "$_"
    }
}