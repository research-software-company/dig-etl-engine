xcopy /s %SRC_DIR% %BUILD_PREFIX%

copy %SRC_DIR%\conda\.env.conda %BUILD_PREFIX%\.env

mkdir %BUILD_PREFIX%\mydig-projects
REM Make sure the mydig-projects has a dummy file, so it is created when installing the conda package
echo dummy > %BUILD_PREFIX%\mydig-projects\dummy

