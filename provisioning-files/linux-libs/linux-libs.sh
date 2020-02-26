#!/bin/bash

#change these to match your MinGW installation:
# platform name, for configure scripts
#HOST="i686-w64-mingw32" 
# prefix for MinGW executables (e.g. if MinGW gcc is named i686-w64-mingw32-gcc, use "i686-w64-mingw32-")
#MINGW_BIN_PREFIX="i686-w64-mingw32-"
# where to install the libraries
# you'll probably want to set this to the location where all the existing MinGW bin/lib/include folders are
#MINGW_INSTALL_DIR="/usr/i686-w64-mingw32" 


#
# Script to download, compile (including files for static linking) 
# and install libraries for compiling Powder Toy using MinGW, 
#
# Copyright (c) 2011-2013 jacksonmj
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#

MAKE="make -j 4"



log_error()
{
	error_msg=${1}
	if test "${errors}" = ""; then
		errors=${error_msg}
	else
		errors=${errors}"\n"${error_msg}
	fi
	printf "\033[1;31m${error_msg}\033[m\n"
}

make_lib()
{
	lib=$1
	eval ${lib}_successful_make=0
	eval filename=\$${lib}_filename
	eval url=\$${lib}_url
	if test "${filename}" = ""; then
		log_error "Library name \"${lib}\" not recognised"
		return 1
	fi
	if test ! -f ${filename}; then
		printf "\033[1m${filename} does not exist, downloading...\033[m\n"
		wget -qO "${filename}" "${url}"
		if test $? -ne 0; then
			log_error "Unable to download ${url}"
			return 1
		fi
	fi
	eval md5=\$${lib}_md5
	if test "${md5}" != ""; then
		md5_test=`md5sum -b ${filename} | cut -d' ' -f 1`
		if test "${md5}" != "${md5_test}"; then
			log_error "Incorrect checksum for ${filename}"
			return 1
		fi
	fi
	eval folder=\$${lib}_folder
	eval extractfolder=\$${lib}_extractfolder
	if test "${extractfolder}" != ""; then
		rm -rf ${extractfolder}${folder}
	fi
	printf "\033[1mExtracting ${filename}...\033[m\n"
	mkdir -p ${extractfolder}
	tar -C ${extractfolder} -axf ${filename}
	if test $? -ne 0; then
		log_error "Unable to extract ${filename}"
		return 1
	fi
	printf "\033[1mCompiling ${lib}...\033[m\n"
	${lib}_compile ${extractfolder}${folder}
	if test $? -ne 0; then
		log_error "Failed to compile ${lib}"
		return 1
	fi
	printf "\033[1;32m${lib} compiled and ready to install\033[m\n\n"
	eval ${lib}_successful_make=1
	return 0
}

install_lib()
{
	lib=$1
	eval ${lib}_successful_install=0
	eval folder=\$${lib}_folder
	eval extractfolder=\$${lib}_extractfolder
	printf "\033[1mInstalling ${lib}...\033[m\n"
	${lib}_install ${extractfolder}${folder}
	if test $? -ne 0; then
		log_error "Failed to install ${lib}"
		return 1
	fi
	printf "\033[1;32m${lib} installed\033[m\n\n"
	eval ${lib}_successful_install=1
	return 0
}

bzip2_url="https://starcatcher.us/TPT/libs/bzip2-1.0.8.tar.gz"
bzip2_md5="67e051268d0c475ea773822f7500d0e5"
bzip2_filename="bzip2-1.0.8.tar.gz"
bzip2_folder="/bzip2-1.0.8"
bzip2_extractfolder="tpt-libs"
bzip2_compile()
{
	pushd $1 > /dev/null
	$MAKE bzip2 bzip2recover
	result=$?
	popd > /dev/null
	return $result
}
bzip2_install()
{
	pushd $1 > /dev/null
	$MAKE install
	result=$?
	popd > /dev/null
	return $result
}

