@echo off
echo %CD%
echo %DATE%
echo %TIME%

for %%t in (*.bat *.txt) do type %%t
pause
