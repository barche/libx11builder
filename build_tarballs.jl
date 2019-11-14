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
    
    "https://xcb.freedesktop.org/dist/xcb-util-0.4.0.tar.bz2" =>
    "46e49469cb3b594af1d33176cd7565def2be3fa8be4371d62271fabb5eae50e9",

    "https://xcb.freedesktop.org/dist/xcb-util-wm-0.4.1.tar.bz2" =>
    "28bf8179640eaa89276d2b0f1ce4285103d136be6c98262b6151aaee1d3c2a3f",

    "https://xcb.freedesktop.org/dist/xcb-util-image-0.4.0.tar.bz2" =>
    "2db96a37d78831d643538dd1b595d7d712e04bdccf8896a5e18ce0f398ea2ffc",

    "https://xcb.freedesktop.org/dist/xcb-util-keysyms-0.4.0.tar.bz2" =>
    "0ef8490ff1dede52b7de533158547f8b454b241aa3e4dcca369507f66f216dd9",

    "https://xcb.freedesktop.org/dist/xcb-util-renderutil-0.3.9.tar.bz2" =>
    "c6e97e48fb1286d6394dddb1c1732f00227c70bd1bedb7d1acabefdd340bea5b",

    "https://xorg.freedesktop.org/releases/individual/lib/libX11-1.6.9.tar.bz2" =>
    "9cc7e8d000d6193fa5af580d50d689380b8287052270f5bb26a5fb6b58b2bed1",

    "https://xorg.freedesktop.org/releases/individual/lib/libXext-1.3.4.tar.bz2" =>
    "59ad6fcce98deaecc14d39a672cf218ca37aba617c9a0f691cac3bcd28edf82b",

    "https://xorg.freedesktop.org//releases/individual/lib/xtrans-1.4.0.tar.bz2" =>
    "377c4491593c417946efcd2c7600d1e62639f7a8bbca391887e2c4679807d773",

    "https://xkbcommon.org/download/libxkbcommon-0.9.1.tar.xz" =>
    "d4c6aabf0a5c1fc616f8a6a65c8a818c03773b9a87da9fbc434da5acd1199be0"
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd util-macros-1.19.2/
./configure --prefix=$prefix --host=$target
make install

cd ../xorgproto-2019.2/
./configure --prefix=$prefix --host=$target
make install
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$prefix/share/pkgconfig

cd ../xcb-proto-1.13/
./configure --prefix=$prefix --host=$target
make install
cd ../libXdmcp-1.1.3/
./configure --prefix=$prefix --host=$target --disable-static
make
make install

cd ../libXau-1.0.9/
./configure --prefix=$prefix --host=$target
make
make install

cd ../libxcb-1.13.1/
curl https://git.archlinux.org/svntogit/packages.git/plain/trunk/libxcb-1.1-no-pthread-stubs.patch?h=packages/libxcb --output libxcb-1.1-no-pthread-stubs.patch
patch -Np1 -i libxcb-1.1-no-pthread-stubs.patch
autoreconf -I$prefix/share/aclocal -vfi
./configure --prefix=$prefix --host=$target --disable-static
make -j16
make install

cd ../xcb-util-0.4.0
./configure --prefix=$prefix --host=$target --disable-static
make
make install

cd ../xcb-util-wm-0.4.1
./configure --prefix=$prefix --host=$target --disable-static
make
make install

cd ../xcb-util-image-0.4.0
./configure --prefix=$prefix --host=$target --disable-static
make
make install

cd ../xcb-util-keysyms-0.4.0
./configure --prefix=$prefix --host=$target --disable-static
make
make install

cd ../xcb-util-renderutil-0.3.9
./configure --prefix=$prefix --host=$target --disable-static
make
make install

cd ../xtrans-1.4.0/
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

cd ../libxkbcommon-0.9.1
apk add meson
meson setup build -Dprefix=/workspace/destdir -Denable-wayland=false -Denable-docs=false
ninja -C build
ninja -C build install

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
    LibraryProduct(prefix, "libxcb-icccm", Symbol("libxcb-icccm")),
    LibraryProduct(prefix, "libXdmcp", :libxdcmp),
    LibraryProduct(prefix, "libxcb-xvmc", Symbol("libxcb-xvmc")),
    LibraryProduct(prefix, "libXext", :libxext),
    LibraryProduct(prefix, "libxcb-xinerama", Symbol("libxcb-xinerama")),
    LibraryProduct(prefix, "libxcb-randr", Symbol("libxcb-randr")),
    LibraryProduct(prefix, "libxcb-xv", Symbol("libxcb-xv")),
    LibraryProduct(prefix, "libxcb-render", Symbol("libxcb-render")),
    LibraryProduct(prefix, "libX11-xcb", Symbol("libx11-xcb")),
    LibraryProduct(prefix, "libxkbcommon", Symbol("libxkbcommon")),
    LibraryProduct(prefix, "libxkbcommon-x11", Symbol("libxkbcommon-x11"))
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

