# ##############################################################################
# xpfunmac.cmake
#  xp prefix = intended to be used both internally (by externpro) and externally
#  ip prefix = intended to be used only internally by externpro
#  fun = functions
#  mac = macros
# functions and macros should begin with xp or ip prefix
# functions create a local scope for variables, macros use the global scope

set(xpThisDir ${CMAKE_CURRENT_LIST_DIR})
include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)
include(CMakeDependentOption)

function(xpListAppendTrailingSlash var)
  set(listVar)
  foreach(f ${ARGN})
    if(IS_DIRECTORY ${f})
      list(APPEND listVar "${f}/")
    else()
      list(APPEND listVar "${f}")
    endif()
  endforeach()
  set(${var} "${listVar}" PARENT_SCOPE)
endfunction()

function(xpListRemoveFromAll var match replace)
  set(listVar)
  foreach(f ${ARGN})
    string(REPLACE "${match}" "${replace}" f ${f})
    list(APPEND listVar ${f})
  endforeach()
  set(${var} "${listVar}" PARENT_SCOPE)
endfunction()

function(xpStringTrim str)
  if("${${str}}" STREQUAL "")
    return()
  endif()
  # remove leading and trailing spaces with STRIP
  string(STRIP ${${str}} stripped)
  set(${str} ${stripped} PARENT_SCOPE)
endfunction()

function(xpStringAppendIfDne appendTo str)
  if("${${appendTo}}" STREQUAL "")
    set(${appendTo} ${str} PARENT_SCOPE)
  else()
    string(FIND ${${appendTo}} ${str} pos)
    if(${pos} EQUAL -1)
      set(${appendTo} "${${appendTo}} ${str}" PARENT_SCOPE)
    endif()
  endif()
endfunction()

function(xpStringRemoveIfExists removeFrom str)
  if("${${removeFrom}}" STREQUAL "")
    return()
  endif()
  string(FIND ${${removeFrom}} ${str} pos)
  if(${pos} EQUAL -1)
    return()
  endif()
  string(REPLACE " ${str}" "" res ${${removeFrom}})
  string(REPLACE "${str} " "" res ${${removeFrom}})
  string(REPLACE ${str} "" res ${${removeFrom}})
  xpStringTrim(res)
  set(${removeFrom} ${res} PARENT_SCOPE)
endfunction()

function(xpGitIgnoredDirs var dir)
  if(NOT GIT_FOUND)
    include(FindGit)
    find_package(Git)
  endif()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} ls-files --exclude-standard --ignored --others --directory
    WORKING_DIRECTORY ${dir}
    ERROR_QUIET
    OUTPUT_VARIABLE ignoredDirs
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  string(REPLACE ";" "\\\\;" ignoredDirs "${ignoredDirs}")
  string(REPLACE "\n" ";" ignoredDirs "${ignoredDirs}")
  list(APPEND ignoredDirs ${ARGN})
  list(TRANSFORM ignoredDirs PREPEND ${dir}/)
  set(${var} "${ignoredDirs}" PARENT_SCOPE)
endfunction()

function(xpGitIgnoredFiles var dir)
  if(NOT GIT_FOUND)
    include(FindGit)
    find_package(Git)
  endif()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} ls-files --exclude-standard --ignored --others
    WORKING_DIRECTORY ${dir}
    ERROR_QUIET
    OUTPUT_VARIABLE ignoredFiles
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  string(REPLACE ";" "\\\\;" ignoredFiles "${ignoredFiles}")
  string(REPLACE "\n" ";" ignoredFiles "${ignoredFiles}")
  list(TRANSFORM ignoredFiles PREPEND ${dir}/)
  set(${var} "${ignoredFiles}" PARENT_SCOPE)
endfunction()

