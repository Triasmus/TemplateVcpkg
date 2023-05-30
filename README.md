# IPCTesting
Template for a c++ project using vcpkg

## Dependecies
`cmake >= v3.26`
`gcc-13`

This repo uses [vcpkg](https://github.com/microsoft/vcpkg) as a submodule.
See [vcpkg.json](/vcpkg.json) for list of 3rd party libraries it uses.

### Linux
For wsl, make sure to auto enable the ssh-agent: https://esc.sh/blog/ssh-agent-windows10-wsl2/

### Windows
`Visual Studio 2022`

## WSL 22.04 Compilation
```
sudo apt-get install pkg-config build-essential tar curl zip unzip
# Install gcc-13
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
    sudo apt install -y gcc-13 g++-13
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100
# Install cmake
    cd /tmp
    sudo apt-get install libssl-dev libncurses5-dev
    wget https://github.com/Kitware/CMake/releases/download/v3.26.4/cmake-3.26.4.tar.gz
    tar -zxvf cmake-3.26.4.tar.gz
    cd cmake-3.26.4/
    sudo ./bootstrap && sudo make -j4 && sudo make install
cd ~/dev
git clone git@github.com:Triasmus/IPCTesting.git
cd IPCTesting/
git submodule update --init
mkdir ../_temVcpkg && cd ../_temVcpkg
cmake ../IPCTesting # Note: The first run of cmake might take awhile, since it has to download 3rd party libraries
make -j4 install
```

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
