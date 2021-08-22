class HaloAuth {
    <#
        .SYNOPSIS
            Utility classes for Halo authentication.
        .DESCRIPTION
            Provides helper utilities for Halo authentication scenarios.
    #>
    [array] static $Scopes = @(
        'all',
        'all:standard',
        'admin',
        'read:tickets',
        'edit:tickets',
        'read:calendar',
        'edit:calendar',
        'read:customers',
        'edit:customers',
        'read:crm',
        'edit:crm',
        'editMine:timesheets',
        'read:timesheets',
        'edit:timesheets',
        'read:contracts',
        'edit:contracts',
        'read:suppliers',
        'edit:suppliers',
        'read:items',
        'edit:items',
        'read:projects',
        'edit:projects',
        'read:sales',
        'edit:sales',
        'read:quotes',
        'edit:quotes',
        'read:sos',
        'edit:sos',
        'read:pos',
        'edit:pos',
        'read:invoices',
        'edit:invoices',
        'read:reporting',
        'edit:reporting',
        'read:software',
        'edit:software',
        'read:softwarelicensing',
        'edit:softwarelicensing',
        'read:kb',
        'edit:kb',
        'read:assets',
        'edit:assets',
        'access:chat',
        'access:adpasswordreset'
    )
    [array] static GetScopes() {
        return [HaloAuth]::Scopes
    }
}
