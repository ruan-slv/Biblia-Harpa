# CMake install step fails because it tries to install to Program Files (requires admin).
# Workaround: set CMAKE_INSTALL_PREFIX to a local directory.
cmake -DBUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="C:/Users/ruang/OneDrive/Documentos/Projetos/Biblia-Harpa/build/windows/x64/install" -P cmake_install.cmake