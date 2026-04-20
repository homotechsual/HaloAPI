@{
    RootModule = 'CustomRules.psm1'
    ModuleVersion = '1.0.0'
    GUID = '3b19ac28-c62e-4620-a630-4a0c69f8d2bb'
    Author = 'Homotechsual'
    CompanyName = 'Homotechsual'
    Copyright = '(c) Homotechsual. All rights reserved.'
    Description = 'Custom PSScriptAnalyzer rules for the HaloAPI module'
    FunctionsToExport = @(
        'Measure-RequiredCommentBasedHelp',
        'Measure-RequireProperTypeAcceleratorCasing',
        'Measure-EmptyCommentBasedHelpSections',
        'Measure-MissingParameterDescription',
        'Measure-AvoidSelfReferentialParameterAlias',
        'Measure-RequireCamelCaseParameterName'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
}