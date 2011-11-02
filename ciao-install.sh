#! /bin/bash
#################################################################
#
#  File: ciao-install
#
#  Description
#  Script to assist users in downloading, installing and patching
#  ciao.
#  Version 1.1
# 
#  Copyright (C) 2010 Smithsonian Astrophysical Observatory
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#################################################################

# these variables will be configured by the web page

SEGMENTS="sherpa chips tools prism obsvis contrib CALDB_main "
SYS=""

# Global variables
# The DEF_* Variables are over-written with values found in
# the CIAOINSTALLRC file. If that file does not exist,
# the DEF_* values are used.

DEF_DL_DIR="`pwd`"       # Default Download Directory
DL_DIR=""                # Download Directory
CL_DL_DIR=""             # Set if directory given on command line
DEF_INS_DIR="/usr/local" # Default Install Directory
INS_DIR=""               # Install Directory
CL_INS_DIR=""            # Set if directory given on command line
CALDB_DIR="CIAO"         # CALDB Directory
DEF_RUN_SMOKE="y"        # run smoke tests after install
RUN_SMOKE=""
DEF_SYS="NONE"           # Default system
SYSTEM=""                # System to install (Linux, osxi, sun10, etc)
BATCH="no"               # Batch mode (No prompts)
SILENT="no"              # Silent mode (No output Implies BATCH=yes)
CONTROL_FILE="ciao-control" # Control file name
CONTROL_LOCATION="ftp://cxc.harvard.edu/pub/ciao4.3/all"
CIAO_INSTALLED="ciao_installed" # installed file name
TMPDIR="/tmp"            # Directory to write tmp files
TMPNAME="tmp-ciao-install-$$" # name of temporary files
MYDATE="`date +%y-%m-%d.%H.%M.%S`"
LOGFILE_NAME="ciao-install-${MYDATE}.log"
WORKFILE="${TMPDIR}/${TMPNAME}"  # Workfile name
EXITFILE="${WORKFILE}-exit"
LOGDIR="`pwd`"           # Directory to write logfile in
LOGFILE="${LOGDIR}/${LOGFILE_NAME}" # Install log file
CIAOINSTALLRC="${HOME}/.ciaoinstall.rc"  # Name of user defaults file
FORCE_INSTALL="no"       # Install even if CIAO exists?
CONFIG_OPT=""            # extra configure options
POST_PROCESS="yes"       # do we run post processing?
DOWNLOAD_ONLY="no"       # Should we only download files?
INSTALL_ONLY="no"        # Should we only install local file?
NOCALDB="no"             # set to yes if CALDB area exists but is not writable
VERSION_STRING="ciao-install v1.1"
FORCE_FTP="no"           # force the use of ftp for downloads?
DELETE_TAR="n"           # Delete tar files after install
DEF_DELETE_TAR="n"       # Inital default for deleting tar files.

MD5SUM=""                # Location of md5 sum tool
MD5TYPE=""               # do we have md5 or md5sum
GTAR=""                  # Location of GNU tar
GUNZIP=""                # Location of GNU unzip
STARTDIR="`pwd`"         # Location where script is run from
FTPVERB=""               # Keep ftp quite
MFTPVERB="1>/dev/null 2>&1" # Keep ftp on Mac quite
WGETVERB="-q"            # Keep wget quite

UPDATE_DEF="no"          # Flag to test if default has changed

SYSERR="OK"
USED_FILES=""            # list of temp files opened by function
CIAO_DIR=""              # Base of CIAO from control file
DL_LOC=""                # Download location (base web address)
RET=""                   # Generic function returns.

# variables to handle the CALDB patch

declare -a EQV_LIST      # <segment> # a b c ..
                         # If any of the files for <segment> are installed, use the
                         # PATCH file and not the FILE file.

# Exit Codes

OK=0                      # No error
DL_DIR_DOES_NOT_EXIST=2   # Invalid download directory
INS_DIR_DOES_NOT_EXIST=3  # Invalid install directory
UNKNOWN_ARGUMENT=4        # Invalid command line argument
UNKNOWN_VERSION=5         # Unknown Version
UNKNOWN_FILE=6            # Unknown file
CALDB_NOT_FOUND=7         # User specified a CALDB directory that does not exist
INSUFFICIENT_SPACE=8      # Not enough disk space

printline()
{
    \echo $* >> ${LOGFILE}

    # if running in silent mode never print

    if [ "${SILENT}" == "no" ] ; then
	while [ "$#" -ne 0 ] ; do
	    \echo -n ${1}
	    shift
	    if [ "$#" -ne 0 ] ; then
		\echo -n " "
	    fi
	done
	\echo
    fi
}

printerror()
{
    # Prints out error message (printline checks for silent mode)
    # and exits if in batch mode.

    printline "ERROR: ${1}"
    if [ "${BATCH}" == "yes" ] ; then
	exit ${2}
    fi
}

retn()
{
    # Return the n'th argument

    let n=${1}
    shift
    while (( $n > 1 ))
    do
        let n=$n-1
        shift
    done
    echo ${1}
}

retnp()
{

    # Return all remaing arguments atarting from n

    let n=${1}
    shift
    while (( ${n} > 1 ))
    do
        let n=${n}-1
        shift
    done
    echo $@
}

remove_element()
{
    rem="${1}"
    shift
    while [ "$#" -ne 0 ] ; do
	if [ "${1}" != "${rem}" ] ; then
	    \echo -n "${1}"
	    shift
	    if [ "$#" -ne 0 ] ; then
		\echo -n " "
	    fi
	fi
    done
    \echo
}

callexit()
{
    \rm -f ${EXITFILE}
    echo ${1} > ${EXITFILE}
    exit ${1}
}

ci_reset()
{
    while [ "$#" -ne 0 ] ; do
	\rm -f ${1}
	\touch ${1}
	if [ "x${USED_FILES}" != "x" ] ; then
	    USED_FILES="${USED_FILES} ${1}"
	else
	    USED_FILES="${1}"
	fi
	shift
    done
}

rmall()
{
    # remove all temp work files

    while [ "$#" -ne 0 ] ; do
	\rm -f ${1}
	shift
    done
    USED_FILES=""
}     

check_file()
{
    if [ -f "${1}/${2}" ] ; then
	if [ "${MD5SUM}" != "x" ] ; then
	    if [ "x${3}" != "x" ] && [ "x${3}" != "x0" ] ; then
		printline "Verifying file ${2}" 
		check="`${MD5SUM} ${1}/${2}`"
		
	    # md5 and md5sum have different outputs
		
		if [ "${MD5TYPE}" != "md5sum" ] ; then
		    let ipos=4
		else
		    let ipos=1
		fi
		check="`retn ${ipos} ${check}`"
		if [ "x${check}" != "x${3}" ] ; then
		    ret="FAIL"
		    \rm -f "${EXITFILE}"
		    \echo ${UNKNOWN_FILE} > ${EXITFILE}
		    printerror "md5sum mismatched ${check} ${3}" 1
		else
		    ret="OK"
		fi
	    else
		ret="OK"
	    fi
	else
	    ret="OK"
	fi
    else
	ret="FAIL"
	\rm -f "${EXITFILE}"
	\echo ${UNKNOWN_FILE} > ${EXITFILE}
	printerror "Unable to download ${2}" 1
    fi
    RET=${ret}
}

check_space()
{

    # check to see if we have enough disk space to perform the operation

    ret=0
    \cd "${1}"
    space="`\df -k .`"
    let ispace="`retn 11 ${space}`"
    let nspace=${2}
    if (( ${ispace} < ${nspace} )) ; then
	printerror "Not enough space on ${1}. Requires: ${2} KB Space available: ${ispace} KB" ${INSUFFICIENT_SPACE}
	\rm -f ${EXITFILE}
	\echo ${INSUFFICIENT_SPACE} > "${EXITFILE}"
	exit ${INSUFFICIENT_SPACE}
    fi
    RET=${ret}
}

get_file()
{
    if [ "${INSTALL_ONLY}" != "yes" ] ; then
	\cd "${DL_DIR}"
	if [ "x${4}" != "x" ] ; then
	    check_space "${DL_DIR}" ${4}
	    if [ "${RET}" != "0" ] ; then
		exit ${RET}
	    fi
	fi
	
# compute the size of the download
	
	if [ "x${4}" != "x" ] &&  [ "x${4}" != "x0" ] ; then
	    let size=${4}
	    if (( ${size} < 1000 )) ; then
		sizemsg=" (${4} Kb)"
	    elif (( ${size} < 1000000 )) ; then
		let r=${size}%1000
		let size=(${size}-${r})/1000 
		if (( ${r} > 499 )) ; then
		    let size=${size}+1
		fi
		sizemsg=" (${size} Mb)"
	    else
		let r=${size}%1000000
		let size=(${size}-${r})/1000000 
		if (( ${r} > 499999 )) ; then
		    let size=${size}+1
		fi
		sizemsg=" (${size} Gb)"	
	    fi
	else
	    sizemsg=""
	fi
	printline "Downloading file ${2}${sizemsg} to ${DL_DIR}"
	case  "${OSTYPE}" in 
	    darwin* | Darwin* )
		realsys="OSX" ;;
	    * )
		realsys="other" ;;
	esac

