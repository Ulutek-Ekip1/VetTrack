# VetTrack Backend Run Script for PowerShell
# Loads environment variables from .env and runs the Spring Boot application

if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
            $name, $value = $line -split '=', 2
            [System.Environment]::SetEnvironmentVariable($name.Trim(), $value.Trim())
        }
    }
    Write-Host "Environment variables successfully loaded from .env" -ForegroundColor Green
} else {
    Write-Warning ".env file not found in the backend directory! Spring Boot may fail to start."
}

.\mvnw spring-boot:run -Dspring-boot.run.profiles=local
