@echo off
rem VetTrack Backend Run Script for Windows Command Prompt (CMD)
rem Loads environment variables from .env and runs the Spring Boot application

if exist .env (
    for /F "usebackq tokens=*" %%i in (`findstr /V "^#" .env`) do (
        set %%i
    )
    echo Environment variables successfully loaded from .env
) else (
    echo WARNING: .env file not found in the backend directory! Spring Boot may fail to start.
)

call mvnw spring-boot:run