# first try to download via wget

	if [ "${INSTALL_ONLY}" != "yes" ] ; then
	    ret="OK"
	    if [ "${WGET}" != "x" ] && [ "${realsys}" != "OSX" ] ; then
		${WGET} "${WGETVERB}" "${1}/${2}"
		if [ ! -f "${2}" ] ; then
		    printerror "Unable to retrieve ${1}/${2}" 1
		    ret="no"
		fi
# next try ftp
		
	    elif [ "${FTP}" != "x" ] ; then
		if [ "${realsys}" != "other" ] ; then
		    netrc="${WORKFILE}-netrc"
		    \echo "default" > ${netrc}
		    \echo "macdef" >> ${netrc}
		    \echo "init" >> ${netrc}
		    \echo "epsv4 off" >> ${netrc}
		    \echo "" >> ${netrc}
		    if [ "x${MFTPVERB}" != "x" ] ; then
			${FTP} -N ${netrc} -a ${1}/${2} 1>/dev/null 2>&1
		    else
			${FTP} -N ${netrc} -a ${1}/${2}
		    fi
		    if [ ! -f "${2}" ] ; then
			printerror "Unable to retrieve ${1}/${2}" 1
			ret="no"
		    fi
		    \rm -f ${netrc}
		else
		    ftpline="`echo ${1} | sed 'y-/- -'`"
		    ftpsys="`retn 2 ${ftpline}`"
		    Dir=""
		    let i=3
		    s="`retn $i ${ftpline}`"
		    while [ "x${s}" != "x" ]
		    do
			if [ "x${Dir}" != "x" ] ; then
			    Dir="${Dir}/${s}"
			else
			    Dir="${s}"
			fi
			i=${i}+1
			s="`retn ${i} ${ftpline}`"
			\rm -rf ${WORKFILE}-ftp
			\echo ${Dir} > ${WORKFILE}-ftp
		    done 
		    Dir="`cat ${WORKFILE}-ftp`"
		    \rm -rf ${WORKFILE}-ftp
		    File="`basename ${2}`"
		    ftpcmd="${WORKFILE}-ftp-commands"
		    \rm -f ${ftpcmd} ${FTPVERB}
		    if [ "x${FTPVERB}" == "x-v" ] ; then
			\echo "verbose" >> ${ftpcmd}
			\echo "trace" >> ${ftpcmd}
		    fi
		    \echo "open  ${ftpsys}" >> ${ftpcmd}
		    \echo "cd ${Dir}" >> ${ftpcmd}
		    \echo "binary" >> ${ftpcmd}
		    \echo "get ${File}" >> ${ftpcmd}
		    \echo "bye" >> ${ftpcmd}
		    cipid="$$-${MYDATE}"
		    if [ -f "${HOME}/.netrc" ] ; then
			\echo "Backing up ${HOME}/.netrc to ${HOME}/.netrc.ciao-install.${cipid}" >> ${LOGFILE}
			\mv -f "${HOME}/.netrc" ${HOME}/.netrc.ciao-install.${cipid}
		    fi
		    \echo "machine ${ftpsys}" > "${HOME}/.netrc"
		    \echo "login    anonymous" >> "${HOME}/.netrc"
		    \echo "password ciao-install@cfa.harvard.edu" >> "${HOME}/.netrc"
		    ${FTP} < ${ftpcmd}
		    \rm -f "${HOME}/.netrc"
		    if [ -f "${HOME}/.netrc.ciao-install.${cipid}" ] ; then
			\mv "${HOME}/.netrc.ciao-install.${cipid}" "${HOME}/.netrc"
		    fi
		    \rm -f ${ftpcmd}
		    if [ ! -f "${2}" ] ; then
			printerror "Unable to retrieve ${1}/${2}" 1
			ret="no"
		    fi
		fi
	    else
		printerror "ftp and wget are unavailable. Unable to download." 1
		ret="no"
	    fi
	    check_file ${DL_DIR} ${2} ${3}
	    retcf=${RET}
	    if [ "${retcf}" != "OK" ] ; then
		printerror "Bad Download. Please try again. If the problem continues Please contact the CXC helpdesk.(cxchelp@head.cfa.harvard.edu)" ${UNKNOWN_FILE}
		callexit ${UNKNOWN_FILE}
	    fi
	else
	    ret="no"
	fi
    else
	printerror "${DL_DIR}/${2} is missing. Please download." ${UNKNOWN_FILE}
	callexit ${UNKNOWN_FILE}
    fi
    RET="${ret}"
}

get_input()
{

    # get user input. Use readline to make things nice (-e)

    read -e -p "${1}: " INPUT dummy
    \echo ${INPUT}
}

su_task()
{

    # Do tasks that require super-user access (not valid in batch mode)

    if [ "${BATCH}" == "yes" ] ; then
	printerror "Unable to create / write ${2}" "${INS_DIR_DOES_NOT_EXIST}"
    else
	\rm -f "${WORKFILE}"
	\echo "#! /bin/bash" > "${WORKFILE}"
	md="`which mkdir`"
	co="`which chown`"
	if [ "${1}" == "mkdir" ] ; then
	    \echo "${md} -p ${2} 2>/dev/null" >> "${WORKFILE}"
	    \echo "${co} ${USER} ${2} 2>/dev/null" >> "${WORKFILE}"
	else
	    \echo "${co} ${USER} ${2} 2>/dev/null" >> "${WORKFILE}"
	fi
	\chmod +x "${WORKFILE}"
	
	case ${SYS} in
	    SunOS ) 
		su - root -c ${WORKFILE} ;;
	    Darwin* | darwin* )
		\chmod +x ${WORKFILE}
		sudo ${WORKFILE}
		if [ ! -d "${2}" ] ; then
		    printline "Unable to create directory with sudo. Trying su."
		    su - root -c ${WORKFILE}
		fi
		;;
	    * )
		su - root -c ${WORKFILE} ;;
	esac
	
	\rm -f ${WORKFILE}
    fi
}

get_defaults()
{
    \rm -f ${WORKFILE}
    if [ -f "${CIAOINSTALLRC}" ] ; then
        # Remember bash shells out loops so we need to store
        # the results when a match is found.
	\cat "${CIAOINSTALLRC}" |
	while read var def dummy
	do
            if [ "x${var}" != "x" ] && \
		[ "x`\echo ${var} | grep ^#`" == "x" ] && \
		[ "x${def}" != "x" ] ; then
		if [ "${var}" == "${1}" ] ; then
                    \echo ${def} > ${WORKFILE}
		fi
            fi
	done

	if [ -f ${WORKFILE} ] ; then
            RCRET=`cat ${WORKFILE}`
            \rm -f ${WORKFILE}
	else
            RCRET="NONE"
	fi
    else
	RCRET="NONE"
    fi
    \echo ${RCRET}
}

get_all_defaults()
{
    ret=`get_defaults DL_DIR`
    if [ "x${ret}" != "x" ] && [ "x${ret}" != "xNONE" ] ; then
	DEF_DL_DIR="${ret}"
    fi

    # if $ASCDS_INSTALL is set use $ASCDS_INSALL/.. 
    # instead of the default.

    if [ "x${ASCDS_INSTALL}" != "x" ] ; then
	DEF_INS_DIR="`dirname ${ASCDS_INSTALL}`"
    else
	ret=`get_defaults INS_DIR`
	if [ "x${ret}" != "x" ] && [ "x${ret}" != "xNONE" ] ; then
	    DEF_INS_DIR="${ret}"
	fi
    fi
    ret=`get_defaults CALDB_DIR`
    if [ "x${ret}" != "x" ] && [ "x${ret}" != "xNONE" ] ; then
	DEF_CALDB_DIR="${ret}"
    fi
    ret=`get_defaults RUN_SMOKE`
    if [ "x${ret}" != "x" ] && [ "x${ret}" != "xNONE" ] ; then
	DEF_RUN_SMOKE="${ret}"
    fi
    ret=`get_defaults DELETE_TAR`
    if [ "x${ret}" != "x" ] && [ "x${ret}" != "xNONE" ] ; then
	DEF_DELETE_TAR="${ret}"
    fi
}

test_missing()
{
    if [ "$#" == "1" ] ; then
	\echo "OK"
    else
	if [ "x${1}" == "xno" ] || [ "x${1}" == "xCommand" ] || [ "x${2}" == "xCommand" ] ; then
	    \echo "no"
	else
	    # there must be spaces in the path name to get here.
	    \echo "yes"
	fi
    fi
}

