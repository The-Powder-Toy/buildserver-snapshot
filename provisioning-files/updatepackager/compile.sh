#!/bin/bash

cd ..
git pull 2>/dev/null
if test $? -ne 0; then
	printf "Could not update source, exiting"
	cd updatepackager
	exit 1
fi
scons --clean

export VER="$1"
export CPPDEFINES="UPDATESERVER=\\\"starcatcher.us/TPT\\\""
export COMPILE="scons --static --snapshot-id=$VER -j4 --luajit --release"

LIN32_compile()
{
	schroot -c bionic -d ~/The-Powder-Toy -- git pull 2>/dev/null
	schroot -c bionic -d ~/The-Powder-Toy -- scons --clean

	export CCFLAGS="-static-libgcc -static-libstdc++ -fno-pie"
	export LINKFLAGS="-static-libgcc -static-libstdc++ -no-pie"
	schroot -c bionic -d ~/The-Powder-Toy -p -- $COMPILE --32bit --builddir=build/$1 2> error_$1.log 1> output_$1.log
}

LIN64_compile()
{
	export CCFLAGS="-static-libgcc -static-libstdc++ -fno-pie"
	export LINKFLAGS="-static-libgcc -static-libstdc++ -no-pie"
	$COMPILE --64bit --builddir=build/$1 2> error_$1.log 1> output_$1.log
}

WIN32_compile()
{
	export CCFLAGS="-static-libgcc"
	export LINKFLAGS="-static-libgcc"
	$COMPILE --win --32bit --builddir=build/$1 2> error_$1.log 1> output_$1.log
}

MACOSX_compile()
{
	export CCFLAGS=
	export LINKFLAGS=
	OLDPATH=$PATH
	PATH=~/mac/osxcross/target/SDK/MacOSX10.12.sdk/usr/bin:~/mac/osxcross/target/bin:$PATH
	CC=o64-clang CXX=o64-clang++-libc++ STRIP=x86_64-apple-darwin16-strip $COMPILE --mac --builddir=build/$1 2> error_$1.log 1> output_$1.log
	ret=$?
	PATH=$OLDPATH
	return $ret
}

NOSNAPSHOT_compile()
{
	export COMPILE="scons --static"
}

MSVC_compile()
{
	echo "Ignoring MSVC compile for now"
}

shift
failed=0
succeed=0
faillist=""
succlist=""
for plat in "$@"
do
	${plat}_compile $plat
	if test $? -ne 0; then
		failed=`expr ${failed} + 1`
		faillist="${faillist}${plat} "
		echo "Compiling $plat failed"
	else
		succeed=`expr ${succeed} + 1`
		succlist="${succlist}${plat} "
		echo "$(git rev-parse HEAD)" > latest_$plat.log
		echo "Compiling $plat succeeded"
	fi
	mv config.log config_$plat.log
done

cd updatepackager
if test $succeed -ne 0; then
	printf "Succeeded builds: ${succlist}\n"
fi
if test $failed -ne 0; then
	printf "Failed builds: ${faillist}\n"
	exit 1
fi
exit 0
