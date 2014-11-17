#!/bin/bash

cp -r "$RECIPE_DIR/../" .

mkdir build

if [ "$(uname -s)" == "Darwin" ]; then
  mv "./SuiteSparse/SuiteSparse_config/SuiteSparse_config_Mac.mk" "./SuiteSparse/SuiteSparse_config/SuiteSparse_config.mk"
fi

# Patch for Metis 5
patch -p0 < metis5_idx.patch

cd build

cmake .. \
-DLIB_POSTFIX="" \
-DSHARED=1 \
-DBUILD_METIS=1 \
-DGKLIB_PATH="$RECIPE_DIR/../metis/GKlib" \
-DCMAKE_INSTALL_PREFIX=$PREFIX

# I have no idea how to stop the CMake from putting -lrt
# inside the link.txt, so I've had to improvise by sed'ing it out
if [ "$(uname -s)" == "Darwin" ]; then
  sed -i"bak" 's/-lrt//' SuiteSparse/UMFPACK/CMakeFiles/umfpack.dir/link.txt
  sed -i"bak" 's/-lrt//' SuiteSparse/SPQR/CMakeFiles/spqr.dir/link.txt
  sed -i"bak" 's/-lrt//' SuiteSparse/CHOLMOD/CMakeFiles/cholmod.dir/link.txt
fi

make -j$CPU_COUNT
make install

# Metis seems to want to make this lib64 folder?
rm -fr $PREFIX/lib64
