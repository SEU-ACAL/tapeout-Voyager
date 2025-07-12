set(BOARDTEST_WORKLOAD_DIR ${WORKLOAD_DIR}/boardtest)

add_custom_target(boardtest-build ALL DEPENDS
    pintest-build
)

add_subdirectory(pintest)