test_command()
{

    # Pull off te last thing from which as
    # Solaris can put extra junk on the which line

    var="`which ${1} 2>/dev/null`"
    savIFS=${IFS}
    IFS=$'\n'
    arr=( ${var} )
    IFS=${savIFS}
    tlen=${#arr[@]}
    if (( $tlen > 0 )) ; then
	results="${arr[(${tlen}-1)]}"
    else
	results=""
    fi

    if [ "x${results}" != "x" ] && [ "`test_missing ${results}`" == "OK" ] ; then 
	\echo "${results}"
    else
	\echo "no"
    fi
}

get_dir()
{
    ans=`get_input "(R)etry (C)reate or (E)xit?"`
    case ${ans}
	in
	R* | r* ) ANS="r" ;;
	C* | c* ) ANS="c" ;;
	E* | e* ) exit 0 ;;
	* ) ANS=r ;;
    esac
    if [ "${ANS}" == "c" ] ; then
	\mkdir -p ${1}
	if [ ! -d ${1} ] ; then
	    printerror "Unable to create ${1}"
	    ANS="r"
	fi
    fi

}

verify_tools()
{

    # see if we have GNU tar as tar

    istar=`test_command tar`

    if [ "x`${istar} --version 2>&1 | grep GNU`" != "x" ] || [ "x`${istar} --version 2>&1 | grep bsdtar`" != "x" ] ; then
	tarok="yes"
    else
	tarok="no"
    fi

    if [ "${istar}" != "no" ] && [ "${tarok}" != "no" ] ; then
	    GTAR="${istar} xf"
    else
	# maybe GNU tar is called gtar
	
	isgtar=`test_command gtar`
	
	if [ "${isgtar}" != "no" ] && [ "x`${isgtar} --version 2>&1 | grep GNU`" != "x" ] ; then
	    GTAR="${isgtar} xf"
	elif [ "${istar}" != "no" ] ; then
	    printline "Warning: GNU tar NOT Found! Some smoke tests will fail with Sun tar"
	    printline "Also some files in the CALDB may not expand to their correct name."
	    GTAR="${istar} xf"
	else
	    printerror "gtar or tar not found!" ${UNKNOWN_FILE}
	    exit ${UNKNOWN_FILE}
	fi
    fi

    # see if we have gunzip
    
    isgzip=`test_command gunzip`
    if [ "${isgzip}" != "no" ] ; then
	GUNZIP="${isgzip} -c"
    elif [ "`test_command gzip`" != "no" ] ; then
	# if gzip exists use it with the -d option
	isgzip=`test_command gzip`
	GUNZIP="${isgzip} -d -c"
    else
	# we need gzip
	printerror "gzip not found!" ${UNKNOWN_FILE}
	exit ${UNKNOWN_FILE}
    fi
    
    # see if we have md5sum
    
    ismd5sum="`test_command md5sum`"
    if [ "${ismd5sum}" != "no" ] ; then
	MD5SUM="${ismd5sum}"
	MD5TYPE="md5sum"
    else
	
        # On solaris the command is md5
	
	ismd5sum="`test_command md5`"
	if [ "${ismd5sum}" != "no" ] ; then
	    MD5SUM="${ismd5sum}"
	    MD5TYPE="md5"
	else	
	    MD5SUM="x"
	    ND5TYPE="x"
	    printline "Warning md5sum NOT found. File verification will NOT be done."
	fi
    fi
    
    # see if we have ftp
    
    isftp="`test_command ftp`"
    if [ "${isftp}" != "no" ] ; then
	FTP="${isftp}"
    else
	FTP="x"
    fi
    
    # see if we have wget

    if [ "${FORCE_FTP}" != "yes"  ] ; then
	iswget="`test_command wget`"
	if [ "${iswget}" != "no" ] ; then
	    WGET="${iswget}"
	else
	    WGET="x"
	fi
    else
	iswget="no"
	WGET="x"
    fi
    if [ "${WGET}" == "x" ] && [ "${FTP}" == "x" ] && [ "${INSTALL_ONLY}" != "yes" ] ; then
	printerror "ftp or wget required for downloads" 1
	exit 1
    fi
}

get_download_area()
{
    # Over-ride default if command line switch used
    
    CL_DL_DIR="`\echo ${CL_DL_DIR}`"
    if [ "x${CL_DL_DIR}" != "x" ] ; then
	if [ "x${CL_DL_DIR}" != "x${DEF_DL_DIR}" ] ; then
	    UPDATE_DEF="yes"
	    DEF_DL_DIR="${CL_DL_DIR}"
	fi
    fi
    
    # Prompt user if not in batch mode
    
    if [ "${BATCH}" == "no" ] ; then
	if [ "x${CL_DL_DIR}" == "x" ] ; then
	    prompt="Download directory for tar files (${DEF_DL_DIR})"
	    DL_DIR=`get_input "${prompt}"`
	else
	    DL_DIR="${CL_DL_DIR}"
	fi
	if [ "${DL_DIR}" == "." ] || [ "${DL_DIR}" == "./" ] ; then
	    DL_DIR="`pwd`"
	fi
    fi
    
    # this is to expand any use of ~
    
    DL_DIR="`\echo ${DL_DIR}`"
    
    # reset CL_DL_DIR in case input switch is invalid
    
    CL_DL_DIR=""
    
    # If a null string is entered, use default.
    
    if [ "x${DL_DIR}" == "x" ] ; then
	DL_DIR="${DEF_DL_DIR}"
    else
	UPDATE_DEF="yes"
    fi
    
    # Validate download directory
    
    if [ -d "${DL_DIR}" ] ; then
	STEP="2"
    else
	if [ "{BATCH}" != "yes" ] ; then
	    printline "ERROR: Download directory ${DL_DIR} not found!"
	    get_dir "${DL_DIR}"
	    if [ ${ANS} == "c" ] ; then
		\cd "${DL_DIR}"
		DL_DIR="`pwd`"
		STEP="2"
	    else
		STEP="1"
	    fi
	else
	    printerror "Download directory ${DL_DIR} not found!" ${DL_DIR_DOES_NOT_EXIST}
	    exit ${DL_DIR_DOES_NOT_EXIST}
	fi
    fi
}

get_install_area()
{
    # Over-ride default if command line switch userd

    CL_INS_DIR="`\echo ${CL_INS_DIR}`"
    if [ "${DOWNLOAD_ONLY}" != "yes" ] ; then
	if [ "x${CL_INS_DIR}" != "x" ] ; then
	    if [ "x${CL_INS_DIR}" != "x${DEF_INS_DIR}" ] ; then
		UPDATE_DEF="yes"
		DEF_INS_DIR="${CL_INS_DIR}"
	    fi
	fi
	
    # Prompt user if not in batch mode
	
	if [ "${BATCH}" == "no" ] ; then
	    if [ "x${CL_INS_DIR}" == "x" ] ; then
		prompt="CIAO installation directory (${DEF_INS_DIR})"
		INS_DIR=`get_input "${prompt}"`
	    else
		INS_DIR=${CL_INS_DIR}
	    fi
	    if [ "${INS_DIR}" == "." ] || [ "${INS_DIR}" == "./" ] ; then
		INS_DIR="`pwd`"
	    fi
	fi
	
	# this is to expand any use of ~
	
	INS_DIR="`\echo ${INS_DIR}`"
	
	# reset CL_INS_DIR in case input is invalid
	
	CL_INS_DIR=""
	
    # If a null string is entered, use default.
	
	if [ "x${INS_DIR}" == "x" ] ; then
	    INS_DIR="${DEF_INS_DIR}"
	else
	    UPDATE_DEF="yes"
	fi
	
    # Validate install directory
	
	if [ -d "${INS_DIR}" ] ; then
	    
	    # does the ciao-4.x directory exist?
	    
	    if [ -d "${INS_DIR}/${CIAO_DIR}" ] ; then
		
		# Yes it does now can we write in it?
		
		\touch "${INS_DIR}/${CIAO_DIR}/${TMPNAME}" 2>/dev/null
		if [ -f "${INS_DIR}/${CIAO_DIR}/${TMPNAME}" ] ; then
		    # good to go!
		    \rm -f "${INS_DIR}/${CIAO_DIR}/${TMPNAME}"
		    STEP="4"
		else
		    # We need write permission

		    su_task chown "${INS_DIR}/${CIAO_DIR}"
		    \touch "${INS_DIR}/${CIAO_DIR}/${TMPNAME}" 2>/dev/null
		    if [ -f "${INS_DIR}/${CIAO_DIR}/${TMPNAME}" ] ; then
		        # good to go!
			\rm "${INS_DIR}/${CIAO_DIR}/${TMPNAME}"
			STEP="4"
		    else
			printline "Error Cannot create ${INS_DIR}/${CIAO_DIR}"
			STEP="3"   # go back to step 3
		    fi
		fi
	    else
		
		# This is a new install of CIAO can we create the directory?
		
		\mkdir -p "${INS_DIR}/${CIAO_DIR}" 2>/dev/null
		if [ -d "${INS_DIR}/${CIAO_DIR}" ] ; then
		    
		    # good to go!
		    
		    STEP="4"
		else
		    # we need to get permission
		    su_task mkdir -p "${INS_DIR}/${CIAO_DIR}"
		    if [ -d "${INS_DIR}/${CIAO_DIR}" ] ; then
			
		        # good to go!
			
			STEP="4"
		    else
			printline "Error: Cannot get ownership of ${INS_DIR}/${CIAO_DIR}"
			STEP="3"
		    fi
		fi
	    fi
	else
	    printline "Error: Installation directory ${INS_DIR} not found!"
	    if [ "${BATCH}" != "yes" ] ; then
		get_dir "${INS_DIR}"
		if [ ${ANS} == "c" ] ; then
		    \cd "${INS_DIR}"
		    INS_DIR="`pwd`"
		    STEP="4"
		else
		    STEP="3"
		fi
	    else
		exit ${INS_DIR_DOES_NOT_EXIST}
	    fi
	fi
    else
	STEP=4
    fi
}

