#!/bin/bash
set -x
#
# $Id$
#
# This script builds all binary Perl modules required by Squeezebox Server.
# 
# Supported OSes:
#
# Linux (Perl 5.8.8 & 5.10.0)
#   i386/x86_64 Linux
#   ARM Linux
#   PowerPC Linux
# Mac OSX 10.5, 10.6, (Perl 5.8.8 & 5.10.0)
#   Under 10.5, builds Universal Binaries for i386/ppc
#   Under 10.6, builds Universal Binaries for i386/x86_64
# FreeBSD 7.2 (Perl 5.8.9)

DISTDIR="$1"; shift

OS=`uname`

# get system arch, stripping out extra -gnu on Linux
ARCH=`/usr/bin/perl -MConfig -le 'print $Config{archname}' | sed 's/gnu-//' | sed 's/^i[3456]86-/i386-/' `

if [ $OS = "Linux" -o $OS = "Darwin" -o $OS = "FreeBSD" ]; then
    echo "Building for $OS / $ARCH"
else
    echo "Unsupported platform: $OS, please submit a patch or provide us with access to a development system."
    exit
fi

# Build dir
BUILD=$PWD

# Path to Perl 5.8.8
if [ -x "/usr/bin/perl5.8.8" ]; then
    PERL_58=/usr/bin/perl5.8.8
elif [ -x "/usr/local/bin/perl5.8.8" ]; then
    PERL_58=/usr/local/bin/perl5.8.8
elif [ -x "/usr/local/bin/perl5.8.9" ]; then # FreeBSD 7.2
    PERL_58=/usr/local/bin/perl5.8.9
fi

if [ $PERL_58 ]; then
    echo "Building with Perl 5.8.x at $PERL_58"
fi

# Install dir for 5.8
BASE_58=$BUILD/5.8

# Path to Perl 5.10.0
if [ -x "/usr/bin/perl5.10.0" ]; then
    PERL_510=/usr/bin/perl5.10.0
elif [ -x "/usr/local/bin/perl5.10.0" ]; then
    PERL_510=/usr/local/bin/perl5.10.0
fi

if [ $PERL_510 ]; then
    echo "Building with Perl 5.10 at $PERL_510"
fi

# Install dir for 5.10
BASE_510=$BUILD/5.10

# Require modules to pass tests
RUN_TESTS=1

FLAGS=""
# Mac-specific flags
if [ $OS = "Darwin" ]; then
    if [ $PERL_58 ]; then
        # build 32-bit version 
        FLAGS="-arch i386 -arch ppc -isysroot /Developer/SDKs/MacOSX10.4u.sdk -mmacosx-version-min=10.3"
    elif [ $PERL_510 ]; then
        # Build 64-bit version    
        FLAGS="-arch x86_64 -arch i386 -isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5"
    fi
fi

# FreeBSD's make sucks
if [ $OS = "FreeBSD" ]; then
    if [ !-x /usr/local/bin/gmake ]; then
        echo "ERROR: Please install GNU make (gmake)"
        exit
    fi
    export GNUMAKE=/usr/local/bin/gmake
    export MAKE=/usr/local/bin/gmake
else
    export MAKE=/usr/bin/make
fi

# Clean up
# XXX command-line flag to skip cleanup
#rm -rf $BUILD

#mkdir $BUILD

# $1 = module to build
# $2 = Makefile.PL arg(s)
function build_module {
    tar zxvf $DISTDIR/SqueezeboxServer-$1.tar.gz || exit 1
    cd $1
#    cp -R ../hints .
    if [ $PERL_58 ]; then
        # Running 5.8
        export PERL5LIB=$BASE_58/lib/perl5
        
        $PERL_58 Makefile.PL PREFIX=$BASE_58 $2
        if [ $RUN_TESTS -eq 1 ]; then
            make test
        else
            make
        fi
        if [ $? != 0 ]; then
            if [ $RUN_TESTS -eq 1 ]; then
                echo "make test failed, aborting"
            else
                echo "make failed, aborting"
            fi
            exit $?
        fi
        make install || exit 1
        make clean || exit 1
    fi
    if [ $PERL_510 ]; then
        # Running 5.10
        export PERL5LIB=$BASE_510/lib/perl5
        
        $PERL_510 Makefile.PL PREFIX=$BASE_510 $2
        if [ $RUN_TESTS -eq 1 ]; then
            make test
        else
            make
        fi
        if [ $? != 0 ]; then
            if [ $RUN_TESTS -eq 1 ]; then
                echo "make test failed, aborting"
            else
                echo "make failed, aborting"
            fi
            exit $?
        fi
        make install || exit 1
    fi
    cd ..
    rm -rf $1
}

