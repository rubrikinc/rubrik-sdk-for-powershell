    # Create new markdown and XML help files
Write-Host "Building new function documentation" -ForegroundColor Yellow
New-MarkdownHelp -Module Rubrik -OutputFolder "$env:LocalPath\docs\reference\" -Force
New-ExternalHelp -Path "$env:LocalPath\docs\reference\" -OutputPath "$env:LocalPath\Rubrik\en-US\" -Force



$StageFolder = '.\compiled_docs'

# Create a Staging folder and copy items in for compiling
$null = New-Item -Path $StageFolder -ItemType:Directory
Copy-Item -Path '.\*.md' -Destination $StageFolder -Force
Copy-Item -Path '.\docs\*' -Destination $StageFolder -Recurse -Force

# Build the book
Push-Location -Path $StageFolder
gitbook install
gitbook build
Pop-Location

# Copy the new book items into the docs folder
Remove-Item -Path '.\docs\' -Include *.html -Recurse -Force
Copy-Item -Path "$StageFolder\_book\*" -Destination '.\docs\' -Recurse -Force
Remove-Item -Path $StageFolder -Recurse -Force