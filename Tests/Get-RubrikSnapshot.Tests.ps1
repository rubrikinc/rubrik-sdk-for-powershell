# Import
Import-Module -Name "$PSScriptRoot\..\Rubrik" -Force
. "$(Split-Path -Parent -Path $PSScriptRoot)\Rubrik\Private\Get-RubrikAPIData.ps1"
$resources = GetRubrikAPIData -endpoint ('VMwareVMSnapshotGet')

# Pester

Describe -Name 'Get-RubrikSnapshot Tests' -Fixture {
  
}