function build_all {
    build Audio::Scan
#    build AutoXS::Header
#    build Class::C3::XS
#    build Class::XSAccessor
#    build Class::XSAccessor::Array
#    build Compress::Raw::Zlib
#    build DBI
#    build DBD::mysql
#    build Digest::SHA1
    build EV
#    build Encode::Detect
#    build GD
#    build HTML::Parser
#    build JSON::XS
#    build Locale::Hebrew
#    build Sub::Name
#    build Template
#    build XML::Parser
#    build YAML::Syck
}

function build {
    case "$1" in
        AutoXS::Header)
            # AutoXS::Header support module
            build_module AutoXS-Header-1.02
            ;;
            
        Class::C3::XS)
            if [ $PERL_58 ]; then
                build_module Class-C3-XS-0.11
            fi
            ;;
        
        Class::XSAccessor)
            build_module Class-XSAccessor-1.03
            ;;
        
        Class::XSAccessor::Array)
            build_module Class-XSAccessor-Array-1.04
            ;;
        
        Compress::Raw::Zlib)
            build_module Compress-Raw-Zlib-2.017
            ;;
        
        DBI)
            build_module DBI-1.608
            ;;
        
        Digest::SHA1)
            build_module Digest-SHA1-2.11
            ;;
        
        EV)
