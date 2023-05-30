project(Shared)
set(folder ${PROJECT_NAME})
set_property(GLOBAL PROPERTY FOLDER ${PROJECT_NAME})
####################################################
# No Dependency
add_subdirectory(UtilitiesLIB/Utilities)
xpSourceListAppend()
