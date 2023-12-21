set(lib_name SdCapnProto)
#######################################
set(Test_srcs
  echo.capnp
  )
source_group(Test FILES ${Test_srcs})
list(APPEND ${lib_name}_capnp_srcs ${Test_srcs})
#######################################
# generate capnproto stuff here
capnp_generate_cpp(${lib_name}_SRCS ${lib_name}_HDRS ${${lib_name}_capnp_srcs})
#######################################
add_library(${lib_name} STATIC ${${lib_name}_SRCS} ${${lib_name}_HDRS} ${${lib_name}_proto_srcs})
# Add access to generated c++ headers
target_include_directories(${lib_name} SYSTEM PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/..)
target_link_libraries(${lib_name} PUBLIC CapnProto::capnp-rpc)
set_property(TARGET ${lib_name} PROPERTY FOLDER ${folder})
xpSourceListAppend("${${lib_name}_proto_srcs}")