#            build_module common-sense-2.0

            export PERL_MM_USE_DEFAULT=1
            RUN_TESTS=0
            build_module EV-3.8
            RUN_TESTS=1
            export PERL_MM_USE_DEFAULT=
            ;;
        
        Encode::Detect)
            build_module Data-Dump-1.15
            build_module ExtUtils-CBuilder-0.260301
            RUN_TESTS=0
            build_module Module-Build-0.35
            RUN_TESTS=1
            build_module Encode-Detect-1.00
            ;;
        
        HTML::Parser)
            build_module HTML-Tagset-3.20
            build_module HTML-Parser-3.60
            ;;
        
        JSON::XS)
            build_module JSON-XS-2.232
            ;;
        
        Locale::Hebrew)
            build_module Locale-Hebrew-1.04
            ;;
        
        Sub::Name)
            build_module Sub-Name-0.04
            ;;
        
        YAML::Syck)
            build_module YAML-Syck-1.05
            ;;
        
        Audio::Scan)
            build_module Audio-Scan-0.45
            ;;
        
        Template)
            # Template, custom build due to 2 Makefile.PL's
            tar zxvf Template-Toolkit-2.21.tar.gz
            cd Template-Toolkit-2.21
            cp -R ../hints .
            cp -R ../hints ./xs
            if [ $PERL_58 ]; then
                # Running 5.8
                $PERL_58 Makefile.PL PREFIX=$BASE_58 TT_ACCEPT=y TT_EXAMPLES=n TT_EXTRAS=n
                make # minor test failure, so don't test
                if [ $? != 0 ]; then
                    echo "make failed, aborting"
                    exit $?
                fi
                make install
                make clean
            fi
            if [ $PERL_510 ]; then
                # Running 5.10
                $PERL_510 Makefile.PL PREFIX=$BASE_510 TT_ACCEPT=y TT_EXAMPLES=n TT_EXTRAS=n
                make # minor test failure, so don't test
                if [ $? != 0 ]; then
                    echo "make failed, aborting"
                    exit $?
                fi
                make install
            fi
            cd ..
            rm -rf Template-Toolkit-2.21
            ;;
        
        DBD::mysql)
            # Build libmysqlclient
            tar jxvf mysql-5.1.37.tar.bz2
            cd mysql-5.1.37
            CC=gcc CXX=gcc \
            CFLAGS="-O3 -fno-omit-frame-pointer $FLAGS" \
            CXXFLAGS="-O3 -fno-omit-frame-pointer -felide-constructors -fno-exceptions -fno-rtti $FLAGS" \
                ./configure --prefix=$BUILD \
                --disable-dependency-tracking \
                --enable-thread-safe-client \
                --without-server --disable-shared --without-docs --without-man
            make
            if [ $? != 0 ]; then
                echo "make failed"
                exit $?
            fi
            make install
            cd ..
            rm -rf mysql-5.1.37

            # DBD::mysql custom, statically linked with libmysqlclient
            tar zxvf DBD-mysql-3.0002.tar.gz
            cd DBD-mysql-3.0002
            cp -R ../hints .
            mkdir mysql-static
            cp $BUILD/lib/mysql/libmysqlclient.a mysql-static
            if [ $PERL_58 ]; then
                # Running 5.8
                export PERL5LIB=$BASE_58/lib/perl5
                
                $PERL_58 Makefile.PL --mysql_config=$BUILD/bin/mysql_config --libs="-Lmysql-static -lmysqlclient -lz -lm" PREFIX=$BASE_58 
                make
                if [ $? != 0 ]; then
                    echo "make failed, aborting"
                    exit $?
                fi
                make install
                make clean
            fi
            if [ $PERL_510 ]; then
                # Running 5.10
                export PERL5LIB=$BASE_510/lib/perl5
                
                $PERL_510 Makefile.PL --mysql_config=$BUILD/bin/mysql_config --libs="-Lmysql-static -lmysqlclient -lz -lm" PREFIX=$BASE_510
                make
                if [ $? != 0 ]; then
                    echo "make failed, aborting"
                    exit $?
                fi
                make install
            fi
            cd ..
            rm -rf DBD-mysql-3.0002
            ;;
        
        XML::Parser)
            # build expat
            tar zxvf expat-2.0.1.tar.gz
            cd expat-2.0.1
            CFLAGS="$FLAGS" \
            LDFLAGS="$FLAGS" \
                ./configure --prefix=$BUILD \
                --disable-dependency-tracking
            make
            if [ $? != 0 ]; then
                echo "make failed"
                exit $?
            fi
            make install
            cd ..

            # Symlink static versions of libraries to avoid OSX linker choosing dynamic versions
            cd build/lib
            ln -sf libexpat.a libexpat_s.a
            cd ../..

            # XML::Parser custom, built against expat
            tar zxvf XML-Parser-2.36.tar.gz
            cd XML-Parser-2.36
            cp -R ../hints .
            cp -R ../hints ./Expat # needed for second Makefile.PL
            patch -p0 < ../XML-Parser-Expat-Makefile.patch
            if [ $PERL_58 ]; then
                # Running 5.8
                $PERL_58 Makefile.PL PREFIX=$BASE_58 EXPATLIBPATH=$BUILD/lib EXPATINCPATH=$BUILD/include
                make test
                if [ $? != 0 ]; then
                    echo "make failed, aborting"
                    exit $?
                fi
                make install
                make clean
            fi
            if [ $PERL_510 ]; then
                # Running 5.10
                $PERL_510 Makefile.PL PREFIX=$BASE_510 EXPATLIBPATH=$BUILD/lib EXPATINCPATH=$BUILD/include
                make test
                if [ $? != 0 ]; then
                    echo "make failed, aborting"
                    exit $?
                fi
                make install
            fi
            cd ..
            rm -rf XML-Parser-2.36
            rm -rf expat-2.0.1
            ;;
        
        GD)
            # build libjpeg
            # Makefile doesn't create directories properly, so make sure they exist
            # Note none of these directories are deleted until GD is built
            mkdir -p build/bin build/lib build/include build/man/man1
            tar zxvf jpegsrc.v6b.tar.gz
            cd jpeg-6b
            CFLAGS="$FLAGS" \
            LDFLAGS="$FLAGS" \
                ./configure --prefix=$BUILD \
                --disable-dependency-tracking
            make && make test
            if [ $? != 0 ]; then
                echo "make failed"
                exit $?
            fi
            make install-lib
            cd ..

            # build libpng
            tar zxvf libpng-1.2.39.tar.gz
            cd libpng-1.2.39
            CFLAGS="$FLAGS" \
            LDFLAGS="$FLAGS" \
                ./configure --prefix=$BUILD \
                --disable-dependency-tracking
            make && make test
            if [ $? != 0 ]; then
                echo "make failed"
                exit $?
            fi
            make install
            cd ..

            # build freetype
            tar zxvf freetype-2.3.9.tar.gz
            cd freetype-2.3.9
            CFLAGS="$FLAGS" \
            LDFLAGS="$FLAGS" \
                ./configure --prefix=$BUILD \
                --disable-dependency-tracking
            patch -p0 < ../freetype-arm-asm.patch # patch to fix ARM asm
            $MAKE
            if [ $? != 0 ]; then
                echo "make failed"
                exit $?
            fi
            $MAKE install
            cd ..

            # build expat
            tar zxvf expat-2.0.1.tar.gz
            cd expat-2.0.1
            CFLAGS="$FLAGS" \
            LDFLAGS="$FLAGS" \
                ./configure --prefix=$BUILD \
                --disable-dependency-tracking
            make
            if [ $? != 0 ]; then
                echo "make failed"
                exit $?
            fi
            make install
            cd ..

            # build fontconfig
            tar zxvf fontconfig-2.6.0.tar.gz
            cd fontconfig-2.6.0
            CFLAGS="$FLAGS" \
            LDFLAGS="$FLAGS" \
                ./configure --prefix=$BUILD \
                --disable-dependency-tracking --disable-docs \
                --with-expat-includes=$BUILD/include --with-expat-lib=$BUILD/lib \
                --with-freetype-config=$BUILD/bin/freetype-config
            make
            if [ $? != 0 ]; then
                echo "make failed"
                exit $?
            fi
            make install
            cd ..

            # build gd
            tar zxvf gd-2.0.35.tar.gz
            cd gd-2.0.35
            # gd's configure is really dumb, adjust PATH so it can find the correct libpng config scripts
            # and need to manually specify include dir
            PATH="$BUILD/bin:$PATH" \
            CFLAGS="-I$BUILD/include $FLAGS" \
            LDFLAGS="$FLAGS" \
                ./configure --prefix=$BUILD \
                --disable-dependency-tracking --without-xpm --without-x \
                --with-libiconv-prefix=/usr \
                --with-jpeg=$BUILD \
                --with-png=$BUILD \
                --with-freetype=$BUILD \
                --with-fontconfig=$BUILD
            make
            if [ $? != 0 ]; then
                echo "make failed"
                exit $?
            fi
            make install
            cd ..

            # Symlink static versions of libraries to avoid OSX linker choosing dynamic versions
            cd build/lib
            ln -sf libexpat.a libexpat_s.a
            ln -sf libjpeg.a libjpeg_s.a
            ln -sf libpng12.a libpng12_s.a
            ln -sf libgd.a libgd_s.a
            ln -sf libfontconfig.a libfontconfig_s.a
            ln -sf libfreetype.a libfreetype_s.a
            cd ../..

            # GD
            tar zxvf GD-2.41.tar.gz
            cd GD-2.41
            patch -p0 < ../GD-Makefile.patch # patch to build statically
            cp -R ../hints .
            if [ $PERL_58 ]; then
                # Running 5.8
                PATH="$BUILD/bin:$PATH" \
                    $PERL_58 Makefile.PL PREFIX=$BASE_58

                make test
                if [ $? != 0 ]; then
                    echo "make test failed, aborting"
                    exit $?
                fi
                make install
                make clean
            fi
            if [ $PERL_510 ]; then
                # Running 5.10
                PATH="$BUILD/bin:$PATH" \
                    $PERL_510 Makefile.PL PREFIX=$BASE_510

                make test
                if [ $? != 0 ]; then
                    echo "make test failed, aborting"
                    exit $?
                fi
                make install
            fi

            cd ..
            rm -rf GD-2.41
            rm -rf gd-2.0.35
            rm -rf fontconfig-2.6.0
            rm -rf expat-2.0.1
            rm -rf freetype-2.3.9
            rm -rf libpng-1.2.39
            rm -rf jpeg-6b
            ;;
    esac
}

