# 组件目录说明

## 目录结构

```text
component
├── CMakeLists.txt
├── Kconfig
├── lib
│   └── libtest.a
├── inc
│   └── lib1.h
└── src
    └── lib1.c
```

### Kconfig

[kconfig-language](https://www.kernel.org/doc/Documentation/kbuild/kconfig-language.txt)

```text
menu "Component configuration"
    config COMPONENT_ENABLED
        bool "Enable component"
        help
            Select this option to enable component2 and show the submenu.
    menu "Component configuration menu"
        visible if COMPONENT_ENABLED
        choice COMPONENT_TEST_STR
            prompt "Component test string"
            depends on COMPONENT_ENABLED
            help
                Component test string in lib_test func.

            config COMPONENT_TEST_STR1
                bool "component test string 1"

            config COMPONENT_TEST_STR2
                bool "component test string 2"

            config COMPONENT_TEST_STR3
                bool "component test string 3"
        endchoice
    endmenu
endmenu


menuconfig MENUCONFIG_EXAMPLE
    bool "selectable menuconfig item example"
    default n

    config MENUCONFIG_SUB_EXAMPLE_1
        bool "menuconfig item's sub item1"
        default y
        depends on MENUCONFIG_EXAMPLE
    config MENUCONFIG_SUB_EXAMPLE_2
        bool "menuconfig item's sub item2"
        default n
        depends on MENUCONFIG_EXAMPLE
```

### CMakeLists

[CMake Tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/index.html#)

```cmake
if(CONFIG_COMPONENT_ENABLED)
    ############## Import package #################
    # find_package(OpenSSL REQUIRED)
    ###############################################

    ################# Add include #################
    list(APPEND ADD_INCLUDE "inc")
    # list(APPEND ADD_PRIVATE_INCLUDE "include_private")
    ###############################################

    ############## Add source files ###############
    list(APPEND ADD_SRCS "src/lib1.c")
    # FILE(GLOB_RECURSE EXTRA_SRC  "src/*.c")
    # FILE(GLOB EXTRA_SRC  "src/*.c")
    # list(APPEND ADD_SRCS  ${EXTRA_SRC})
    # aux_source_directory(src ADD_SRCS)  # collect all source file in src dir, will set var ADD_SRCS
    # append_srcs_dir(ADD_SRCS "src")     # append source file in src dir to var ADD_SRCS
    # list(REMOVE_ITEM COMPONENT_SRCS "src/test.c")
    # set(ADD_ASM_SRCS "src/asm.S")
    # list(APPEND ADD_SRCS ${ADD_ASM_SRCS})
    # SET_PROPERTY(SOURCE ${ADD_ASM_SRCS} PROPERTY LANGUAGE C) # set .S  ASM file as C language
    # SET_SOURCE_FILES_PROPERTIES(${ADD_ASM_SRCS} PROPERTIES COMPILE_FLAGS "-x assembler-with-cpp -D BBBBB")
    ###############################################

    ###### Add required/dependent components ######
    # list(APPEND ADD_REQUIREMENTS component1)
    ###############################################

    ###### Add link search path for requirements/libs ######
    # list(APPEND ADD_LINK_SEARCH_PATH "${CONFIG_TOOLCHAIN_PATH}/lib")
    # list(APPEND ADD_REQUIREMENTS pthread m)  # add system libs, pthread and math lib for example here
    # set (OpenCV_DIR opencv/lib/cmake/opencv4)
    # find_package(OpenCV REQUIRED)
    ###############################################

    ############ Add static libs ##################
    list(APPEND ADD_STATIC_LIB "lib/libtest.a")
    ###############################################

    ############ Add dynamic libs ##################
    # list(APPEND ADD_DYNAMIC_LIB "libtest.so")
    ###############################################

    #### Add compile option for this component ####
    #### Just for this component, won't affect other 
    #### modules, including component that depend 
    #### on this component
    # list(APPEND ADD_DEFINITIONS_PRIVATE -DAAAA=1)
    ###############################################

    #### Add compile option for this component
    #### and components denpend on this component
    # list(APPEND ADD_DEFINITIONS -DAAAA=1)
    ###############################################

    ############ Add static libs ##################
    #### Update parent's variables like CMAKE_C_LINK_FLAGS
    # set(CMAKE_C_LINK_FLAGS "${CMAKE_C_LINK_FLAGS} -Wl,--start-group libmaix/libtest.a -ltest2 -Wl,--end-group" PARENT_SCOPE)
    ###############################################

    # register component, DYNAMIC or SHARED flags will make component compiled to dynamic(shared) lib
    register_component()
endif()
```
