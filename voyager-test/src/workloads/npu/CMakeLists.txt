
add_custom_target(npu-build ALL DEPENDS
    gemmini-buddy 
    gemmini-native
)

add_subdirectory(buddy)
add_subdirectory(native)