function(xpGitUntrackedFiles var dir)
  if(NOT GIT_FOUND)
    include(FindGit)
    find_package(Git)
  endif()
  execute_process(
    COMMAND ${GIT_EXECUTABLE} ls-files --exclude-standard --others
    WORKING_DIRECTORY ${dir}
    ERROR_QUIET
    OUTPUT_VARIABLE untrackedFiles
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  string(REPLACE ";" "\\\\;" untrackedFiles "${untrackedFiles}")
  string(REPLACE "\n" ";" untrackedFiles "${untrackedFiles}")
  list(TRANSFORM untrackedFiles PREPEND ${dir}/)
  set(${var} "${untrackedFiles}" PARENT_SCOPE)
endfunction()

function(xpGlobFiles var item)
  set(globexpr ${ARGN})
  if(IS_DIRECTORY ${item})
    string(REGEX REPLACE "/$" "" item ${item}) # remove trailing slash
    list(TRANSFORM globexpr PREPEND ${item}/)
    # NOTE: By default GLOB_RECURSE omits directories from result list
    file(GLOB_RECURSE dirFiles ${globexpr})
    xpGitUntrackedFiles(untrackedFiles ${item})
    xpGitIgnoredFiles(ignoredFiles ${item})
    list(APPEND untrackedFiles ${ignoredFiles})
    if(dirFiles AND untrackedFiles)
      list(REMOVE_ITEM dirFiles ${untrackedFiles})
    endif()
    list(APPEND listVar ${dirFiles})
  else()
    get_filename_component(dir ${item} DIRECTORY)
    list(TRANSFORM globexpr PREPEND ${dir}/)
    file(GLOB match ${globexpr})
    list(FIND match ${item} idx)
    if(NOT ${idx} EQUAL -1)
      list(APPEND listVar ${item})
    endif()
  endif()
  set(${var} ${${var}} ${listVar} PARENT_SCOPE)
endfunction()

macro(xpSourceListAppend)
  set(_dir ${CMAKE_CURRENT_SOURCE_DIR})
  if(EXISTS ${_dir}/CMakeLists.txt)
    list(APPEND masterSrcList ${_dir}/CMakeLists.txt)
  endif()
  if(DEFINED unclassifiedSrcList)
    list(APPEND masterSrcList ${unclassifiedSrcList})
  endif()
  if(${ARGC} GREATER 0)
    foreach(f ${ARGN})
      # remove any relative parts with get_filename_component call
      # as this will help REMOVE_DUPLICATES
      if(IS_ABSOLUTE ${f})
        get_filename_component(f ${f} ABSOLUTE)
      else()
        get_filename_component(f ${_dir}/${f} ABSOLUTE)
      endif()
      list(APPEND masterSrcList ${f})
    endforeach()
  endif()
  file(
    GLOB miscFiles
    LIST_DIRECTORIES false
    ${_dir}/.git*
    ${_dir}/*clang-format
    ${_dir}/.crtoolrc
    ${_dir}/docker-compose.*
    ${_dir}/README.md
    ${_dir}/version.cmake
  )
  if(miscFiles)
    list(APPEND masterSrcList ${miscFiles})
    file(RELATIVE_PATH relPath ${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
    string(REPLACE "/" "" custTgt .CMake${relPath})
    if(NOT TARGET ${custTgt})
      if(EXISTS ${_dir}/.codereview)
        file(GLOB crFiles "${_dir}/.codereview/*")
        source_group(".codereview" FILES ${crFiles})
        list(APPEND masterSrcList ${crFiles})
      endif()
      if(EXISTS ${_dir}/.devcontainer)
        file(GLOB_RECURSE dcFiles "${_dir}/.devcontainer" "${_dir}/.devcontainer/*")
        source_group(".devcontainer" FILES ${dcFiles})
        list(APPEND masterSrcList ${dcFiles})
      endif()
      if(EXISTS ${_dir}/.github)
        file(GLOB_RECURSE github_yml "${_dir}/.github/workflows/*.yml")
        source_group(".github.yml" FILES ${github_yml})
        list(APPEND masterSrcList ${github_yml})
      endif()
      add_custom_target(${custTgt} SOURCES ${miscFiles} ${crFiles} ${dcFiles} ${github_yml})
      set_property(TARGET ${custTgt} PROPERTY FOLDER ${folder})
    endif()
  endif()
  if(NOT ${CMAKE_BINARY_DIR} STREQUAL ${CMAKE_CURRENT_BINARY_DIR})
    set(masterSrcList "${masterSrcList}" PARENT_SCOPE)
    set(XP_SOURCE_DIR_IGNORE ${XP_SOURCE_DIR_IGNORE} PARENT_SCOPE)
  else()
    list(REMOVE_DUPLICATES masterSrcList)
    if(EXISTS ${CMAKE_SOURCE_DIR}/.git)
      if(NOT GIT_FOUND)
        include(FindGit)
        find_package(Git)
      endif()
      xpGitIgnoredDirs(ignoredDirs ${CMAKE_SOURCE_DIR} .git/)
      xpGitUntrackedFiles(untrackedFiles ${CMAKE_SOURCE_DIR})
      file(GLOB topdir ${_dir}/*)
      xpListAppendTrailingSlash(topdir ${topdir})
      list(REMOVE_ITEM topdir ${ignoredDirs} ${untrackedFiles})
      list(SORT topdir) # sort list in-place alphabetically
      foreach(item ${topdir})
        xpGlobFiles(repoFiles ${item} *)
      endforeach()
      set(fmtFiles ${repoFiles})
      list(
        FILTER
        fmtFiles
        INCLUDE
        REGEX
        "^.*\\.(c|h|cpp|hpp|cu|cuh|proto)$"
      )
      foreach(item ${XP_SOURCE_DIR_IGNORE})
        xpGlobFiles(ignoreFiles ${item} *)
      endforeach()
      list(REMOVE_ITEM repoFiles ${masterSrcList} ${ignoreFiles})
      if(DEFINED NV_CMAKE_REPO_INSYNC)
        option(XP_CMAKE_REPO_INSYNC "cmake error if repo and cmake are not in sync"
               ${NV_CMAKE_REPO_INSYNC}
        )
      else()
        option(XP_CMAKE_REPO_INSYNC "cmake error if repo and cmake are not in sync" OFF)
      endif()
      mark_as_advanced(XP_CMAKE_REPO_INSYNC)
      if(repoFiles)
        string(REPLACE ";" "\n" repoFilesTxt "${repoFiles}")
        file(WRITE ${CMAKE_BINARY_DIR}/notincmake.txt ${repoFilesTxt}\n)
        list(APPEND masterSrcList ${CMAKE_BINARY_DIR}/notincmake.txt)
        if(XP_CMAKE_REPO_INSYNC)
          message("")
          message(STATUS "***** FILE(S) IN REPO, BUT NOT IN CMAKE *****")
          foreach(abs ${repoFiles})
            string(REPLACE ${CMAKE_SOURCE_DIR}/ "" rel ${abs})
            message(STATUS ${rel})
          endforeach()
          message("")
          message(FATAL_ERROR "repo and cmake are out of sync, see file(s) listed above. "
                              "See also \"${CMAKE_BINARY_DIR}/notincmake.txt\"."
          )
        endif()
      elseif(EXISTS ${CMAKE_BINARY_DIR}/notincmake.txt)
        file(REMOVE ${CMAKE_BINARY_DIR}/notincmake.txt)
      endif()
      ####
      # Windows can't handle passing very many files to clang-format
      if(NOT MSVC AND fmtFiles)
        # make paths relative to CMAKE_SOURCE_DIR
        xpListRemoveFromAll(fmtFiles ${CMAKE_SOURCE_DIR} . ${fmtFiles})
        list(LENGTH fmtFiles lenFmtFiles)
        # NOTE: externpro doesn't have usexp-clangformat-config.cmake at cmake time
        if(NOT CMAKE_PROJECT_NAME STREQUAL externpro)
          xpGetPkgVar(clangformat EXE)
          add_custom_command(
            OUTPUT format_cmake COMMAND ${CLANGFORMAT_EXE} -style=file -i ${fmtFiles}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            COMMENT "Running clang-format on ${lenFmtFiles} files..."
          )
        endif()
        string(REPLACE ";" "\n" fmtFiles "${fmtFiles}")
        file(WRITE ${CMAKE_BINARY_DIR}/formatfiles.txt ${fmtFiles}\n)
        list(APPEND masterSrcList ${CMAKE_BINARY_DIR}/formatfiles.txt)
        if(NOT TARGET format)
          add_custom_target(format SOURCES ${CMAKE_BINARY_DIR}/formatfiles.txt DEPENDS format_cmake)
          set_property(TARGET format PROPERTY FOLDER CMakeTargets)
        endif()
      endif()
    endif() # is a .git repo
    find_program(XP_DOT_EXE "dot")
    mark_as_advanced(XP_DOT_EXE)
    if(XP_DOT_EXE)
      option(XP_GRAPHVIZ "create a \${CMAKE_BINARY_DIR}/CMakeGraphVizOptions.cmake file" ON)
      mark_as_advanced(XP_GRAPHVIZ)
      if(NOT DEFINED XP_GRAPHVIZ_PRIVATE_DEPS)
        set(NV_GRAPHVIZ_PRIVATE_DEPS ON) # (NV: normal variable)
      else()
        set(NV_GRAPHVIZ_PRIVATE_DEPS ${XP_GRAPHVIZ_PRIVATE_DEPS})
        unset(XP_GRAPHVIZ_PRIVATE_DEPS)
      endif()
      cmake_dependent_option(
        XP_GRAPHVIZ_PRIVATE_DEPS
        "keep private dependencies in graph"
        ${NV_GRAPHVIZ_PRIVATE_DEPS}
        "XP_GRAPHVIZ"
        ON
      )
      mark_as_advanced(XP_GRAPHVIZ_PRIVATE_DEPS)
      if(XP_GRAPHVIZ)
        if(NOT XP_GRAPHVIZ_PRIVATE_DEPS)
          configure_file(${xpThisDir}/graphPvtClean.sh.in graphPvtClean.sh @ONLY NEWLINE_STYLE LF)
          set(graphPvtClean COMMAND ./graphPvtClean.sh)
        endif()
        if(NOT TARGET graph)
          add_custom_command(
            OUTPUT graph_cmake
            COMMAND ${CMAKE_COMMAND} --graphviz=${CMAKE_PROJECT_NAME}.dot . ${graphPvtClean}
            COMMAND dot -Tpng -o${CMAKE_PROJECT_NAME}.png ${CMAKE_PROJECT_NAME}.dot
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Generating ${CMAKE_PROJECT_NAME}.dot and ${CMAKE_PROJECT_NAME}.png..."
          )
          add_custom_target(
            graph SOURCES ${CMAKE_BINARY_DIR}/CMakeGraphVizOptions.cmake DEPENDS graph_cmake
          )
          set_property(TARGET graph PROPERTY FOLDER CMakeTargets)
        endif()
        set(opts "# Generating Dependency Graphs with CMake\n")
        set(opts "${opts}# https://gitlab.kitware.com/cmake/community/-/wikis/doc/cmake/Graphviz\n")
        set(opts "${opts}# https://cmake.org/cmake/help/latest/module/CMakeGraphVizOptions.html\n")
        set(opts "${opts}# cmake --graphviz=${CMAKE_PROJECT_NAME}.dot ..\n")
        set(opts "${opts}# dot -Tpng -o${CMAKE_PROJECT_NAME}.png ${CMAKE_PROJECT_NAME}.dot\n")
        foreach(stringOpt GRAPH_NAME GRAPH_HEADER NODE_PREFIX IGNORE_TARGETS)
          if(DEFINED GRAPHVIZ_${stringOpt})
            set(opts "${opts}set(GRAPHVIZ_${stringOpt}")
            foreach(str ${GRAPHVIZ_${stringOpt}})
              set(opts "${opts} \"${str}\"")
            endforeach()
            set(opts "${opts})\n")
          endif()
        endforeach()
        foreach(
          boolOpt
          EXECUTABLES
          STATIC_LIBS
          SHARED_LIBS
          MODULE_LIBS
          INTERFACE_LIBS
          OBJECT_LIBS
          UNKNOWN_LIBS
          EXTERNAL_LIBS
          CUSTOM_TARGETS
          GENERATE_PER_TARGET
          GENERATE_DEPENDERS
        )
          if(DEFINED GRAPHVIZ_${boolOpt})
            set(opts "${opts}set(GRAPHVIZ_${boolOpt} ${GRAPHVIZ_${boolOpt}})\n")
          endif()
        endforeach()
        file(WRITE ${CMAKE_BINARY_DIR}/CMakeGraphVizOptions.cmake ${opts})
      endif() # XP_GRAPHVIZ
    endif() # XP_DOT_EXE
    option(XP_CSCOPE "always update cscope database" OFF)
    mark_as_advanced(XP_CSCOPE)
    if(XP_CSCOPE)
      file(GLOB cscope_files ${CMAKE_BINARY_DIR}/cscope.*)
      list(LENGTH cscope_files len)
      if(NOT ${len} EQUAL 0)
        file(REMOVE ${cscope_files})
      endif()
      foreach(
        extn
        bmp
        docx
        gif
        ICO
        ico
        jpeg
        jpg
        ntf
        pdf
        png
        rtf
        vsd
        xcf
        xlsx
        zip
      )
        list(
          FILTER
          masterSrcList
          EXCLUDE
          REGEX
          "(.*).${extn}$"
        )
      endforeach()
      string(REPLACE ";" "\n" cscopeFileList "${masterSrcList}")
      file(WRITE ${CMAKE_BINARY_DIR}/cscope.files ${cscopeFileList}\n)
      message(STATUS "Generating cscope database")
      execute_process(COMMAND cscope -b -q -k -i cscope.files)
    endif()
  endif()
endmacro()

function(xpSourceDirIgnore)
  set(ignoredDirs ${ARGN})
  list(TRANSFORM ignoredDirs PREPEND ${CMAKE_CURRENT_SOURCE_DIR}/)
  list(APPEND XP_SOURCE_DIR_IGNORE ${ignoredDirs})
  set(XP_SOURCE_DIR_IGNORE ${XP_SOURCE_DIR_IGNORE} PARENT_SCOPE)
endfunction()

function(xpFindPkg)
  cmake_parse_arguments(
    FP
    ""
    ""
    PKGS
    ${ARGN}
  )
  foreach(pkg ${FP_PKGS})
    string(TOUPPER ${pkg} PKG)
    if(NOT ${PKG}_FOUND)
      string(TOLOWER ${pkg} pkg)
      unset(usexp-${pkg}_DIR CACHE)
      find_package(
        usexp-${pkg}
        REQUIRED
        PATHS
        ${XP_MODULE_PATH}
        NO_DEFAULT_PATH
      )
      mark_as_advanced(usexp-${pkg}_DIR)
      if(DEFINED ${PKG}_FOUND)
        list(APPEND reqVars ${PKG}_FOUND)
      else()
        message(AUTHOR_WARNING "${PKG}: no ${PKG}_FOUND defined")
      endif()
      foreach(var ${reqVars})
        set(${var} ${${var}} PARENT_SCOPE)
      endforeach()
    endif()
  endforeach()
endfunction()

function(xpGetPkgVar pkg)
  xpFindPkg(PKGS ${pkg})
  string(TOUPPER ${pkg} PKG)
  if(${PKG}_FOUND)
    foreach(var ${ARGN})
      string(TOUPPER ${var} VAR)
      if(DEFINED ${PKG}_${VAR})
        set(${PKG}_${VAR} ${${PKG}_${VAR}} PARENT_SCOPE)
      elseif(DEFINED ${pkg}_${VAR})
        set(${pkg}_${VAR} ${${pkg}_${VAR}} PARENT_SCOPE)
      elseif(DEFINED ${PKG}_${var})
        set(${PKG}_${var} ${${PKG}_${var}} PARENT_SCOPE)
      elseif(DEFINED ${pkg}_${var})
        set(${pkg}_${var} ${${pkg}_${var}} PARENT_SCOPE)
      endif()
    endforeach()
  endif()
endfunction()

function(xpEnforceOutOfSourceBuilds)
  # NOTE: could also check for in-source builds with the following:
  #if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  # make sure the user doesn't play dirty with symlinks
  get_filename_component(srcdir "${CMAKE_SOURCE_DIR}" REALPATH)
  # check for polluted source tree and disallow in-source builds
  if(EXISTS ${srcdir}/CMakeCache.txt OR EXISTS ${srcdir}/CMakeFiles)
    message("##########################################################")
    message("Found results from an in-source build in source directory.")
    message("Please delete:")
    message("  ${srcdir}/CMakeCache.txt (file)")
    message("  ${srcdir}/CMakeFiles (directory)")
    message("And re-run CMake from an out-of-source directory.")
    message("In-source builds are forbidden!")
    message("##########################################################")
    message(FATAL_ERROR)
  endif()
endfunction()

macro(xpEnableWarnings)
  if(CMAKE_COMPILER_IS_GNUCXX OR ${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
    check_cxx_compiler_flag("-Wall" has_Wall)
    if(has_Wall)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wall")
    endif()
    #-Wall turns on maybe_uninitialized warnings which can be spurious
    check_cxx_compiler_flag("-Wno-maybe-uninitialized" has_Wno_maybe_uninitialized)
    if(has_Wno_maybe_uninitialized)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wno-maybe-uninitialized")
    endif()
    check_cxx_compiler_flag("-Wextra" has_Wextra)
    if(has_Wextra)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wextra")
    endif()
    check_cxx_compiler_flag("-Wcast-align" has_cast_align)
    if(has_cast_align)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wcast-align")
    endif()
    check_cxx_compiler_flag("-pedantic" has_pedantic)
    if(has_pedantic)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-pedantic")
    endif()
    check_cxx_compiler_flag("-Wformat=2" has_Wformat)
    if(has_Wformat)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wformat=2")
    endif()
    check_cxx_compiler_flag("-Wfloat-equal" has_Wfloat_equal)
    if(has_Wfloat_equal)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wfloat-equal")
    endif()
    check_cxx_compiler_flag("-Wno-unknown-pragmas" has_nounkprag)
    if(has_nounkprag)
      # turn off unknown pragma warnings as we use MSVC pragmas
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wno-unknown-pragmas")
    endif()
    check_cxx_compiler_flag("-Wno-psabi" has_psabi)
    if(has_psabi)
      # turn off messages noting ABI passing structure changes in GCC
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wno-psabi")
    endif()
  endif()
endmacro()

function(xpToggleDebugInfo)
  if(MSVC)
    set(releaseCompiler "/O2 /Ob2")
    set(reldebCompiler "/Zi /O2 /Ob1")
    set(releaseLinker "/INCREMENTAL:NO")
    set(reldebLinker "/debug /INCREMENTAL")
  elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR ${CMAKE_C_COMPILER_ID} MATCHES
                                                                "Clang" OR ${CMAKE_CXX_COMPILER_ID}
                                                                           MATCHES "Clang"
  )
    set(releaseCompiler "-O3")
    set(reldebCompiler "-O2 -g")
  else()
    message(FATAL_ERROR "unknown compiler")
  endif()
  if(XP_BUILD_WITH_DEBUG_INFO)
    set(from release)
    set(to reldeb)
  else()
    set(from reldeb)
    set(to release)
  endif()
  foreach(flagVar ${ARGV})
    if(DEFINED ${flagVar})
      if(${flagVar} MATCHES ".*LINKER_FLAGS.*")
        if(DEFINED ${from}Linker AND DEFINED ${to}Linker)
          string(REGEX REPLACE "${${from}Linker}" "${${to}Linker}" flagTmp "${${flagVar}}")
          set(${flagVar} ${flagTmp} CACHE STRING "Flags used by the linker." FORCE)
        endif()
      else()
        if(${flagVar} MATCHES ".*CXX_FLAGS.*")
          set(cType "C++ ")
        elseif(${flagVar} MATCHES ".*C_FLAGS.*")
          set(cType "C ")
        endif()
        string(REGEX REPLACE "${${from}Compiler}" "${${to}Compiler}" flagTmp "${${flagVar}}")
        set(${flagVar} ${flagTmp} CACHE STRING "Flags used by the ${cType}compiler." FORCE)
      endif()
    endif()
  endforeach()
endfunction()

function(xpDebugInfoOption)
  cmake_dependent_option(
    XP_BUILD_WITH_DEBUG_INFO
    "build Release with debug information"
    OFF
    "DEFINED CMAKE_BUILD_TYPE;CMAKE_BUILD_TYPE STREQUAL Release"
    OFF
  )
  set(checkflags CMAKE_C_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELEASE)
  if(MSVC)
    list(
      APPEND
      checkflags
      CMAKE_EXE_LINKER_FLAGS_RELEASE
      CMAKE_MODULE_LINKER_FLAGS_RELEASE
      CMAKE_SHARED_LINKER_FLAGS_RELEASE
    )
  endif()
  xpToggleDebugInfo(${checkflags})
endfunction()

macro(xpCommonFlags)
  if(NOT DEFINED CMAKE_C_COMPILER_ID)
    set(CMAKE_C_COMPILER_ID NOTDEFINED)
  endif()
  if(NOT DEFINED CMAKE_CXX_COMPILER_ID)
    set(CMAKE_CXX_COMPILER_ID NOTDEFINED)
  endif()
  xpDebugInfoOption()
  if(MSVC)
    set(VCPKG_TARGET_TRIPLET "x64-windows-static")
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
      add_definitions(-DWIN64)
    endif()
    # Turn on Multi-processor Compilation
    xpStringAppendIfDne(CMAKE_C_FLAGS "/MP")
    xpStringAppendIfDne(CMAKE_CXX_FLAGS "/MP")
  elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR ${CMAKE_CXX_COMPILER_ID} MATCHES
                                                                "Clang"
  )
    if(CMAKE_BUILD_TYPE STREQUAL Debug)
      add_definitions(-D_DEBUG)
    endif()
    # C
    if(DEFINED CMAKE_C_COMPILER)
      include(CheckCCompilerFlag)
      check_c_compiler_flag("-fPIC" has_c_fPIC)
      if(has_c_fPIC)
        xpStringAppendIfDne(CMAKE_C_FLAGS "-fPIC")
        xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS "-fPIC")
        xpStringAppendIfDne(CMAKE_MODULE_LINKER_FLAGS "-fPIC")
        xpStringAppendIfDne(CMAKE_SHARED_LINKER_FLAGS "-fPIC")
      endif()
      check_c_compiler_flag("-msse3" has_c_msse3)
      if(has_c_msse3)
        xpStringAppendIfDne(CMAKE_C_FLAGS "-msse3")
      endif()
      check_c_compiler_flag("-fstack-protector-strong" has_c_StrongSP)
      if(has_c_StrongSP)
        xpStringAppendIfDne(CMAKE_C_FLAGS "-fstack-protector-strong")
      endif()
      if(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
        check_c_compiler_flag("-arch x86_64" has_c_arch)
        if(has_c_arch)
          xpStringAppendIfDne(CMAKE_C_FLAGS "-arch x86_64")
          xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS "-arch x86_64")
          xpStringAppendIfDne(CMAKE_MODULE_LINKER_FLAGS "-arch x86_64")
          xpStringAppendIfDne(CMAKE_SHARED_LINKER_FLAGS "-arch x86_64")
        endif()
      endif() # CMAKE_SYSTEM_NAME (Darwin)
    endif()
    # C++
    if(CMAKE_COMPILER_IS_GNUCXX OR ${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
      include(CheckCXXCompilerFlag)
      if(${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
        check_cxx_compiler_flag("-stdlib=libc++" has_libcxx)
        if(has_libcxx)
          xpStringAppendIfDne(CMAKE_CXX_FLAGS "-stdlib=libc++")
          xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS "-stdlib=libc++")
          xpStringAppendIfDne(CMAKE_MODULE_LINKER_FLAGS "-stdlib=libc++")
          xpStringAppendIfDne(CMAKE_SHARED_LINKER_FLAGS "-stdlib=libc++")
        endif()
      endif()
      check_cxx_compiler_flag("-fPIC" has_cxx_fPIC)
      if(has_cxx_fPIC)
        xpStringAppendIfDne(CMAKE_CXX_FLAGS "-fPIC")
        xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS "-fPIC")
        xpStringAppendIfDne(CMAKE_MODULE_LINKER_FLAGS "-fPIC")
        xpStringAppendIfDne(CMAKE_SHARED_LINKER_FLAGS "-fPIC")
      endif()
      check_cxx_compiler_flag("-msse3" has_cxx_msse3)
      if(has_cxx_msse3)
        xpStringAppendIfDne(CMAKE_CXX_FLAGS "-msse3")
      endif()
      check_cxx_compiler_flag("-fstack-protector-strong" has_cxx_StrongSP)
      if(has_cxx_StrongSP)
        xpStringAppendIfDne(CMAKE_CXX_FLAGS "-fstack-protector-strong")
      endif()
      if(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
        check_cxx_compiler_flag("-arch x86_64" has_cxx_arch)
        if(has_cxx_arch)
          xpStringAppendIfDne(CMAKE_CXX_FLAGS "-arch x86_64")
          xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS "-arch x86_64")
          xpStringAppendIfDne(CMAKE_MODULE_LINKER_FLAGS "-arch x86_64")
          xpStringAppendIfDne(CMAKE_SHARED_LINKER_FLAGS "-arch x86_64")
        endif()
      endif() # CMAKE_SYSTEM_NAME (Darwin)
    endif() # C++ (GNUCXX OR Clang)
  endif()
endmacro()

macro(xpSetFlagsMsvc)
  add_definitions(
    -D_CRT_NONSTDC_NO_DEPRECATE
    -D_CRT_SECURE_NO_WARNINGS
    -D_SCL_SECURE_NO_WARNINGS
    -D_WINSOCK_DEPRECATED_NO_WARNINGS
    -D_WIN32_WINNT=0x0601 #(Windows 7 target)
    -DWIN32_LEAN_AND_MEAN
  )
  xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS_DEBUG "/MANIFEST:NO")
  # Remove Linker > System > Stack Reserve Size setting
  string(REPLACE "/STACK:10000000" "" CMAKE_EXE_LINKER_FLAGS ${CMAKE_EXE_LINKER_FLAGS})
  # Add Linker > System > Enable Large Addresses
  xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS "/LARGEADDRESSAWARE")
  option(XP_BUILD_VERBOSE "use verbose compiler and linker options" OFF)
  if(XP_BUILD_VERBOSE)
    # Report the build times
    xpStringAppendIfDne(CMAKE_EXE_LINKER_FLAGS "/time")
    # Report the linker version (32/64-bit: x86_amd64/amd64)
    xpStringAppendIfDne(CMAKE_CXX_FLAGS "/Bv")
  endif()
  if(MSVC12)
    # Remove unreferenced data and functions
    # http://blogs.msdn.com/b/vcblog/archive/2014/03/25/linker-enhancements-in-visual-studio-2013-update-2-ctp2.aspx
    xpStringAppendIfDne(CMAKE_CXX_FLAGS "/Zc:inline")
  endif()
  # Increase the number of sections that an object file can contain
  # https://msdn.microsoft.com/en-us/library/ms173499.aspx
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "/bigobj")
  # Treat Warnings As Errors
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "/WX")
  # Warning level 3
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "/W3")
  # Treat the following warnings as errors (above and beyond Warning Level 3)
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "/we4238") # don't take address of temporaries
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "/we4239") # don't bind temporaries to non-const references
  # Disable the following warnings
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "/wd4503"
  )# decorated name length exceeded, name was truncated
  xpStringAppendIfDne(CMAKE_CXX_FLAGS "/wd4351"
  )# new behavior: elements of array will be default initialized
endmacro()

macro(xpSetFlagsGccDebug)
  if(NOT DEFINED XP_SANITIZER)
    set(NV_SANITIZER "NONE") # (NV: normal variable) 'cmake --help-policy CMP0077'
    if(XP_USE_ASAN)
      message(AUTHOR_WARNING "XP_USE_ASAN deprecated, use XP_SANITIZER=ASAN.")
      set(NV_SANITIZER "ASAN")
    endif()
  else()
    if(DEFINED XP_USE_ASAN)
      if(XP_SANITIZER STREQUAL "ASAN")
        message(AUTHOR_WARNING "XP_USE_ASAN deprecated, remove use.")
      else()
        message(
          AUTHOR_WARNING "XP_USE_ASAN deprecated and ignored, using XP_SANITIZER=${XP_SANITIZER}."
        )
      endif()
    endif()
    set(NV_SANITIZER ${XP_SANITIZER})
    unset(XP_SANITIZER)
  endif()
  set(docSanitizer "sanitizer option [ASAN|TSAN|NONE]")
  if(CMAKE_BUILD_TYPE STREQUAL Debug)
    set(XP_SANITIZER ${NV_SANITIZER} CACHE STRING "${docSanitizer}" FORCE)
    set_property(CACHE XP_SANITIZER PROPERTY STRINGS NONE ASAN TSAN)
    if(XP_SANITIZER STREQUAL "NONE")

    elseif(XP_SANITIZER STREQUAL "ASAN")
      include(CMakePushCheckState)
      cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES asan)
      check_cxx_compiler_flag("-fsanitize=address" has_asan)
      if(has_asan)
        xpStringAppendIfDne(CMAKE_CXX_FLAGS_DEBUG "-fsanitize=address")
      endif()
      cmake_pop_check_state()
    elseif(XP_SANITIZER STREQUAL "TSAN")
      include(CMakePushCheckState)
      cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES tsan)
      check_cxx_compiler_flag("-fsanitize=thread" has_tsan)
      if(has_tsan)
        xpStringAppendIfDne(CMAKE_CXX_FLAGS_DEBUG "-fsanitize=thread")
      endif()
      cmake_pop_check_state()
    elseif(DEFINED XP_SANITIZER)
      message(FATAL_ERROR "XP_SANITIZER unrecognized: ${XP_SANITIZER}, ${docSanitizer}")
    endif()
  else()
    set(XP_SANITIZER ${NV_SANITIZER} CACHE INTERNAL "${docSanitizer}")
  endif()
  #######
  if(NOT DEFINED XP_COVERAGE)
    set(NV_COVERAGE OFF) # (NV: normal variable) 'cmake --help-policy CMP0077'
  else()
    set(NV_COVERAGE ${XP_COVERAGE})
    unset(XP_COVERAGE)
  endif()
  cmake_dependent_option(
    XP_COVERAGE
    "generate coverage information"
    ${NV_COVERAGE}
    "CMAKE_BUILD_TYPE STREQUAL Debug"
    ${NV_COVERAGE}
  )
  if(XP_COVERAGE AND CMAKE_BUILD_TYPE STREQUAL Debug)
    find_program(XP_PATH_LCOV lcov)
    find_program(XP_PATH_GENHTML genhtml)
    if(XP_PATH_LCOV AND XP_PATH_GENHTML)
      if(DEFINED externpro_DIR AND EXISTS ${externpro_DIR})
        list(APPEND XP_COVERAGE_RM '${externpro_DIR}/*')
      endif()
      if(EXISTS /opt/rh AND IS_DIRECTORY /opt/rh)
        list(APPEND XP_COVERAGE_RM '/opt/rh/*')
      endif()
      if(EXISTS /usr AND IS_DIRECTORY /usr)
        list(APPEND XP_COVERAGE_RM '/usr/*')
      endif()
      list(APPEND XP_COVERAGE_RM '${CMAKE_BINARY_DIR}/*')
      list(REMOVE_DUPLICATES XP_COVERAGE_RM)
      if(NOT TARGET precoverage)
        add_custom_target(
          precoverage COMMAND ${XP_PATH_LCOV} --directory ${CMAKE_BINARY_DIR} --zerocounters
          COMMAND ${XP_PATH_LCOV} --capture --initial --directory ${CMAKE_BINARY_DIR} --output-file
                  ${PROJECT_NAME}-base.info WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        )
      endif()
      if(NOT TARGET postcoverage)
        add_custom_target(
          postcoverage
          COMMAND ${XP_PATH_LCOV} --directory ${CMAKE_BINARY_DIR} --capture --output-file
                  ${PROJECT_NAME}-test.info
          COMMAND
            ${XP_PATH_LCOV} -a ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-base.info -a
            ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-test.info -o
            ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.info
          COMMAND ${XP_PATH_LCOV} --remove ${PROJECT_NAME}.info ${XP_COVERAGE_RM} --output-file
                  ${PROJECT_NAME}-cleaned.info
          COMMAND ${XP_PATH_GENHTML} -o report ${PROJECT_NAME}-cleaned.info
          COMMAND ${CMAKE_COMMAND} -E remove ${PROJECT_NAME}*.info
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        )
      endif()
      if(NOT TARGET coverage)
        add_custom_target(
          coverage
          COMMAND make precoverage
          COMMAND make test
          COMMAND make postcoverage
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        )
      endif()
      xpStringAppendIfDne(CMAKE_CXX_FLAGS_DEBUG "--coverage")
    else()
      if(NOT XP_PATH_LCOV)
        message(AUTHOR_WARNING "lcov not found -- coverage reports will not be supported")
      endif()
      if(NOT XP_PATH_GENHTML)
        message(AUTHOR_WARNING "genhtml not found -- coverage reports will not be supported")
      endif()
    endif()
  endif()
  check_cxx_compiler_flag("-O0" has_O0)
  if(has_O0)

    # don't use debug optimizations (coverage requires this, make it the default for all debug builds)
    xpStringAppendIfDne(CMAKE_CXX_FLAGS_DEBUG "-O0")
  endif()
endmacro()

macro(xpSetFlagsGcc)
  if(NOT CMAKE_BUILD_TYPE) # if not specified, default to "Release"
    set(CMAKE_BUILD_TYPE
        "Release"
        CACHE STRING
              "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
              FORCE
    )
  endif()
  include(CheckCCompilerFlag)
  include(CheckCXXCompilerFlag)
  xpSetFlagsGccDebug()
  if(CMAKE_COMPILER_IS_GNUCXX)
    # Have all executables look in the current directory for shared libraries
    # so the user or installers don't need to update LD_LIBRARY_PATH or equivalent.
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-R,\$ORIGIN")
    set(CMAKE_INSTALL_RPATH "\$ORIGIN")
  endif()
  option(XP_TREAT_WARNING_AS_ERROR "treat GCC warnings as errors" ON)
  if(XP_TREAT_WARNING_AS_ERROR)
    check_cxx_compiler_flag("-Werror" has_Werror)
    if(has_Werror)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Werror")
    endif()
    check_c_compiler_flag("-Werror" has_c_Werror)
    if(has_c_Werror)
      xpStringAppendIfDne(CMAKE_C_FLAGS "-Werror")
    endif()
  endif()
  if(${CMAKE_SYSTEM_NAME} STREQUAL Linux)
    # Makes symbols in executables inaccessible from plugins.
    xpStringRemoveIfExists(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "-rdynamic")
    # Makes symbols hidden by default in shared libraries.  This allows
    # SDL-developed plugins compiled against different versions of
    # VantageShared to coexist without using each other's symbols.
    check_cxx_compiler_flag("-fvisibility=hidden" has_visibility)
    if(has_visibility)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-fvisibility=hidden")
    endif()
    # Prevents symbols from external static libraries from being visible
    # in the shared libraries that use them.  This allows
    # SDL-developed plugins compiled against different versions of third-
    # party libraries to coexist without using each other's symbols.
    check_cxx_compiler_flag("-Wl,--exclude-libs,ALL" has_exclude)
    if(has_exclude)
      xpStringAppendIfDne(CMAKE_CXX_FLAGS "-Wl,--exclude-libs,ALL")
    endif()
  endif()
endmacro()

macro(xpSetFlags) # preprocessor, compiler, linker flags
  xpEnforceOutOfSourceBuilds()
  xpSetUnitTestTools()
  enable_testing()
  set_property(GLOBAL PROPERTY USE_FOLDERS ON) # enables Solution Folders
  set_property(GLOBAL PROPERTY GLOBAL_DEPENDS_NO_CYCLES ON)
  xpCommonFlags()
  xpEnableWarnings()
  if(NOT DEFINED XP_CMAKE_REPO_INSYNC)
    # cmake error if repo and cmake are not in sync
    set(NV_CMAKE_REPO_INSYNC ON) # (NV: normal variable) 'cmake --help-policy CMP0077'
  endif()
  if(MSVC)
    xpSetFlagsMsvc()
  elseif(CMAKE_COMPILER_IS_GNUCXX OR ${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
    xpSetFlagsGcc()
  endif()
endmacro()

macro(xpSetUnitTestTools)
  option(XP_GENERATE_TESTTOOLS "include test tool projects" ON)
  if(XP_GENERATE_TESTTOOLS)
    set(TESTTOOL) # will be part of main solution
  else()
    set(TESTTOOL EXCLUDE_FROM_ALL) # generated, but not part of main solution
  endif()
  ######
  option(XP_GENERATE_UNITTESTS "include unit test projects" ON)
  if(XP_GENERATE_UNITTESTS)
    set(UNITTEST) # will be part of main solution
  else()
    set(UNITTEST EXCLUDE_FROM_ALL) # generated, but not part of main solution
  endif()
endmacro()