run_smoke_tests()
{
    if [ "${BATCH}" == "no" ] && [ "${DOWNLOAD_ONLY}" != "yes" ] && [ "${SYSERR}" == "OK" ] ; then
	ans=`get_input "Run smoke tests? (y|n) (${DEF_RUN_SMOKE})"`
	if [ "x${ans}" == "x" ] ; then
	    RUN_SMOKE="${DEF_RUN_SMOKE}"
	    STEP="5"
	else
	    UPDATE_DEF="yes"
	    case ${ans} in
		y* | Y* ) RUN_SMOKE="y"
		    STEP="5" ;;
		n* | N* ) RUN_SMOKE="n"
		    STEP="5" ;;
		* ) STEP="4" ;;
	    esac
	fi
    else
	RUN_SMOKE="n"
	STEP="5"
    fi
}

delete_tar_files()
{
    if [ "${BATCH}" == "no" ] && [ "${DOWNLOAD_ONLY}" != "yes" ] && [ "${SYSERR}" == "OK" ] && [ "${DELETE_TAR}" != "yes" ] ; then
	ans=`get_input "Delete tar files after install? (y|n) (${DEF_DELETE_TAR})"`
	if [ "x${ans}" == "x" ] ; then
	    DELETE_TAR="${DEF_DELETE_TAR}"
	    STEP="6"
	else
	    UPDATE_DEF="yes"
	    case ${ans} in
		y* | Y* ) DELETE_TAR="yes"
		    STEP="6" ;;
		n* | N* ) DELETE_TAR="no"
		    STEP="6" ;;
		* ) STEP="5" ;;
	    esac
	fi
    else
	DELETE_TAR="${DEF_DELETE_TAR}"
	STEP="6"
    fi
}

replace_space()
{

    # replaces empty space with ${1}

    char=${1}
    \echo -n "${char}"
    shift
    while [ "$#" -ne 0 ] ; do
	\echo -n ${1}
	shift
	\echo -n "${char}"
    done
    \echo
}

read_version()
{

   # get the versions of installed files
    
    \rm -f "${WORKFILE}"
    touch "${WORKFILE}"
    if [ -f "${INS_DIR}/${CIAO_DIR}/${INSTALLED_FILE}" ] ; then
	\cat "${INS_DIR}/${CIAO_DIR}/${INSTALLED_FILE}" |
	while read file_name dummy
	do
	    if [ "x${file_name}" != "x" ] ; then
		\echo "${file_name} " >> "${WORKFILE}"
	    fi
	done
    fi
    INSTALLED_LIST="`cat ${WORKFILE}`"
    \rm -f "${WORKFILE}"
}

build_dep()
{
    # build dependency list

    \rm -f "${WORKFILE}-bd"
    \echo "${SEGMENTS}" > "${WORKFILE}-bd"
    tmpseg="`replace_space X ${SEGMENTS}`"
    while [ "$#" -ne 0 ] ; do
	if [ "${1}" == "-" ] ; then
	    break
	else
	    # add in segments not already there

	    if [ "x`\echo ${tmpseg} | grep X${1}X`" == "x" ] ; then
		SEGMENTS="${SEGMENTS} ${1}"
		tmpseg="${tmpseg}${1} "
		rm -f  "${WORKFILE}-bd"
		\echo "${SEGMENTS}" > "${WORKFILE}-bd"
	    fi
	fi
	shift
    done
    SEGMENTS="`cat ${WORKFILE}-bd`"
    \rm -f "${WORKFILE}-bd"
    \echo "${SEGMENTS}"
}

