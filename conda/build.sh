#!/bin/bash

cp -r "$RECIPE_DIR/../" .

mkdir build

# Patch for Metis 5
patch -p0 < metis5_idx.patch

cd build

# Create the static libraries
cmake .. \
-DLIB_POSTFIX="" \
-DCMAKE_INSTALL_PREFIX=$PREFIX \
-DUSE_METIS=0 \
-DMETIS_LIB_PATH="$LIBRARY_PATH/libmetis.a" \
-DMETIS_INCLUDE_PATH=$INCLUDE_PATH

# I have no idea how to stop the CMake from putting -lrt
# inside the link.txt, so I've had to improvise by sed'ing it out
#if [ "$(uname -s)" == "Darwin" ]; then
#  sed -i"bak" 's/-lrt//' SuiteSparse/UMFPACK/CMakeFiles/umfpack.dir/link.txt
#  sed -i"bak" 's/-lrt//' SuiteSparse/SPQR/CMakeFiles/spqr.dir/link.txt
#  sed -i"bak" 's/-lrt//' SuiteSparse/CHOLMOD/CMakeFiles/cholmod.dir/link.txt
#fi

make -j$CPU_COUNT
make install

# Create the SHARED libraries
cmake .. \
-DBUILD_SHARED_LIBS=1 \
-DLIB_POSTFIX="" \
-DUSE_METIS=0 \
-DMETIS_LIB_PATH="$LIBRARY_PATH/libmetis.so" \
-DMETIS_INCLUDE_PATH=$INCLUDE_PATH \
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