# Build a single module if requested, or all
if [ $1 ]; then
    build $1
else
    build_all
fi

# Reset PERL5LIB
export PERL5LIB=

# clean out useless .bs/.packlist files, etc
find $BUILD -name '*.bs' -exec rm -f {} \;
find $BUILD -name '*.packlist' -exec rm -f {} \;

# create our directory structure
# XXX there is still some crap left in here by some modules such as DBI, GD
if [ $PERL_58 ]; then
    mkdir -p $BUILD/CPAN-arch/5.8/$ARCH
    mkdir -p $BUILD/CPAN-pm
    mv $BASE_58/lib*/perl5/site_perl/*/*/auto $BUILD/CPAN-arch/5.8/$ARCH/
    mv $BASE_58/lib*/perl5/site_perl/*/*/* $BUILD/CPAN-pm
fi
if [ $PERL_510 ]; then
    mkdir -p $BUILD/CPAN-arch/5.10/$ARCH
    mkdir -p $BUILD/CPAN-pm
    mv $BASE_510/lib*/perl5/site_perl/*/*/auto $BUILD/CPAN-arch/5.10/$ARCH/
    mv $BASE_510/lib*/perl5/site_perl/*/*/* $BUILD/CPAN-pm
fi

# could remove rest of build data, but let's leave it around in case
#rm -rf $BASE_58
#rm -rf $BASE_510
#rm -rf $BUILD/bin $BUILD/etc $BUILD/include $BUILD/lib $BUILD/man $BUILD/share $BUILD/var
