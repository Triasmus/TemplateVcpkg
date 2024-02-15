# RepoName
Template for a c++ project

### Linux
For wsl, make sure to auto enable the ssh-agent: https://esc.sh/blog/ssh-agent-windows10-wsl2/

### Windows
`Visual Studio 2022`

## WSL 22.04 Compilation
```
sudo apt-get install pkg-config build-essential tar curl zip unzip
# Install gcc-13
# Install cmake
cd ~/dev
git clone *Some bitbucket path*
cd RepoName/
git submodule update --init
mkdir ../_bld && cd ../_bld
cmake ../RepoName
make -j4 install
```

## Unit Testing
Use the `test` make target (see above) or `ctest`

### ctest
1. Inside `_bld/`
1. Run `ctest -C <Release|Debug> --output-on-failure`
1. See `ctest -h` for more options