zlib_url="https://starcatcher.us/TPT/libs/zlib-1.2.11.tar.gz"
zlib_md5="1c9f62f0778697a09d36121ead88e08e"
zlib_filename="zlib-1.2.11.tar.gz"
zlib_folder="/zlib-1.2.11"
zlib_extractfolder="tpt-libs"
zlib_compile()
{
	pushd $1 > /dev/null
	./configure --static && \
	$MAKE
	result=$?
	popd > /dev/null
	return $result
}
zlib_install()
{
	pushd $1 > /dev/null
	$MAKE install BINARY_PATH="/bin" INCLUDE_PATH="/include" LIBRARY_PATH="/lib"
	result=$?
	popd > /dev/null
	return $result
}

fftw_url="http://www.fftw.org/fftw-3.3.8.tar.gz"
fftw_md5="8aac833c943d8e90d51b697b27d4384d"
fftw_filename="fftw-3.3.8.tar.gz"
fftw_folder="/fftw-3.3.8"
fftw_extractfolder="tpt-libs"
fftw_compile()
{
	pushd $1 > /dev/null
	./configure --build=`./config.guess` --disable-shared --enable-static --disable-alloca --with-our-malloc16 --disable-threads --disable-fortran --enable-portable-binary --enable-float --enable-sse && \
	$MAKE
	result=$?
	popd > /dev/null
	return $result
}
fftw_install()
{
	pushd $1 > /dev/null
	$MAKE install
	result=$?
	popd > /dev/null
	return $result
}

sdl2_url="http://www.libsdl.org/release/SDL2-2.0.10.tar.gz"
sdl2_md5="5a2114f2a6f348bdab5bf52b994811db"
sdl2_filename="SDL2-2.0.10.tar.gz"
sdl2_folder="/SDL2-2.0.10"
sdl2_extractfolder="tpt-libs"
sdl2_compile()
{
	cp glibc.patch $1
	pushd $1 > /dev/null
	patch src/stdlib/SDL_stdlib.c glibc.patch
	./configure --build=`build-scripts/config.guess` --disable-shared && \
	$MAKE
	result=$?
	popd > /dev/null
	return $result
}
sdl2_install()
{
	pushd $1 > /dev/null
	$MAKE install
	result=$?
	popd > /dev/null
	return $result
}

lua_url="http://www.lua.org/ftp/lua-5.1.5.tar.gz"
lua_md5="2e115fe26e435e33b0d5c022e4490567"
lua_filename="lua-5.1.5.tar.gz"
lua_folder="/lua-5.1.5"
lua_extractfolder="tpt-libs"
lua_compile()
{
	pushd $1/src > /dev/null
	$MAKE PLAT=linux LUA_A="liblua5.1.a" linux
	result=$?
	popd > /dev/null
	return $result
}
lua_install()
{
	pushd $1 > /dev/null
	$MAKE install TO_LIB="liblua5.1.a" INSTALL_INC="/usr/local/include/lua5.1/"
	result=$?
	popd > /dev/null
	return $result
}

lua52_url="http://www.lua.org/ftp/lua-5.2.4.tar.gz"
lua52_md5="913fdb32207046b273fdb17aad70be13"
lua52_filename="lua-5.2.4.tar.gz"
lua52_folder="/lua-5.2.4"
lua52_extractfolder="tpt-libs"
lua52_compile()
{
	pushd $1/src > /dev/null
	$MAKE PLAT=linux LUA_A="liblua5.2.a" linux 
	result=$?
	popd > /dev/null
	return $result
}
lua52_install()
{
	pushd $1 > /dev/null
	$MAKE install TO_LIB="liblua5.2.a" INSTALL_INC="/usr/local/include/lua5.2/"
	result=$?
	popd > /dev/null
	return $result
}

luajit_url="http://luajit.org/download/LuaJIT-2.0.5.tar.gz"
luajit_md5="48353202cbcacab84ee41a5a70ea0a2c"
luajit_filename="LuaJIT-2.0.5.tar.gz"
luajit_folder="/LuaJIT-2.0.5"
luajit_extractfolder="tpt-libs"
luajit_compile()
{
	pushd $1/src > /dev/null
	$MAKE LUAJIT_SO=
	result=$?
	popd > /dev/null
	return $result
}
luajit_install()
{
	pushd $1 > /dev/null
	$MAKE install
	result=$?
	popd > /dev/null
	return $result
}

