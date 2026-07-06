@echo off
rem FIX: pre-expand %~dp0 into a variable, then use single-level
rem backslash-escaped quotes around the path instead of nesting
rem doubled double-quotes inside a single-quoted string inside a
rem double-quoted -Command. The old version could fail to launch
rem if the script's folder path contained a space.
set "SCRIPT_DIR=%~dp0"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%SCRIPT_DIR%DriveManager.ps1\"' -Verb RunAs"
