PROJECT(CHOLMOD)

include_directories("${suitesparseconfig_SOURCE_DIR}")
include_directories("${AMD_SOURCE_DIR}/Include")
include_directories("${CAMD_SOURCE_DIR}/Include")
include_directories("${COLAMD_SOURCE_DIR}/Include")
include_directories("${CCOLAMD_SOURCE_DIR}/Include")

IF (USE_METIS)
    include_directories("${METIS_INCLUDE_PATH}")
ENDIF()

# Headers:
include_directories("${CHOLMOD_SOURCE_DIR}/Include")
FILE(GLOB LIBHDRS "${CHOLMOD_SOURCE_DIR}/Include/*.h")
FILE(GLOB LIBSRCS "SourceWrappers/*.c")


declare_suitesparse_library(cholmod "${LIBSRCS}" "${LIBHDRS}"
	TARGET_PRIVATE_LINK	${METIS_LIBS} ${SuiteSparse_LINKER_LAPACK_BLAS_LIBS}
	TARGET_PUBLIC_LINK amd camd colamd ccolamd
)