read_control()
{

    # get the latest control file

    \cd "${DL_DIR}"
    if [ "${INSTALL_ONLY}" != "yes" ] ; then
	if [ -f "${CONTROL_FILE}" ] ; then
	    \mv -f "${CONTROL_FILE}" "${CONTROL_FILE}.bak"
	fi
	get_file "${CONTROL_LOCATION}" "${CONTROL_FILE}" "0" "1"
	ret=${RET}
	if [ "${ret}" != "OK" ] ; then
	    if [ -f "${CONTROL_FILE}.bak" ] ; then
		printline "Cannot download ${CONTROL_FILE}. Using existing file."
		\mv -f "${CONTROL_FILE}.bak" "${CONTROL_FILE}"
	    else
		printerror "Cannot download control file ${CONTROL_FILE}" ${UNKNOWN_ARGUMENT}
		exit ${UNKNOWN_ARGUMENT}
	    fi
	fi
    else
	if [ ! -f "${CONTROL_FILE}" ] ; then
	    printerror "CIAO control file ${DL_DIR}/${CONTROL_FILE} is missing. Cannot install." ${UNKNOWN_ARGUMENT}
	    exit ${UNKNOWN_ARGUMENT}
	fi
    fi

    # Read the control file to see whats available
    
    wfbase="${WORKFILE}-BASE"
    ci_reset ${wfbase} ${newseg}
    
    if [ -f "${DL_DIR}/${CONTROL_FILE}" ] ; then
	var="`cat ${DL_DIR}/${CONTROL_FILE}`"
	savIFS=${IFS}
	IFS=$'\n'
	arr=( ${var} )
	IFS=${savIFS}
	tlen=${#arr[@]}
	n=0;
	tmpsubset=""
	subsetlen=-1;
	while [ ${n} -lt ${tlen} ] ; do
	    tag="`retn 1 ${arr[$n]}`"

	    # the second argument is always used so to save processing
	    # it is assigned it's own variable.
	    v1="`retn 2 ${arr[$n]}`"

	    # only process non-blank non-comment lines


	    if [ "x${tag}" != "x" ] && [ "x${tag}" != "x#" ] ; then
		case ${tag} in
		    BASE )
			\echo ${v1} >> ${wfbase}
			CIAO_DIR="${v1}"
			export CIAO_DIR
                        # See if we are installing over a differnt system

			if [ -f "${INS_DIR}/${CIAO_DIR}/${CIAO_INSTALLED}" ] ; then
			    coretest="`grep bin-core ${INS_DIR}/${CIAO_DIR}/${CIAO_INSTALLED}`"
			    if [ "x${coretest}" != "x" ] ; then
				teststr="core-${SYS}.tar"
				if [ "x`echo ${coretest} | grep core-${SYS}.tar`" == "x" ] ; then
				    printerror "Trying to install system ${SYS} when `retn 2 ${coretest}` is already installed." 1
				    exit 1
				fi
			    fi
			fi			
			;;
		    VERSION )
			if [ "`retnp 2 ${arr[$n]}`" != "${VERSION_STRING}" ] ; then
			    ver_num="`retnp 3 ${arr[$n]}`"
			    printline "+++ NOTICE: a newer version of ciao-install is available (${ver_num}) +++"
			    printline "       You are using ${VERSION_STRING}"
			fi
			;;
		    VALID )
			if [ "${v1}" != "-" ] ; then
			    VALID_SEG="${VALID_SEG} `retnp 2 ${arr[$n]}`"
			else
			    # Validate segments in SEGMENTS variable
			    vset_X="`replace_space X ${VALID_SEG}`"
			    let m=1;
			    while [ "x`retn ${m} ${SEGMENTS}`" != "x" ] ; do
				Xseg="X`retn ${m} ${SEGMENTS}`X"
				test_seg="`\echo ${vset_X} | grep ${Xseg}`"
				if [ "x${test_seg}" == "x" ] ; then
				    printerror "Segment `retn ${m} ${SEGMENTS}` is not valid." 1
				    exit 1
				fi
				let m=${m}+1;
			    done
			fi
			;;
		    DL )
			dlarea="${v1}"
			;;
		    DEP )

			# build dependency list

			seg_X="`replace_space X ${SEGMENTS}`"
			if [ "${v1}" != "-" ] ; then
			    if [ "x`\echo ${seg_X} | grep X${v1}X`" != "x" ] ; then
				seg_string="`retnp 2 ${arr[$n]}`"
				seg="`build_dep ${seg_string}`"
				SEGMENTS="${seg}"
			    fi
			else
			    if [[ ${subsetlen} -ne -1 ]] ; then
				let i=0;
				while [ ${i} -lt ${subsetlen} ] ; do
				    # if both files in the subset exist in SEGMENTS
				    # remove the first
				    sub1="`retn 1 ${subsetarr[${i}]}`"
				    sub2="`retn 2 ${subsetarr[${i}]}`"
				    if [ "x`\echo ${seg_X} | grep X${seg1}X`" != "x" ] && [ "x`\echo ${seg_X} | grep X${seg2}X`" != "x" ] ; then
					SEGMENTS="`remove_element ${sub1} ${SEGMENTS}`"
				    fi
				    let i=${i}+1;
				done
			    fi
			fi
			;;
		    SYS )
			if [ "x`retn 2 ${arr[$n]}`" == "xall" ] ; then
			    lsys="${SYS}"
			else
			    lsys="${v1}"
			fi
			;;
		    SEG )
			if [ "x${lsys}" == "x${SYS}" ] ; then
			    if [ "x`\echo ${seg_X} | grep X${v1}X`" != "x" ] ; then
				getseg="${v1}"
			    else
				getseg="no"
			    fi
			fi
			;;
		    SUBSET )
			# Segment 2 is a subset of segment 1
			if [ "${v1}" != "-" ] ; then
			    v2="`retn 3 ${arr[$n]}`"
			    tmpsubset="${tmpsubset}${v1} ${v2}$'\n'"
			else
			    savIFS="${IFS}"
			    IFS=$'\n'
			    subsetarr=( ${tmpsubset} )
			    IFS="${savIFS}"
			    subsetlen=${#subsetarr[@]}
			fi
			;;
		    FILE )
			if [ "x${lsys}" == "x${SYS}" ] && [ "${getseg}" != "no" ] ; then
			    case "${getseg}" in
				CALDB* )
				    if [ "${NOCALDB}" != "yes" ] ; then
                                        if [ "${CALDB_DIR}" != "CIAO" ] && [ "${CALDB_DIR}" != "${INS_DIR}/${CIAO_DIR}/CALDB" ] ; then
                                            if [ ! -e "${INS_DIR}/${CIAO_DIR}/CALDB" ] ; then
                                                ln -s "${CALDB_DIR}" "${INS_DIR}/${CIAO_DIR}/CALDB"
                                            fi
                                        fi
					ins="${INS_DIR}/${CIAO_DIR}/CALDB"
					if [  "${getseg}" == "CALDB_main" ] ; then
					    CHECKCAL="yes"
					fi
					eqv="`check_eqv ${getseg}`"
					if [ "${eqv}" == "FILE" ] || [ "${eqv}" == "no" ] ; then
					    install_file "${dlarea}" "${ins}" "`retn 2 ${arr[$n]}`" "`retn 3 ${arr[$n]}`" "`retn 4 ${arr[$n]}`" "`retn 5 ${arr[$n]}`"
					elif [ "${eqv}" == "yes" ] ; then
					    printline "File CALDB main already installed ${ins}"
					fi
				    else
					printline "Omiting install of CALDB file ${v1}"
				    fi
				    ;;
				* )
				    ins="${INS_DIR}"
				    install_file "${dlarea}" "${ins}" "`retn 2 ${arr[$n]}`" "`retn 3 ${arr[$n]}`" "`retn 4 ${arr[$n]}`" "`retn 5 ${arr[$n]}`"
				    ;;
			    esac
			fi
			;;
		    PATCH )
			if [ "x${lsys}" == "x${SYS}" ] && [ "${getseg}" != "no" ] ; then
			    eqv="`check_eqv ${getseg}`"
			    if [ "${eqv}" == "PATCH" ] ; then
				if [ "${CALDB_DIR}" == "CIAO" ] ; then
				    cdb="${CIAO_DIR}/CALDB"
				else
				    cdb="${CALDB_DIR}"
				fi
				install_patch "${dlarea}" "`retn 2 ${arr[$n]}`" "`retn 3 ${arr[$n]}`" "`retn 4 ${arr[$n]}`" "`retn 5 ${arr[$n]}`" "${cdb}"
			    elif [ "${eqv}" == "no" ] ; then
				install_patch "${dlarea}" "`retn 2 ${arr[$n]}`" "`retn 3 ${arr[$n]}`" "`retn 4 ${arr[$n]}`" "`retn 5 ${arr[$n]}`"
			    fi
			fi
			;;
		    EQV )
			# read in what installed files qualify for downloading the patch

			# This should be generalized someday so multiple EQV statuments
                        # can be used.

			EQV_LIST=(`retnp 2 ${arr[$n]}`)
			;;
		    * )
			printline "Unimplemented tag ${tag} in control file"
			printline "Your copy of ciao-install may be old."
			;;
		esac
	    fi
	    let n=${n}+1;
       done
    fi
    CIAO_DIR="`\cat ${wfbase}`"
    rmall ${USED_FILES}
}

write_defaults()
{
    if [ "x${INS_DIR}" == "x" ] ; then
	ret=`get_defaults INS_DIR`
	if [ "x${ret}" != "x" ] && [ "x${ret}" != "xNONE" ] ; then
	    INS_DIR="${ret}"
	fi
    fi
    if [ "x${CALDB_DIR}" == "x" ] ; then
	ret=`get_defaults CALDB_DIR`
	if [ "x${ret}" != "x" ] && [ "x${ret}" != "xNONE" ] ; then
	    CALDB_DIR="${ret}"
	fi
    fi
    \rm -f "${CIAOINSTALLRC}"
    \echo "# This is a generated file. Do not edit." > "${CIAOINSTALLRC}"
    \echo "# Download directory" >> "${CIAOINSTALLRC}"
    \echo "DL_DIR ${DL_DIR}" >> "${CIAOINSTALLRC}"
    \echo "# Install directory" >> "${CIAOINSTALLRC}"
    \echo "INS_DIR ${INS_DIR}" >> "${CIAOINSTALLRC}"
    \echo "# CALDB directory" >> "${CIAOINSTALLRC}"
    \echo "CALDB_DIR ${CALDB_DIR}" >> "${CIAOINSTALLRC}"
    \echo "# Run Smoke tests upon completion?" >> "${CIAOINSTALLRC}"
    \echo "RUN_SMOKE ${RUN_SMOKE}" >> "${CIAOINSTALLRC}"
    \echo "# Delete download tar files after update?" >> "${CIAOINSTALLRC}"
    \echo "DELETE_TAR ${DELETE_TAR}" >> "${CIAOINSTALLRC}"
}

update_defaults()
{
    if [ "${BATCH}" == "no" ] && [ "${UPDATE_DEF}" == "yes" ] ; then
	ans=`get_input "Save these settings? (y|n) (y)"`
	if [ "x${ans}" == "x" ] ; then
	    write_defaults
	    STEP="done"
	else
	    case ${ans} in
		y* ) write_defaults
		    STEP="done" ;;
		Y* ) write_defaults
		    STEP="done" ;;
		n* ) STEP="done" ;;
		N* ) STEP="done" ;;
		* ) STEP="6" ;;
	    esac
	fi
    else
	STEP="done"
    fi
}

get_user_input()
{

    # here is the processing loop. This will allow users to go back to 
    # previous prompt if needed.

    STEP="1"
    while [ "${STEP}" != "DONE" ] ; do
	case ${STEP} in
	    0 ) exit ${OK} ;;
	    1 ) get_download_area ;;
	    2 ) STEP="3" ;;
	    3 ) get_install_area ;;
	    4 ) run_smoke_tests ;;
	    5 ) delete_tar_files ;;
	    6 ) update_defaults ;;
            * ) STEP="DONE" ;;
	esac
    done
}

check_install()
{

    # Unless force install is set, read the installed-file file.

    \rm -f "${WORKFILE}-ci"
    \echo no >  "${WORKFILE}-ci"
    if [ "x${FORCE_INSTALL}" != "xyes" ] ; then
	if [ -f "${INS_DIR}/${CIAO_DIR}/${CIAO_INSTALLED}" ] ; then
	    \cat "${INS_DIR}/${CIAO_DIR}/${CIAO_INSTALLED}" | 
	    while read ftype fname dummy
	    do
		if [ "x${fname}" == "x${2}" ] ; then
		    \rm -f  "${WORKFILE}-ci"
		    \echo yes >  "${WORKFILE}-ci"
		    break
		fi
	    done
	fi
    fi
    ret=`\cat "${WORKFILE}-ci"`
    \rm -rf  "${WORKFILE}-ci"
    \echo "${ret}"
}

