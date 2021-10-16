using namespace System.Management.Automation
class HaloPipelineIDArgumentTransformation : ArgumentTransformationAttribute {
    [Object] Transform([EngineIntrinsics]$EngineIntrinsics, [Object]$InputData) {   
        # If the input is an integer - pass it through to the command.
        if ($InputData -is [int]) {
            Write-Debug 'Returning integer from inputdata.'
            return $InputData
        }

        # If the input is an object - grab the ID property
        if ($Property = $InputData.PSObject.Properties.Match('id')) {
            Write-Debug 'Returning object from inputdata.'
            return $property.Value
        }

        throw 'Invalid argument'
    }
}