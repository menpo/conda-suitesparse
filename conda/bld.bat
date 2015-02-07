setlocal ENABLEDELAYEDEXPANSION

robocopy %RECIPE_DIR%\.. . /E /NFL /NDL

mkdir build
rem Patch for Metis 5
patch -p0 < metis5_idx.patch
cd build

rem Need to handle Python 3.x case at some point (Visual Studio 2010)
if %ARCH%==32 (
  if %PY_VER% LSS 3 (
    set CMAKE_GENERATOR="Visual Studio 9 2008"
    set CMAKE_CONFIG="Release"
  )
)
if %ARCH%==64 (
  if %PY_VER% LSS 3 (
    set CMAKE_GENERATOR="Visual Studio 9 2008 Win64"
    set CMAKE_CONFIG="Release"
  )
)

rem STATIC LIBRARIES
rem Replace backward slashes with forward slashes
rem to avoid escaping in CMAKE
set WIN_METIS_PATH="%LIBRARY_LIB%\metis.lib"
set UNIX_METIS_PATH=%WIN_METIS_PATH:\=/%

cmake .. -G%CMAKE_GENERATOR% ^
-DLIB_POSTFIX="" ^
-DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
-DUSE_METIS=1 ^
-DMETIS_LIB="%UNIX_METIS_PATH%" ^
-DMETIS_INCLUDE_PATH="%LIBRARY_INC%" ^
-DSUITESPARSE_CUSTOM_BLAS_DLL="%LIBRARY_BIN%\libopenblas.dll" ^
-DSUITESPARSE_CUSTOM_BLAS_LIB="%LIBRARY_LIB%\libopenblas.lib"

cmake --build . --config %CMAKE_CONFIG% --target ALL_BUILD
cmake --build . --config %CMAKE_CONFIG% --target INSTALL

rem SHARED LIBRARIES
cmake .. -G%CMAKE_GENERATOR% ^
-DLIB_POSTFIX="" ^
-DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
-DUSE_METIS=1 ^
-DMETIS_LIB="%UNIX_METIS_PATH%" ^
-DMETIS_INCLUDE_PATH="%LIBRARY_INC%" ^
-DBUILD_SHARED_LIBS=1 ^
-DSUITESPARSE_CUSTOM_BLAS_DLL="%LIBRARY_BIN%\libopenblas.dll" ^
-DSUITESPARSE_CUSTOM_BLAS_LIB="%LIBRARY_LIB%\libopenblas.lib"

cmake --build . --config %CMAKE_CONFIG% --target ALL_BUILD
cmake --build . --config %CMAKE_CONFIG% --target INSTALL

if errorlevel 1 exit 1
