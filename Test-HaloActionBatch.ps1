# Assuming Get-HaloTicket, Get-HaloAction, and Set-HaloActionBatch are part of the same module or available in your environment

# Initialize an array to hold actions
$actions = @()

Write-Verbose 'Retrieving tickets...' -Verbose
# Get a list of tickets
$tickets = Get-HaloTicket

foreach ($ticket in $tickets) {
    Write-Verbose "Processing ticket with ID: $($ticket.Id)" -Verbose
    # Get actions for the ticket
    $TicketActions = Get-HaloAction -TicketID $ticket.Id -AgentOnly
    Write-Verbose "Found $($TicketActions.Count) actions for ticket ID: $($ticket.Id)" -Verbose

    foreach ($action in $TicketActions) {
        # Add or update the property as needed
        $action | Add-Member -NotePropertyName actreviewed -NotePropertyValue 'False' -Force
        Write-Verbose "Updated action ID: $($action.id) with actreviewed property set to 'False'" -Verbose

        # Add the updated action to the main actions array
        $actions += $action

        # If we have collected 50 or more actions, break out of the loop
        if ($actions.Count -ge 50) {
            Write-Verbose 'Collected 50 actions, stopping collection.' -Verbose
            break
        }
    }

    if ($actions.Count -ge 50) {
        break
    }
}

# Ensure only the first 50 actions are kept
$actions = $actions[0..49]
Write-Verbose 'Ensured only the first 50 actions are kept.' -Verbose

# Use Set-HaloActionBatch to send the array of 50 actions
Write-Verbose 'Sending 50 actions with Set-HaloActionBatch...' -Verbose
Set-HaloActionBatch -Actions $actions
Write-Verbose 'Sent 50 actions successfully.' -Verbose