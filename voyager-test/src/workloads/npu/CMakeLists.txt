
add_custom_target(npu-build ALL DEPENDS
    # gemmini-buddy 
    gemmini-native
    npu-buckyball
)

add_subdirectory(buddy)
add_subdirectory(native)
add_subdirectory(buckyball)