curl_url="https://curl.haxx.se/download/curl-7.68.0.tar.gz"
curl_md5="f68d6f716ff06d357f476ea4ea57a3d6"
curl_filename="curl-7.68.0.tar.gz"
curl_folder="/curl-7.68.0"
curl_extractfolder="tpt-libs"
curl_compile()
{
	pushd $1 > /dev/null
	./configure --disable-shared --disable-ftp --disable-telnet --disable-smtp --disable-imap --disable-pop3 --disable-smb --disable-gopher --disable-dict --disable-file --disable-tftp --disable-rtsp --disable-ldap && \
	$MAKE
	result=$?
	popd > /dev/null
	return $result
}
curl_install()
{
	pushd $1 > /dev/null
	$MAKE install
	result=$?
	popd > /dev/null
	return $result
}

echo_usage()
{
	printf "
\033[1mInstructions for use:\033[m

  First, edit this script and change the variables at the start to
  match your MinGW installation. Then use these commands to download,
  compile, and install libraries:
  
    \033[1m"${0}"\033[m make \033[4mLIBRARY_NAME\033[m...
    \033[1msudo "${0}"\033[m install \033[4mLIBRARY_NAME\033[m...
    
  Valid LIBRARY_NAMEs are: \033[1mfftw lua lua52 luajit sdl2 curl\033[m
\n"
}


if test "${1}" = "make"; then
	shift
	for lib in "$@"
	do
		make_lib ${lib}
	done
	success_count=0
	fail_count=0
	for lib in "$@"
	do
		eval result=\${${lib}_successful_make}
		if test ${result} -eq 1; then
			success_count=`expr ${success_count} + 1`
		else
			fail_count=`expr ${fail_count} + 1`
		fi
	done
	if test $# -gt 0; then
		if test ${fail_count} -eq 0; then
			printf "\033[1mFinished\033[m\n"
			if test ${success_count} -eq 1; then
				printf "\033[1m${success_count} library ready to install\033[m\n"
			else
				printf "\033[1m${success_count} libraries ready to install\033[m\n"
			fi
			printf "\nInstall with:\n  sudo ${0} install $@\n\n"
		elif test $# -gt 1; then
			fail_list=""
			for lib in "$@"
			do
				eval result=\${${lib}_successful_make}
				if test ${result} -eq 0; then
					fail_list="${fail_list}${lib} "
				fi
			done
			if test ${fail_count} -eq 1; then
				printf "\n\n\033[1;31mErrors occurred while trying to download/compile ${fail_count} library\033[m\n"
			else
				printf "\n\n\033[1;31mErrors occurred while trying to download/compile ${fail_count} libraries\033[m\n"
			fi
			printf "Failed libraries: ${fail_list}\n\n"
			printf "Messages:\n${errors}\n"
		fi
	else
		echo_usage
	fi
elif test "${1}" = "install"; then
	shift
	for lib in "$@"
	do
		install_lib ${lib}
	done
	success_count=0
	fail_count=0
	for lib in "$@"
	do
		eval result=\${${lib}_successful_install}
		if test ${result} -eq 1; then
			success_count=`expr ${success_count} + 1`
		else
			fail_count=`expr ${fail_count} + 1`
		fi
	done
	if test $# -gt 0; then
		if test ${fail_count} -eq 0; then
			printf "\033[1mFinished\033[m\n"
			if test ${success_count} -eq 1; then
				printf "\033[1m${success_count} library successfully installed\033[m\n\n"
			else
				printf "\033[1m${success_count} libraries successfully installed\033[m\n\n"
			fi
		elif test $# -gt 1; then
			fail_list=""
			for lib in "$@"
			do
				eval result=\${${lib}_successful_install}
				if test ${result} -eq 0; then
					fail_list="${fail_list}${lib} "
				fi
			done
			if test ${fail_count} -eq 1; then
				printf "\n\n\033[1;31mErrors occurred while trying to install ${fail_count} library\033[m\n"
			else
				printf "\n\n\033[1;31mErrors occurred while trying to install ${fail_count} libraries\033[m\n"
			fi
			printf "Failed libraries: ${fail_list}\n\n"
			#printf "Messages:\n${errors}\n"
		fi
	else
		echo_usage
	fi
else
	echo_usage
fi


