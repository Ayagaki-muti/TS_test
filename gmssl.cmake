if (TARGET openssl)
    return()
endif ()

set(OPENSSL_PROVIDER "gmssl" CACHE STRING "Openssl provider (ssl|gmssl)")

if (${OPENSSL_PROVIDER} STREQUAL "ssl")
    message(STATUS "Use native libssl-dev as openssl provider")

    set(OPENSSL_USE_STATIC_LIBS TRUE)
    find_package(OpenSSL REQUIRED)

    add_library(openssl INTERFACE)
    target_link_libraries(openssl INTERFACE OpenSSL::SSL OpenSSL::Crypto)

    # for sqlcipher
    find_library(openssl_crypto_library NAMES libcrypto.a REQUIRED)
elseif (${OPENSSL_PROVIDER} STREQUAL "gmssl")
    message(STATUS "Use gmssl as openssl provider")

    set(gmssl_url git@github.com:Ayagaki-muti/GmSSL.git)
    set(gmssl_tag master)
    set(gmssl_source_dir ${CMAKE_CURRENT_LIST_DIR}/sources/gmssl_source)

    execute_process(COMMAND
            ${CMAKE_CURRENT_LIST_DIR}/git_clone_project.sh
            ${gmssl_url}
            ${gmssl_tag}
            ${gmssl_source_dir})

    include(ExternalProject)
    ExternalProject_Add(gmssl
            DOWNLOAD_COMMAND ""
            UPDATE_COMMAND ""
            CONFIGURE_COMMAND cd ${gmssl_source_dir} && ./config
            BUILD_IN_SOURCE true
            BUILD_COMMAND cd ${gmssl_source_dir} && make -j4
            INSTALL_COMMAND "")

    add_library(openssl INTERFACE)
    target_include_directories(openssl INTERFACE ${gmssl_source_dir}/include)
    target_link_libraries(openssl INTERFACE
            "-Wl,--start-group"
            ${gmssl_source_dir}/libcrypto.a
            ${gmssl_source_dir}/libssl.a
            "-Wl,--end-group"
            pthread dl)
    add_dependencies(openssl gmssl)

    # for sqlcipher
    set(openssl_crypto_library ${gmssl_source_dir}/libcrypto.a)
else ()
    message(FATAL_ERROR "Invalid openssl provider: ${OPENSSL_PROVIDER}")
endif ()