check_eqv()
{

    # check to see if we should apply the PATCH file or the FILE file.
    # This should be generalized someday so multiple EQV statuments
    # can be used.

    # Return codes:
    # no - none of the files are installed
    # yes - An equivlent file is installed
    # PATCH - The patch file is required
    # FILE - The full file is required

    if [ "${EQV_LIST[0]}" != "${1}" ] ; then
	\echo "no"
    elif [ "`check_install x ${EQV_LIST[1]}`" == "yes" ] ; then
	\echo "yes"
    elif [ "`check_install x ${EQV_LIST[2]}`" == "yes" ] ; then
	\echo "yes"
    else
	\rm -f "${WORKFILE}-eqv"
	let max=${EQV_LIST[3]}+4
	for (( i=4 ; i<${max} ; i++ )) ; do
	    if [ "`check_install x ${EQV_LIST[${i}]}`" == "yes" ] ; then
		\touch  "${WORKFILE}-eqv"
	    fi
	done
	if [ -f "${WORKFILE}-eqv" ] ; then
	    echo "PATCH"
	    \rm -rf "${WORKFILE}-eqv"
	else
	    echo "FILE"
	fi
    fi
}


check_download()
{
    # does the file exist in the download directory
    # and is it complete?

    if [ -f "${DL_DIR}/${2}" ] ; then
	if [ "x${INSTALL_ONLY}" != "xyes" ] ; then
	    check_file "${DL_DIR}" "${2}" "${3}"
	    if [ "${RET}" != "OK" ] || [ "x${3}" == "x" ] || [ "x${3}" == "x0" ] ; then
		printline "Removing bad file ${DL_DIR}/${2}"
		\rm -f ${EXITFILE}
		\rm -f "${DL_DIR}/${2}"
		ret="no"
	    else
		ret="yes"
	    fi
	else
	    ret="yes"
	fi
    else
	ret="no"
    fi
    RET=${ret}
}

install_file()
{
# install a CIAO tar / contrib tar / CALDB tar file

    dlfile="${3}"

    # Don't bother checking if installed if we are only downloading.
    if [ "${DOWNLOAD_ONLY}" != "yes" ] ; then
	result="`check_install ${1} ${dlfile} ${4} ${5}`"
    else
	result="no"
    fi
    if [ "${result}" == "no" ] ; then
	
	# do not install if file already installed
	
	check_download "${1}" "${dlfile}" "${4}" "${5}"
	resultcd="${RET}"

	do_install="no"
	if [ "${resultcd}" == "no" ] ; then

            # do not install if download only

	    get_file "${1}" "${dlfile}" "${4}" "${5}" "${6}"
	    resultgf="${RET}"
	    if [ "${resultgf}" == "OK" ] && [ "${DOWNLOAD_ONLY}" != "yes" ] ; then
		do_install="yes"
	    fi
	elif [ "${DOWNLOAD_ONLY}" != "yes" ] ; then 
	    do_install="yes"
	else
	    printline "File exists in download directory. Skipping"
	fi
	if [ "${do_install}" != "no" ] ; then
	    if [ ! -f "${DL_DIR}/${dlfile}" ] ; then
		printerror "Unable to download ${3}"
		exit 1
	    fi
	    if [ ! -d "${2}" ] ; then
		\mkdir -p "${2}"
	    fi
	    \cd "${2}"
	    
	    # use proper decompress method

	    if [ "x${7}" != "x" ] ; then
		cd "${INS_DIR}/${7}"
		printline "Installing file ${DL_DIR}/${3} to ${7}"
		loc="${INS_DIR}/${7}"
	    else
		printline "Installing file ${DL_DIR}/${3} to ${2}"
		loc="${2}"
	    fi
	    if [ "x${6}" != "x" ] ; then
		check_space "${loc}" "${6}"
		if [ "${RET}" != "0" ] ; then
		    exit ${RET}
		fi
	    fi
	    case "${dlfile}" in
		*tar.gz )
		    ${GUNZIP} "${DL_DIR}/${dlfile}" | ${GTAR} -  2>> ${LOGFILE} ;;
		*.tgz )
		    ${GUNZIP} "${DL_DIR}/${dlfile}" | ${GTAR} -  2>> ${LOGFILE} ;;
		*.tar )
		    ${GTAR} "${DL_DIR}/${dlfile}" 2>> "${LOGFILE}" ;;
		* )
		    printerror "Unknown file type ${dlfile}" ${UNKNOWN_FILE} ;;
	    esac

	    # should we clean up the tar files when done?
	    if [ "${DELETE_TAR}" == "yes" ] ; then
		\rm -f "${DL_DIR}/${dlfile}"
	    fi

	    # check to see if an update script is packaged with the file.

	    if [ -f "${INS_DIR}/${CIAO_DIR}/ciao_fix.sh" ] ; then
		\cd "${INS_DIR}/${CIAO_DIR}"
		./ciao_fix.sh
		\mv -f ciao_fix.sh ciao_fix.sh.${2}
	    fi

	    # file processed write uniquely to installed file list.
	    if [ -f "${INS_DIR}/${CIAO_DIR}/${CIAO_INSTALLED}" ] ; then
		if [ "x`grep ${3} ${INS_DIR}/${CIAO_DIR}/${CIAO_INSTALLED}`" == "x" ] ; then
		    \echo "FILE ${dlfile}" >> "${INS_DIR}/${CIAO_DIR}/${CIAO_INSTALLED}"
		fi
	    else
		\echo "FILE ${dlfile}" > "${INS_DIR}/${CIAO_DIR}/${CIAO_INSTALLED}"
	    fi

	    # See if we should delete tar files?

	    if [ "${DELETE_TAR}" == "yes" ] ; then
		\rm -f "${DL_DIR}/${dlfile}"
	    fi
	fi
    else
	printline "File ${dlfile} already installed in ${2}"
    fi
 }

install_patch()
{
# install a patch file

    # check to make sure an old patch script dosen't esist
    if [ -f "${INS_DIR}/${CIAO_DIR}/ciao_patch.sh" ] ; then
	\mv -f "${INS_DIR}/${CIAO_DIR}/ciao_patch.sh" "${INS_DIR}/${CIAO_DIR}/ciao_patch.sh.OLD"
    fi
    install_file "${1}" "${INS_DIR}" "${2}" "${3}" "${4}" "${5}" "${6}"

    # if all went well, we should have a patch script ready to go.
    # if there was an error, it would of been already reported.

    if [ -f "${INS_DIR}/${CIAO_DIR}/ciao_patch.sh" ] ; then
	\cd "${INS_DIR}/${CIAO_DIR}"
	ins_source=""
	if [ -d src ] ; then
	    ins_source="-b"
	fi
	./ciao_patch.sh  ${ins_source}
	\mv -f ciao_patch.sh ciao_patch.sh.${2}
	\mv -f ciao_cleanup.sh ciao_cleanup.sh.${2}
    fi
}

