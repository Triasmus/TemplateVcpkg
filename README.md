# TemplateVcpkg
Template for a c++ project using vcpkg

## Dependecies
`cmake >= v3.24`
`gcc-11`

This repo uses [vcpkg](https://github.com/microsoft/vcpkg) as a submodule.
See [vcpkg.json](/vcpkg.json) for list of 3rd party libraries it uses.

### Linux
For wsl, make sure to auto enable the ssh-agent: https://esc.sh/blog/ssh-agent-windows10-wsl2/

### Windows
`Visual Studio 2022`

## WSL 20.04 Compilation
1. `sudo apt-get install pkg-config build-essential tar curl zip unzip`
1. Install gcc-11
    1. `sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test`
    1. `sudo apt install -y gcc-11 g++-11`
    1. `sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100`
    1. `sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100`
1. Install cmake
    1. `cd /tmp`
    1. `sudo apt-get install libssl-dev libncurses5-dev`
    1. `wget https://github.com/Kitware/CMake/releases/download/v3.25.1/cmake-3.25.1.tar.gz`
    1. `tar -zxvf cmake-3.25.1.tar.gz`
    1. `cd cmake-3.25.1/`
    1. `sudo ./bootstrap` && `sudo make -j4` && `sudo make install`
1. `cd ~/dev`
1. `git clone git@github.com:Triasmus/CryptoTrading.git`
1. `cd CryptoTrading/`
1. `git submodule update --remote`
1. `mkdir ../_cryptotrading && cd ../_cryptotrading`
1. `cmake ../CryptoTrading` # Note: The first run of cmake might take awhile, since it has to download 3rd party libraries
1. `make -j4 install`

## Windows Compilation
1. Run cmake.
    - Point it to the correct src dir and desired bld dir and generate using the default options
1. `.sln` is located in `_bld/`

## `make` Targets

* all_build (Windows only)
    - only builds
* install
    - builds and places the executables for both the repo and Playground in `_bld/dist/bin/`
* package
    - builds and creates a package like: `_bld/<ProjectName>-<version>.zip|rpm`
* test
    - runs unit tests

## Unit Testing
Use the `test` target (see above) or `ctest`

### ctest
1. Inside `_bld/`
1. Run `ctest -C <Release|Debug> --output-on-failure`
1. See `ctest -h` for more options
