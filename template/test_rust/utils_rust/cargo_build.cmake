if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CARGO_CMD cargo build)
    set(TARGET_DIR "debug")
else()
    set(CARGO_CMD cargo build --release)
    set(TARGET_DIR "release")
endif()

macro(rust_header_gen)
    set(RUST_DIST "${CMAKE_CURRENT_SOURCE_DIR}/dist")
    get_filename_component(DIR_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)

    file(MAKE_DIRECTORY ${RUST_DIST})
    file(WRITE ${RUST_DIST}/lib${DIR_NAME}.h "#pragma once\r\n\r\n")
endmacro()

macro(add_crate NAME)
    set(${NAME}_DIST "${CMAKE_CURRENT_SOURCE_DIR}/dist")
    set(${NAME}_LIB "${CMAKE_CURRENT_SOURCE_DIR}/target/${TARGET_DIR}/lib${NAME}.a")
    get_filename_component(HEADER_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)

    add_custom_target(
        cargo_build_${NAME} ALL
        COMMAND ${CARGO_CMD}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${NAME}
    )

    add_custom_target(
        generate_${NAME}
        DEPENDS cargo_build_${NAME}
        COMMAND mkdir -p ${${NAME}_DIST}
        COMMAND cp ${${NAME}_LIB} ${${NAME}_DIST}/lib${NAME}.a
        COMMAND cbindgen --lang c --cpp-compat --crate ${NAME} --output ${${NAME}_DIST}/lib${NAME}.h
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${NAME}
    )

    file(APPEND ${${NAME}_DIST}/lib${HEADER_NAME}.h "#include \"lib${NAME}.h\"\r\n")

    add_library(${NAME} INTERFACE)
    target_include_directories(${NAME} INTERFACE ${${NAME}_DIST})
    target_link_libraries(${NAME} INTERFACE ${${NAME}_DIST}/lib${NAME}.a)
    add_dependencies(${NAME} generate_${NAME})
endmacro()