post_process()
{

    # first check to see if we need to make the CALDB link

    if [ "x${NOCALDB}" == "xyes" ] ; then
	\rm -rf "${INS_DIR}/${CIAO_DIR}/CALDB"
	\cd "${INS_DIR}/${CIAO_DIR}"
	ln -s ${CALDB_DIR} CALDB
    fi

    if [ "${POST_PROCESS}" == "yes" ] ; then

	# check if we need to chcon the libraries

	ischcon=`test_command chcon`
	if [ "${ischcon}" != "no" ] && [ "`uname -s`" == "Linux" ] ; then
	    printline "running chcon to allow CIAO to work with SELinux"
	    \cd "${INS_DIR}/${CIAO_DIR}"
	    \chcon -R -t textrel_shlib_t * >> ${LOGFILE} 2>/dev/null
	fi

        # run configure
	
	printline "Running configure ./configure ${CONFIG_OPT}"

	# test to see if we have caldb4 source installed

	if [ -f src/libdev/caldb4/configure ] ; then
	    PATH="`pwd`/ots/bin:${PATH}"
	    PKG_CONFIG_PATH="`pwd`/ots/lib/pkgconfig"
	    if [ -f src/config/fixpc.sh ] ; then
		bash src/config/fixpc.sh "`pwd`"
	    fi
	fi

	\cd "${INS_DIR}/${CIAO_DIR}"
	./configure >> "${LOGFILE}" 2>&1
	
        # re-create the ahelp index
	
	. bin/ciao.bash -o >> "${LOGFILE}"
	if [ -f bin/ahelp ] ; then
	    printline "Re-indexing ahelp system"
	    ahelp -r 1>/dev/null
	fi
	
	# run python fix script

	if [ -f bin/ciao-python-fix ] ; then
	    printline "Creating binary compiled python modules"
	    bash bin/ciao-python-fix 1>/dev/null
	fi

	# If users have installed source, run the fixpc.sh script

	if [ -f src/config/fixpc.sh ] ; then
	    printline "Fixing package config files."
	    bash src/config/fixpc.sh 1>/dev/null 2>&1
	fi

    # if smoke tests are to be run do it now
	
	if [ "x${RUN_SMOKE}" == "xy" ] && [ -f bin/ahelp ] ; then
	    printline "Running smoke tests"
	    \cd test

	    # Make sure the smoke directory is removed

	    if [ -d "${ASCDS_TMP}/smoke.${USER}" ] ; then
		\rm -rf "${ASCDS_TMP}/smoke.${USER}"
	    fi

	    # Make sure we have make
	    ismake=`test_command make`
	    if [ "${ismake}" != "no" ] ; then
		${ismake} -k | tee -a "${LOGFILE}"
	    else
		if [ -f "${ASCDS_WORK_PATH}/smoke.${LOGNAME}/smoketests.txt" ];
		then
		    \rm -f "${ASCDS_WORK_PATH}/smoke.${LOGNAME}/smoketests.txt"
		fi
		if [ ! -d "${ASCDS_WORK_PATH}/smoke.${LOGNAME}" ]; then
		    \mkdir -p "${ASCDS_WORK_PATH}/smoke.${LOGNAME}"
		fi
		\ls "${INS_DIR}/${CIAO_DIR}"/test/smoke/bin/*-smoke*.sh > \
		    "${ASCDS_WORK_PATH}/smoke.${LOGNAME}/smoketests.txt"
		"${INS_DIR}/${CIAO_DIR}"/test/bin/run_smoke_test.sh | tee -a \
		    "${LOGFILE}"
	    fi
	    \sync
	    failures="`grep FAIL ${LOGFILE}`"
	    if [ "x${failures}" != "x" ] ; then
		printline " "
	    else
		printline "Smoke tests complete. All tests passed!"
	    fi
	fi
    fi

    # re-run configure if other install options are passed

    if [ "x${CONFIG_OPT}" != "x" ] ; then
	\cd "${INS_DIR}/${CIAO_DIR}"
	\rm -rf  config.log config.cache config.status
	./configure ${CONFIG_OPT} >> ${LOGFILE} 2>&1
    fi

    # All done print log location

    printline "Processing complete!"
    printline "Script Log file is ${LOGFILE}"
    \cd "${STARTDIR}"
}

usage()
{
    \echo "${VERSION_STRING}"
    \echo 
    \echo "Usage: ${0} [options...]"
    \echo
    \echo "  -h --help Print this message"
    \echo "  --download-only Download only Do not install"
    \echo "  --install-only  Install only Do not download"
    \echo "  --download <dir> Download directory"
    \echo "  --prefix <dir> Install directory"
    \echo "  --logdir <dir> Log file directory"
    \echo "  --config <--with-top=dir> Extra configure switches"
    \echo "  --caldb <dir> Location of the CALDB"
    \echo "  --system <system> System to install"
    \echo "           (Linux, Linux64 sun10, osxi osx64)"
    \echo "  --batch Batch mode (no prompts)"
    \echo "  --silent Silent mode (implies batch) No tty output"
    \echo "  --delete-tar Delete tar files after install."
    \echo "  --add <segment> Add additional segment to CIAO"
    \echo "  -f --force Force re-install"
    \echo "  -v --version Report version and exit"
}

unsupport_sys()
{
    printline "Warning Unsupported system."
    if [ "INSTALL_ONLY" == "yes" ] ; then
	printerror "Cannot install."
	exit 1
    fi
    if [ "DOWNLOAD_ONLY" != "yes" ] ; then    
	printline "Downloading CIAO only, will not install."
	DOWNLOAD_ONLY="yes"
    fi
}


# Get User command line options

\umask 022
CL="$0 $@"
while [ "$#" -ne 0 ]
do
    case "${1}" in
	--download-only | --download-onl | --download-on | --download-o | --download- )
	    DOWNLOAD_ONLY="yes"
	    if [ "${INSTALL_ONLY}" != "no" ] ; then
		\echo "Conflicting switch with --download-only"
		exit  ${UNKNOWN_ARGUMENT}
	    fi
	    if [ "x${FORCE_INSTALL}" == "xyes" ] ; then
		\echo "-f or --force not compatible with --download-only"
		exit 1
	    fi ;;
	--install-only | --install-onl | --install-on | --install-o | --install- )
	    INSTALL_ONLY="yes"
	    if [ "${DOWNLOAD_ONLY}" != "no" ] ; then
		\echo "Conflicting switch with --install-only"
		exit  ${UNKNOWN_ARGUMENT}
	    fi ;;
	--download )
	  # Download directory (may be directory or link to directory
	    
	    if [ "x${2}" != "x" ] ; then
		CL_DL_DIR="${2}"
		if [ "${CL_DL_DIR}" == "." ] || [ "${CL_DL_DIR}" == "./" ] ; then
		    CL_DL_DIR="${STARTDIR}"
		else

# get full directory name if the user selects a relative path

		    if [ -d "${CL_DL_DIR}" ] ; then
			cd "${CL_DL_DIR}"
			CL_DL_DIR="`pwd`"
			cd "${STARTDIR}"
		    else
			printerror "Download directory ${CL_DL_DIR} Does not exist!" ${DL_DIR_DOES_NOT_EXIST}
			exit ${DL_DIR_DOES_NOT_EXIST}
		    fi
		fi
		shift
	    else
		printerror "Argument expected for ${1}" ${UNKNOWN_ARGUMENT}
		exit ${DL_DIR_DOES_NOT_EXIST}
	    fi ;;
	--prefix | --prefi | --pref | --pre )  # install directory
	    if [ "x${2}" != "x" ] ; then
		CL_INS_DIR=${2}
		if [ "${CL_INS_DIR}" == "." ] || [ "${CL_INS_DIR}" == "./" ] ; then
		    CL_INS_DIR="`pwd`"
		    CL_DL_DIR="${STARTDIR}"
		else

# get full directory name if the user selects a relative path.

		    if [ -d "${CL_INS_DIR}" ] ; then
			cd "${CL_INS_DIR}"
			CL_INS_DIR="`pwd`"
			cd "${STARTDIR}"
		    else
			printerror "Install directory ${CL_INS_DIR} Does not exist!" ${CL_DIR_DOES_NOT_EXIST}
			exit ${CL_DIR_DOES_NOT_EXIST}
		    fi
		fi
		shift
	    else
		\echo "Argument expected for ${1}"
		exit ${INS_DIR_DOES_NOT_EXIST}
	    fi  ;;
	--system | --sy | --sys | --syst | --syste ) # system to install
	    if [ "x${2}" != "x" ] ; then
		case "${2}" in
		    linux64 | LINUX64 )
			SYS="Linux64" ;;
		    SUN10 | sun10 | sun | SUN | Solaris | solaris | SOLARIS )
			SYS="sun10" ;;
		    Osxi | OSXI | osxi )
			SYS="osxi" ;;
		    linux | LINUX )
			SYS="Linux" ;;
		    Osx64 | OSX64 | osx64 )
			SYS="osx64" ;;
		    * )			
			SYS="${2}" ;;
		esac
		shift
	    else
		printerror "Argument expected for ${1}" ${UNKNOWN_ARGUMENT}
		exit ${UNKNOWN_ARGUMENT}
	    fi  ;;
	--batch ) # batch mode No prompts, use defaults
	    BATCH="yes" ;;
	--silent | --silen | --sile | --sil | --si )  # silent mode (Implies batch mode)
            SILENT="yes"
	    BATCH="yes" ;;
	--config )  # extra configure switches
	    if [ "x${2}" != "x" ] ; then
		CONFIG_OPT="${2}"
	    else
		\echo "Argument expected for ${1}"
		exit ${UNKNOWN_ARGUMENT}
	    fi ;;
	--logdir | --logdi | --logd | --log | --lo | --l  | -l )
	    if [ "x${2}" != "x" ] ; then
		# Make sure directory exists and is writable

		if [ "${2}" == "." ] || [ "${2}" == "./" ] ; then
		    LOGDIR="`pwd`"
		else
		    LOGDIR="`\echo ${2}`"
		fi
	        if [ ! -d "${LOGDIR}" ] ; then
		    \echo "Invalid argument for --logdir ${LOGDIR}"
		    exit ${UNKNOWN_ARGUMENT}
		fi
		LOGFILE="${LOGDIR}/${LOGFILE_NAME}"
		\touch "${LOGFILE}"
		if [ ! -f "${LOGFILE}" ] ; then
		    \echo "Log directory not writable for --logdir ${2}"
		    exit ${UNKNOWN_ARGUMENT}
		fi
		shift
	    else
		\echo "Argument expected for ${1}"
		exit ${UNKNOWN_ARGUMENT}
	    fi ;;
	--caldb | --cald | --cal | --ca )
            # location to install CALDB
	    if [ "x${2}" != "x" ] ; then
		CALDB_DIR="${2}"

		if [ "${CALDB_DIR}" != "CIAO" ] ; then
		    if [ -e "${CALDB_DIR}" ] ; then
			touch "${CALDB_DIR}"/ciao-install-test 2>/dev/null
			if [ ! -f ${CALDB_DIR}/ciao-install-test ] ; then
			    printline "CALDB dir ${CALDB_DIR} is not writable. CALDB files will not be installled."
			    NOCALDB="yes"
			else
			    \rm -f "${CALDB_DIR}/ciao-install-test"
			fi
		    else
			\echo "CALDB area not found!"
			exit  ${CALDB_NOT_FOUND}
		    fi
		else
		    CALDB_DIR="CIAO"
		fi
		shift
	    else
		printerror "Argument expected for ${1}" ${CALDB_DIR_DOES_NOT_EXIST}
		exit ${CALDB_DIR_DOES_NOT_EXIST}
	    fi  ;;
	--use-ftp | --use-ft | --use-f )
	    FORCE_FTP="yes" ;;
	--force | --forc | --for | -f )   # force install
	    FORCE_INSTALL="yes"
	    if [ "x${DOWNLOAD_ONLY}" == "xyes" ] ; then
		\echo -f or --force not compatible with --download-only
		exit 1
	    fi ;;
	--add | --ad | --a | -a )
	    if [ "x${2}" != "x" ] ; then
		SEGMENTS="${SEGMENTS} `echo ${2} | sed 'y/,/ /'`"
		shift
	    else
		\echo "Argument expected for ${1}"
		exit ${UNKNOWN_ARGUMENT}
	    fi ;;
	--verbose | --verbos | --verbo | --verb )
	    WGETVERB="-v"
	    MFTPVERB=""
	    FTPVERB="-v" ;;
	--server | --serve | --serv | --ser | --se )
	    if [ "x${2}" != "x" ] ; then
		CONTROL_LOCATION="${2}"
		shift
	    else
		\echo "Argument expected for ${1}"
		exit ${UNKNOWN_ARGUMENT}
	    fi ;;
	--version | --versio | --versi | --vers | --ver | --ve | --v | -v )
	    \echo "${VERSION_STRING}"
	    exit 0 ;;
	--delete-tar | --delete-ta | --delete-t | --delete- | --delete | --delet | --dele | --del | --de )
	    export DEF_DELETE_TAR="yes"
	    export DELETE_TAR="yes" ;;
	-h | --help | --hel | --he | --h )
	    usage
	    exit 0 ;;
	* ) # Unknown switch ${1} passed print help
	    \echo "Unknown switch ${1}"
	    usage
	    exit 1 ;;
    esac
    shift
done

# First verify that we have the tools needed to install

case "`uname -s`" in
    Linux* )
	if [ "`uname -m`" != "x86_64" ] ; then
	    RSYS="Linux"
	else
	    RSYS="Linux64"
	fi ;;
    Sun* )
	sysver="`uname -r | sed 'y/./ /'`"
	let sunver="`retn 2 ${sysver}`"
	if (( ${sunver} < 10 )) ; then
	    unsupport_sys
	fi  
	RSYS="sun10" ;;
    Darwin* | darwin* )
	sysver="`uname -r | sed 'y/./ /'`"
	let macver="`retn 1 ${sysver}`"
	proc="`uname -p`"
	case ${proc} in
	    i386* )
		let minver=9
		# uname reports i386 even on x86_64.
		# sysctl.he.cpu64bit_capable tells
		# what the CPU is capable of running

		if [ "x`sysctl hw.cpu64bit_capable | grep 1`" != x ] ; then
		    RSYS="osx64"
		else
		    RSYS="osxi"
		fi;;
	    x86_64* )
		let minver=9
		RSYS="osx64" ;;
	    * )
		unsupport_sys
		exit 1 ;;
	esac

	if (( ${macver} < ${minver} )) ; then
	    unsupport_sys
	fi ;;
    * )
	RSYS="Unknown systen" ;;
esac

if [ "x${SYS}" == "x" ] ; then
    SYS="${RSYS}"
else
    if [ "${RSYS}" != "${SYS}" ] ; then

	# check to see if system is compatable

	case "${RSYS}" in
	    Linux64 )
		if [ "${SYS}" != "Linux" ] ; then
		    SYSERR="no"
		else
		    printline "Warning: Installing 32 bit version on a 64 bit machine."
		fi ;;
	    osxi )
		if [ "${SYS}" != "osx64" ] ; then
		    SYSERR="no"
		fi ;;
	    osx64 )
		if [ "${SYS}" != "osxi" ] ; then
		    SYSERR="no"
		else
		    printline "Warning: Installing 32 bit version on a 64 bit machine."
		fi ;;
	    * )
		SYSERR="no" ;;
	esac
	if [ "${SYSERR}" != "OK" ] ; then
	    if [ "${DOWNLOAD_ONLY}" != "yes" ] ; then
		printline "WARNING: Attempting to install <${SYS}> on <${RSYS}>"
		printline "The files can be unpacked but the configure cannot be run"
		printline "and the ahelp indexes and python modules cannot be created."
		printline "If you would like to just download the tarfiles, please"
		printline "use the --download-only switch on the command line."
		ansok="n"
		until [ "${ansok}" == "y" ] ; do
		    if [ "${BATCH}" != "yes" ] ; then
			ans=`get_input "Should I continue? (y|n)"`
			if [ "x${ans}" != "x" ] ; then
			    case ${ans} in
				y | Y | ye | yes | YE | YES | Yes | Ye ) ansok="y"
				    ans="y";;
				n | N | no | NO | No ) ansok="y"
				    ans="n" ;;
				* ) ans="" ;;
			    esac
			fi
		    else
			ansok="y"
			ans="y"
		    fi
		done
		if [ "${ans}" == "n" ] ; then
		    printline "You can download the ${RSYS} version of CIAO with the command:"
		    printline "  > bash ${0} --system ${RSYS}"
		    exit 1
		fi
	    else
		# Mismatched systems but downloading only,
		# just warn and continue

		printline "WARNING: Attempting to download <${SYS}> on <${RSYS}>"
	    fi    
	fi
    fi
fi

if [ -f "${EXITFILE}" ] ; then
    RET="`cat ${EXITFILE}`" ; \rm -f ${EXITFILE} ; exit ${RET}
fi
\touch ${LOGFILE}
\echo ${CL} >> ${LOGFILE}
printline "${VERSION_STRING}"
printline "Requested packages: ${SEGMENTS}"
uname -a >> ${LOGFILE}

printline "Script log file is ${LOGFILE}"

if [ "x${USER}" == "xroot" ] ; then
    printline "WARNING: Installing CIAO as root!"
    printline "Please consider installing as a non-privileged user."
fi

verify_tools

# If the user has any defaults already, let use them instead of
# our defaults

if [ -f "${EXITFILE}" ] ; then
    RET="`cat ${EXITFILE}`" ; \rm -f ${EXITFILE} ; exit ${RET}
fi
get_all_defaults

# Prompt the user for input. Create any directories needed

if [ -f "${EXITFILE}" ] ; then
    RET="`cat ${EXITFILE}`" ; \rm -f ${EXITFILE} ; exit ${RET}
fi
get_user_input

# install the required CIAO files

if [ -f "${EXITFILE}" ] ; then
    RET="`cat ${EXITFILE}`" ; \rm -f ${EXITFILE} ; exit ${RET}
fi

# print out what system they are installing.

case "${SYS}"
    in
    osxi ) printline "Preparing to install CIAO for Mac OS 32 bit";;
    osx64 ) printline "Preparing to install CIAO for Mac OS 64 bit";;
    sun10 ) printline "Preparing to install CIAO for Solaris";;
    Linux ) printline "Preparing to install CIAO for Linux 32 bit";;
    Linux64 ) printline "Preparing to install CIAO for Linux 64 bit";;
esac

read_control

# Do any post processing here. (rebuild ahelp index, build python modules, etc.)

if [ -f "${EXITFILE}" ] ; then
    RET="`cat ${EXITFILE}`" ; \rm -f ${EXITFILE} ; exit ${RET}
fi
if [ "${DOWNLOAD_ONLY}" != "yes" ] && [ "${SYSERR}" == "OK" ] ; then
    post_process
fi
if [ -f "${EXITFILE}" ] ; then
    RET="`cat ${EXITFILE}`" ; \rm -f ${EXITFILE} ; exit ${RET}
fi
exit 0


