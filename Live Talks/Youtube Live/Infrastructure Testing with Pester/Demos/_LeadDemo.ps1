$demoPath = 'C:\Dropbox\GitRepos\Session-Content\Live Talks\PowerShell Summit 2017\Infrastructure Testing with Pester\Demos'

## DEMO 1 - Infrastructure Testing 101
ii "$demoPath\Introduction\Infrastructure Testing 101.ps1"

## DEMO 2 - Reviewing the DSC configuration
ii "$demoPath\Project\New-TestEnvironment.ps1"

## DEMO 3 - Dealing with Dependencies
ii "$demoPath\Introduction\Dealing with Dependencies.ps1"

## DEMO 4 - Defining Expected Behavior
ii "$demoPath\Introduction\Defining Expected Behavior.ps1"

## DEMO 5 - Creating the Tests
ii "$demoPath\Introduction\Creating Pester Tets.ps1"

## DEMO 6 - Creating the Tests
ii "$demoPath\Introduction\Cleanup.ps1"

## DEMO 7 - Putting it all together
ii "$demoPath\New-TestEnvironment.Tests.ps1"

$invPesterParams = @{
    Path = "$demoPath\Project\New-TestEnvironment.Tests.ps1"
}

################### All tests passing ##########################
## Invoke default set of tests
Invoke-Pester -Script $invPesterParams -Verbose

## Invoke the full test suite of tests but just exit if a dependency was not met
Invoke-Pester -Script ($invPesterParams + @{ Parameters = @{ Full = $true } }) -Verbose

## Invoke the full test suite AND build all the dependencies
Invoke-Pester -Script ($invPesterParams + @{ Parameters = @{ Full = $true; DependencyFailureAction = 'Build' } }) -Verbose

################### Dependency failure ##########################

## Stop the VM just to fail the dependency check
$hyperVCred = (Import-Clixml -Path "$demoPath\Project\HyperVCredential.xml")
$hyperVSrv = 'HYPERVSRV'
Invoke-Command -ComputerName $hyperVSrv -ScriptBlock { Get-Vm -Name 'TESTLABDC' | Stop-Vm -Force }

## Invoke default set of tests --this will fail miserably due to no dep checks
## We're not doing this now because it just hangs. It has no idea of it's own dependencies.
# Invoke-Pester -Script $invPesterParams -Verbose

## Invoke the full test suite of tests but just exit if a dependency was not met --this will see a dep is missing and fail
Invoke-Pester -Script ($invPesterParams + @{ Parameters = @{ Full = $true } }) -Verbose

## Invoke the full test suite AND build all the dependencies --this will notice the missing dep and correct it
Invoke-Pester -Script ($invPesterParams + @{ Parameters = @{ Full = $true; DependencyFailureAction = 'Build' } }) -Verbose

## The VM should now have been tested and is back in the state we left it.
Invoke-Command -ComputerName $hyperVSrv -ScriptBlock { Get-Vm -Name 'TESTLABDC' }