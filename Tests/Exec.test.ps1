
<#
.Synopsis
	Examples and test cases of Invoke-Exec (exec).

.Example
	Invoke-Build * Exec.test.ps1
#>

. .\Shared.ps1

task ExecWorksCode0 {
	$script:ExecWorksCode0 = exec { cmd /c echo Code0 }
}

task ExecWorksCode42 {
	$script:ExecWorksCode42 = exec { cmd /c 'echo Code42&& exit 42' } (40..50)
	equals $LastExitCode 42
}

task ExecFailsCode13 {
	exec { cmd /c exit 13 }
}

task ExecFailsBadCommand {
	exec { throw 'throw in ExecFailsBadCommand' }
}

# The default task calls the others and tests results.
# Note use of @{} for failing tasks.
task . `
ExecWorksCode0,
ExecWorksCode42,
(job ExecFailsCode13 -Safe),
(job ExecFailsBadCommand -Safe),
{
	equals $script:ExecWorksCode0 'Code0'
	equals $script:ExecWorksCode42 'Code42'
	Test-Error ExecFailsCode13 'Command { cmd /c exit 13 } exited with code 13.*At *\Exec.test.ps1:*{ cmd /c exit 13 }*'
	Test-Error ExecFailsBadCommand "throw in ExecFailsBadCommand*At *\Exec.test.ps1:*'throw in ExecFailsBadCommand'*"
}
