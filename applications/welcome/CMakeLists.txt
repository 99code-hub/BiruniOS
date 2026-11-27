cmake_minimum_required(VERSION 3.21)
project(birunios-welcome VERSION 0.1.0 LANGUAGES CXX)
set(BIRUNIOS_VERSION "0.1.0" CACHE STRING "BiruniOS release version")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Widgets)

qt_add_executable(birunios-welcome
    src/main.cpp
)

target_link_libraries(birunios-welcome PRIVATE Qt6::Widgets)
target_compile_definitions(birunios-welcome PRIVATE BIRUNIOS_VERSION=\"${BIRUNIOS_VERSION}\")
target_compile_options(birunios-welcome PRIVATE -Wall -Wextra -Wpedantic)

install(TARGETS birunios-welcome RUNTIME DESTINATION bin)
install(FILES data/birunios-welcome.desktop DESTINATION share/applications)
install(FILES data/birunios-welcome.svg DESTINATION share/icons/hicolor/scalable/apps)
