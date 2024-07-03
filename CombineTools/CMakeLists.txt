cmake_minimum_required( VERSION 3.11 FATAL_ERROR )
set(CMAKE_CXX_STANDARD 17)
project(CMSHarvester VERSION 0.0.1)

list(APPEND CMAKE_PREFIX_PATH $ENV{ROOTSYS})
find_package( ROOT REQUIRED COMPONENTS Core MathMore RooFitCore RooFit RooStats Minuit HistFactory RooFitHS3)
find_package(Eigen3 REQUIRED)
find_package(Vdt)
find_package(LCG QUIET) # only used for FindBoost in StatAnalysis
find_package( Boost REQUIRED COMPONENTS program_options filesystem )

message(STATUS "Using ROOT From: ${ROOT_INCLUDE_DIRS}")
include(${ROOT_USE_FILE})

include_directories(${ROOT_INCLUDE_DIRS})
include_directories(BEFORE ${CMAKE_CURRENT_SOURCE_DIR})
add_definitions(${ROOT_CXX_FLAGS})

set(LIBNAME CMSHarvester)

file(GLOB HEADERS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} interface/*.h*)
file(GLOB SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} src/*.c*)

# includes require "CombineHarvester/CombineTools" prefix in many places
# so create a symlink in the build dir
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/CombineHarvester)
execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/CombineHarvester/CombineTools" )
include_directories(${CMAKE_CURRENT_BINARY_DIR})

ROOT_GENERATE_DICTIONARY(G__${LIBNAME} CombineHarvester/CombineTools/src/classes.h LINKDEF src/classes_def.xml
        MODULE ${LIBNAME}
        OPTIONS --deep)
add_library(${LIBNAME} SHARED ${SOURCES} G__${LIBNAME}.cxx)
set_target_properties(${LIBNAME} PROPERTIES PUBLIC_HEADER "${HEADERS}")
target_link_libraries (${LIBNAME} Eigen3::Eigen ${ROOT_LIBRARIES} ${Boost_LIBRARIES} VDT::VDT)

#FIXME  add_executable(combine bin/combine.cpp)
#target_link_libraries(combine PUBLIC ${LIBNAME})

# Create empty __init__.py file in the build directory that will be installed
# in the Python library directories.
set(empty_init_py "${CMAKE_CURRENT_BINARY_DIR}/__init__.py")

# Install the dictionaries.
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/lib${LIBNAME}_rdict.pcm
        ${CMAKE_CURRENT_BINARY_DIR}/lib${LIBNAME}.rootmap
        DESTINATION lib)

# Install the libraries and header files.
install(TARGETS ${LIBNAME}
        LIBRARY DESTINATION lib
        PUBLIC_HEADER DESTINATION include/CombineHarvester/CombineTools/interface
        )
# dictionary requires classes.h to be in include path exactly as it was specified
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/CombineHarvester/CombineTools/src/classes.h
        DESTINATION include/CombineHarvester/CombineTools/src)

# Install the "combine" executable in the bin directory.
#FIXME install(TARGETS combine DESTINATION bin)

# Install the scripts like "text2workspace" to the bin directory.
install(DIRECTORY scripts/ DESTINATION bin)

set(Python_SITELIB_IN_PREFIX "python")

message (STATUS "Using Python install location:" ${Python_SITELIB_IN_PREFIX})
# The python package will be installed in such a way that the original
# CMSSW-style directory structure is kept, for maximal compatibility.
install(DIRECTORY python/ DESTINATION ${Python_SITELIB_IN_PREFIX}/CombineHarvester/CombineTools)

# Create empty __init__.py files in the Python package subdirectories such that
# the Python imports work.
file(TOUCH ${empty_init_py})
INSTALL(FILES ${empty_init_py} DESTINATION ${Python_SITELIB_IN_PREFIX}/CombineHarvester)
INSTALL(FILES ${empty_init_py} DESTINATION ${Python_SITELIB_IN_PREFIX}/CombineHarvester/CombineTools)
