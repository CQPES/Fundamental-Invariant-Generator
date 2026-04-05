cmake_minimum_required(VERSION 3.18)

project(FI_Generator LANGUAGES Fortran)

set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -O3 -qopenmp -heap-arrays -warn -module mod")

find_package(MKL REQUIRED CONFIG)

set(CMAKE_Fortran_MODULE_DIRECTORY ${PROJECT_BINARY_DIR}/mod)

file(GLOB_RECURSE SOURCES "src/*.f90")

add_executable(invariants
    "src/modules.f90"
    ${SOURCES}
)

target_link_libraries(invariants PRIVATE MKL::MKL)

set_target_properties(invariants PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bin"
)
