# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "libx11"
version = v"1.6.9"

# Collection of sources required to build libx11
sources = [
    "https://xorg.freedesktop.org/releases/individual/util/util-macros-1.19.2.tar.bz2" =>
    "d7e43376ad220411499a79735020f9d145fdc159284867e99467e0d771f3e712",

    "https://xorg.freedesktop.org/archive/individual/proto/xorgproto-2019.2.tar.bz2" =>
    "46ecd0156c561d41e8aa87ce79340910cdf38373b759e737fcbba5df508e7b8e",

    "https://xcb.freedesktop.org/dist/xcb-proto-1.13.tar.bz2" =>
    "7b98721e669be80284e9bbfeab02d2d0d54cd11172b72271e47a2fe875e2bde1",

    "https://xorg.freedesktop.org/releases/individual/lib/libXdmcp-1.1.3.tar.bz2" =>
    "20523b44aaa513e17c009e873ad7bbc301507a3224c232610ce2e099011c6529",

    "https://xorg.freedesktop.org/releases/individual/lib/libXau-1.0.9.tar.bz2" =>
    "ccf8cbf0dbf676faa2ea0a6d64bcc3b6746064722b606c8c52917ed00dcb73ec",

    "https://xcb.freedesktop.org/dist/libxcb-1.13.1.tar.bz2" =>
    "a89fb7af7a11f43d2ce84a844a4b38df688c092bf4b67683aef179cdf2a647c4",

    "https://xorg.freedesktop.org/releases/individual/lib/libX11-1.6.9.tar.bz2" =>
    "9cc7e8d000d6193fa5af580d50d689380b8287052270f5bb26a5fb6b58b2bed1",

    "https://xorg.freedesktop.org/releases/individual/lib/libXext-1.3.4.tar.bz2" =>
    "59ad6fcce98deaecc14d39a672cf218ca37aba617c9a0f691cac3bcd28edf82b",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
echo $prefix
cd util-macros-1.19.2/
./configure --prefix=$prefix --host=$target
make install
cd ../xorgproto-2019.2/
./configure --prefix=$prefix --host=$target
make install
cd ../xcb-proto-1.13/
./configure --prefix=$prefix --host=$target
make install
cd ../libXdmcp-1.1.3/
./configure --prefix=$prefix --host=$target --disable-static
echo $PKG_CONFIG_PATH/
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$prefix/share/pkgconfig
./configure --prefix=$prefix --host=$target --disable-static
make -j16
make install
cd ../libXau-1.0.9/
./configure --prefix=$prefix --host=$target
make
make install
cd ../libxcb-1.13.1/
./configure --prefix=$prefix --host=$target --disable-static
./configure --help | grep i thread
./configure --help | grep -i thread
./configure --help
./configure --prefix=$prefix --host=$target --disable-static
wget https://git.archlinux.org/svntogit/packages.git/tree/trunk/libxcb-1.1-no-pthread-stubs.patch?h=packages/libxcb
less libxcb-1.1-no-pthread-stubs.patch\?h\=packages%2Flibxcb 
rm libxcb-1.1-no-pthread-stubs.patch\?h\=packages%2Flibxcb 
wget https://git.archlinux.org/svntogit/packages.git/plain/trunk/libxcb-1.1-no-pthread-stubs.patch?h=packages/libxcb
less libxcb-1.1-no-pthread-stubs.patch\?h\=packages%2Flibxcb 
rm libxcb-1.1-no-pthread-stubs.patch\?h\=packages%2Flibxcb 
curl https://git.archlinux.org/svntogit/packages.git/plain/trunk/libxcb-1.1-no-pthread-stubs.patch?h=packages/libxcb --output ../libxcb-1.1-no-pthread-stubs.patch
patch -Np1 -i ../libxcb-1.1-no-pthread-stubs.patch
autoreconf -vfi
cd ../util-macros-1.19.2/
./configure
make install
cd ../libxcb-1.13.1/
autoreconf -vfi
vim configure.ac
ls $prefix/share/aclocal/
autoreconf -I$prefix/share/aclocal -vfi
./configure --prefix=$prefix --host=$target --disable-static
make -j16
make install
cd ../libX11-1.6.9/
./configure --prefix=$prefix --host=$target --disable-static
cd ..
ls
cd ..
ls
ls metadir/
ls destdir/
cd srcdir/
ls
wget https://xorg.freedesktop.org//releases/individual/lib/xtrans-1.4.0.tar.bz2
tar xvf xtrans-1.4.0.tar.bz2 
rm xtrans-1.4.0.tar.bz2 
cd xtrans-1.4.0/
ls
./configure --prefix=$prefix --host=$target
make
make install
cd ../libX11-1.6.9/
./configure --prefix=$prefix --host=$target --disable-static
make -j16
make install
cd ../libXext-1.3.4/
./configure --prefix=$prefix --host=$target --disable-static
make -j16
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:glibc)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libX11", :libx11),
    LibraryProduct(prefix, "libxcb-glx", Symbol("libxcb-glx")),
    LibraryProduct(prefix, "libxcb-damage", Symbol("libxcb-damage")),
    LibraryProduct(prefix, "libxcb-dri2", Symbol("libxcb-dri2")),
    LibraryProduct(prefix, "libxcb-xkb", Symbol("libxcb-xkb")),
    LibraryProduct(prefix, "libxcb", :libxcb),
    LibraryProduct(prefix, "libxcb-dpms", Symbol("libxcb-dpms")),
    LibraryProduct(prefix, "libXau", :libxau),
    LibraryProduct(prefix, "libxcb-sync", Symbol("libxcb-sync")),
    LibraryProduct(prefix, "libxcb-record", Symbol("libxcb-record")),
    LibraryProduct(prefix, "libxcb-present", Symbol("libxcb-present")),
    LibraryProduct(prefix, "libxcb-shape", Symbol("libxcb-shape")),
    LibraryProduct(prefix, "libxcb-res", Symbol("libxcb-res")),
    LibraryProduct(prefix, "libxcb-xf86dri", Symbol("libxcb-xf86dri")),
    LibraryProduct(prefix, "libxcb-xtest", Symbol("libxcb-xtest")),
    LibraryProduct(prefix, "libxcb-dri3", Symbol("libxcb-dri3")),
    LibraryProduct(prefix, "libxcb-shm", Symbol("libxcb-shm")),
    LibraryProduct(prefix, "libxcb-screensaver", Symbol("libxcb-screensaver")),
    LibraryProduct(prefix, "libxcb-xfixes", Symbol("libxcb-xfixes")),
    LibraryProduct(prefix, "libxcb-composite", Symbol("libxcb-composite")),
    LibraryProduct(prefix, "libxcb-xinput", Symbol("libxcb-xinput")),
    LibraryProduct(prefix, "libXdmcp", :libxdcmp),
    LibraryProduct(prefix, "libxcb-xvmc", Symbol("libxcb-xvmc")),
    LibraryProduct(prefix, "libXext", :libxext),
    LibraryProduct(prefix, "libxcb-xinerama", Symbol("libxcb-xinerama")),
    LibraryProduct(prefix, "libxcb-randr", Symbol("libxcb-randr")),
    LibraryProduct(prefix, "libxcb-xv", Symbol("libxcb-xv")),
    LibraryProduct(prefix, "libxcb-render", Symbol("libxcb-render")),
    LibraryProduct(prefix, "libX11-xcb", Symbol("libx11-xcb"))
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

