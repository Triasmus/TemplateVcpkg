cmake_minimum_required(VERSION 3.24)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/CppShared/cmake)
include(preproject)
include(xpfunmac)
set(VERSION 0.0.0.0)
project(TemplateVcpkg VERSION ${VERSION})
set(CMAKE_CXX_STANDARD 20)
xpSetFlags()
xpSourceDirIgnore(CppShared/cmake)
xpSourceDirIgnore(Test)

include(vcpkg/scripts/buildsystems/vcpkg.cmake)

set(Boost_NO_WARN_NEW_VERSIONS true)

find_package(cpr REQUIRED) # Has cpr::cpr
find_package(magic_enum CONFIG REQUIRED) # Has magic_enum::magic_enum
find_package(OpenSSL REQUIRED) # Has OpenSSL::SSL OpenSSL::Crypto
find_package(spdlog CONFIG REQUIRED) # Has spdlog::spdlog spdlog::spdlog_header_only
find_package(stduuid CONFIG REQUIRED) # Has stduuid

find_package(Boost REQUIRED COMPONENTS json unit_test_framework)
if (Boost_FOUND)
    include_directories(${Boost_INCLUDE_DIRS})
    link_directories(${Boost_LIBRARY_DIRS})
endif ()

add_subdirectory(CppShared)
add_subdirectory(Playground)
add_subdirectory(SolutionName)

if(UNIX)
  set(CPACK_GENERATOR RPM)
elseif(WIN32)
  set(CPACK_GENERATOR ZIP)
endif()
set(CPACK_PACKAGE_NAME "TemplateVcpkg")
set(CPACK_PACKAGE_VENDOR "Triasmus")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${CPACK_PACKAGE_NAME} Revision ${VERSION}")
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${VERSION}")
set(CPACK_PACKAGE_VERSION ${VERSION})
include(CPack)
