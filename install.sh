#!/bin/bash

RUNNING_DIR=${PWD}
USER_HOME=${HOME}

if [ "$(id -u)" = "0" ]; then
    if [ ${SUDO_USER} != "root" ]; then
        USER_HOME="/home/${SUDO_USER}"
    fi
fi

say() {
    printf '\033[0;34m[installer]\33[0m %s\n' "$1"
}

err() {
    say "$1" >&2
    exit 1
}

assert_nz() {
    if [ -z "$1" ]; then err "assert_nz $2"; fi
}

newline() {
    local num=${1:-1}
    for ((i=1; i<=num; i++)); do
        echo
    done
}

check_cmd() {
    command -v "$1" > /dev/null 2>&1
}

need_cmd() {
    if ! check_cmd "$1"; then
        err "need '$1' (command not found)"
    fi
}

# This is just for indicating that commands' results are being
# intentionally ignored. Usually, because it's being executed
# as part of error handling.
ignore() {
    "$@"
}

# Run a command that should never fail. If the command fails execution
# will immediately terminate with an error showing the failing
# command.
ensure_run() {
    if ! "$@"; then err "command failed: $*"; fi
}

ensure_dir() {
    need_cmd mkdir
    
    if [ ! -d "$1" ]; then
        say "mkdir '$1' "
        mkdir -p "$1" -m 755
    fi
}

check_proc() {
    # Check for /proc by looking for the /proc/self/exe link
    # This is only run on Linux
    if ! test -L /proc/self/exe ; then
        err "fatal: Unable to find /proc/self/exe.  Is /proc mounted?  Installation cannot proceed without /proc."
    fi
}

get_bitness() {
    need_cmd head
    # Architecture detection without dependencies beyond coreutils.
    # ELF files start out "\x7fELF", and the following byte is
    #   0x01 for 32-bit and
    #   0x02 for 64-bit.
    # The printf builtin on some shells like dash only supports octal
    # escape sequences, so we use those.
    local _current_exe_head
    _current_exe_head=$(head -c 5 /proc/self/exe )
    if [ "$_current_exe_head" = "$(printf '\177ELF\001')" ]; then
        echo 32
        elif [ "$_current_exe_head" = "$(printf '\177ELF\002')" ]; then
        echo 64
    else
        err "unknown platform bitness"
    fi
}

is_host_amd64_elf() {
    need_cmd head
    need_cmd tail
    # ELF e_machine detection without dependencies beyond coreutils.
    # Two-byte field at offset 0x12 indicates the CPU,
    # but we're interested in it being 0x3E to indicate amd64, or not that.
    local _current_exe_machine
    _current_exe_machine=$(head -c 19 /proc/self/exe | tail -c 1)
    [ "$_current_exe_machine" = "$(printf '\076')" ]
}

get_endianness() {
    local cputype=$1
    local suffix_eb=$2
    local suffix_el=$3
    
    # detect endianness without od/hexdump, like get_bitness() does.
    need_cmd head
    need_cmd tail
    
    local _current_exe_endianness
    _current_exe_endianness="$(head -c 6 /proc/self/exe | tail -c 1)"
    if [ "$_current_exe_endianness" = "$(printf '\001')" ]; then
        echo "${cputype}${suffix_el}"
        elif [ "$_current_exe_endianness" = "$(printf '\002')" ]; then
        echo "${cputype}${suffix_eb}"
    else
        err "unknown platform endianness"
    fi
}

get_architecture() {
    need_cmd uname
    
    local _ostype _cputype _bitness _arch _clibtype
    _ostype="$(uname -s)"
    _cputype="$(uname -m)"
    _clibtype="gnu"
    
    if [ "$_ostype" = Linux ]; then
        if [ "$(uname -o)" = Android ]; then
            _ostype=Android
        fi
        if ldd --version 2>&1 | grep -q 'musl'; then
            _clibtype="musl"
        fi
    fi
    
    if [ "$_ostype" = Darwin ] && [ "$_cputype" = i386 ]; then
        # Darwin `uname -m` lies
        if sysctl hw.optional.x86_64 | grep -q ': 1'; then
            _cputype=x86_64
        fi
    fi
    
    if [ "$_ostype" = SunOS ]; then
        # Both Solaris and illumos presently announce as "SunOS" in "uname -s"
        # so use "uname -o" to disambiguate.  We use the full path to the
        # system uname in case the user has coreutils uname first in PATH,
        # which has historically sometimes printed the wrong value here.
        if [ "$(/usr/bin/uname -o)" = illumos ]; then
            _ostype=illumos
        fi
        
        # illumos systems have multi-arch userlands, and "uname -m" reports the
        # machine hardware name; e.g., "i86pc" on both 32- and 64-bit x86
        # systems.  Check for the native (widest) instruction set on the
        # running kernel:
        if [ "$_cputype" = i86pc ]; then
            _cputype="$(isainfo -n)"
        fi
    fi
    
    case "$_ostype" in
        
        Android)
            _ostype=linux-android
        ;;
        
        Linux)
            check_proc
            _ostype=unknown-linux-$_clibtype
            _bitness=$(get_bitness)
        ;;
        
        FreeBSD)
            _ostype=unknown-freebsd
        ;;
        
        NetBSD)
            _ostype=unknown-netbsd
        ;;
        
        DragonFly)
            _ostype=unknown-dragonfly
        ;;
        
        Darwin)
            _ostype=apple-darwin
        ;;
        
        illumos)
            _ostype=unknown-illumos
        ;;
        
        MINGW* | MSYS* | CYGWIN* | Windows_NT)
            _ostype=pc-windows-gnu
        ;;
        
        *)
            err "unrecognized OS type: $_ostype"
        ;;
        
    esac
    
    case "$_cputype" in
        
        i386 | i486 | i686 | i786 | x86)
            _cputype=i686
        ;;
        
        xscale | arm)
            _cputype=arm
            if [ "$_ostype" = "linux-android" ]; then
                _ostype=linux-androideabi
            fi
        ;;
        
        armv6l)
            _cputype=arm
            if [ "$_ostype" = "linux-android" ]; then
                _ostype=linux-androideabi
            else
                _ostype="${_ostype}eabihf"
            fi
        ;;
        
        armv7l | armv8l)
            _cputype=armv7
            if [ "$_ostype" = "linux-android" ]; then
                _ostype=linux-androideabi
            else
                _ostype="${_ostype}eabihf"
            fi
        ;;
        
        aarch64 | arm64)
            _cputype=aarch64
        ;;
        
        x86_64 | x86-64 | x64 | amd64)
            _cputype=x86_64
        ;;
        
        mips)
            _cputype=$(get_endianness mips '' el)
        ;;
        
        mips64)
            if [ "$_bitness" -eq 64 ]; then
                # only n64 ABI is supported for now
                _ostype="${_ostype}abi64"
                _cputype=$(get_endianness mips64 '' el)
            fi
        ;;
        
        ppc)
            _cputype=powerpc
        ;;
        
        ppc64)
            _cputype=powerpc64
        ;;
        
        ppc64le)
            _cputype=powerpc64le
        ;;
        
        s390x)
            _cputype=s390x
        ;;
        riscv64)
            _cputype=riscv64gc
        ;;
        *)
            err "unknown CPU type: $_cputype"
            
    esac
    
    # Detect 64-bit linux with 32-bit userland
    if [ "${_ostype}" = unknown-linux-gnu ] && [ "${_bitness}" -eq 32 ]; then
        case $_cputype in
            x86_64)
                if [ -n "${MY_CPUTYPE:-}" ]; then
                    _cputype="$MY_CPUTYPE"
                else {
                        # 32-bit executable for amd64 = x32
                        if is_host_amd64_elf; then {
                                echo "This host is running an x32 userland; as it stands, x32 support is poor," 1>&2
                                echo "and there isn't a native toolchain -- you will have to install" 1>&2
                                echo "multiarch compatibility with i686 and/or amd64, then select one" 1>&2
                                echo "by re-running this script with the MY_CPUTYPE environment variable" 1>&2
                                echo "set to i686 or x86_64, respectively." 1>&2
                                echo 1>&2
                                exit 1
                            }; else
                            _cputype=i686
                        fi
                }; fi
            ;;
            mips64)
                _cputype=$(get_endianness mips '' el)
            ;;
            powerpc64)
                _cputype=powerpc
            ;;
            aarch64)
                _cputype=armv7
                if [ "$_ostype" = "linux-android" ]; then
                    _ostype=linux-androideabi
                else
                    _ostype="${_ostype}eabihf"
                fi
            ;;
            riscv64gc)
                err "riscv64 with 32-bit userland unsupported"
            ;;
        esac
    fi
    
    # Detect armv7 but without the CPU features Rust needs in that build,
    # and fall back to arm.
    # See https://github.com/rust-lang/rustup.rs/issues/587.
    if [ "$_ostype" = "unknown-linux-gnueabihf" ] && [ "$_cputype" = armv7 ]; then
        if ensure_run grep '^Features' /proc/cpuinfo | grep -q -v neon; then
            # At least one processor does not have NEON.
            _cputype=arm
        fi
    fi
    
    _arch="${_cputype}-${_ostype}"
    
    RETVAL="$_arch"
}

check_git_repository() {
    need_cmd git
    
    git remote -v > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        say "not a git repository"
        return 1
    fi
    
    return 0
}

check_pybuildkit_remote() {
    check_git_repository || return 1
    
    local result=$(git remote -v 2>/dev/null)
    
    if [[ ${result} != *"PyBuildKit"* ]]; then
        say "not the correct git repository"
        return 1
    fi
    
    return 0
}

apt_install() {
    if ! check_cmd apt; then
        for pack in $@; do
            echo "[warning] You should ensure '$pack' is already installed."
        done
        return 1
    fi
    
    if [ "$(id -u)" = "0" ]; then
        ensure_run apt update
        ensure_run apt install -y $@
    else
        echo "Please run as root"
        exit 1
    fi
    
    return 0
}

package_install() {
    for pack in $@; do
        if ! check_cmd ${pack}; then
            apt_install ${pack}
        fi
    done
}

check_system_environment() {
    say "check the basic environment of system"
    
    package_install git python3 cmake pkg-config curl wget zip unzip tar

    if ! check_cmd gcc || ! check_cmd g++; then
        apt_install build-essential
    fi
}

install() {
    PYBUILDKIT_PATH="${INSTALL_PATH}/PyBuildKit"

    check_pybuildkit_remote
    if [[ $? -ne 0 ]]; then
        if [[ -d ${PYBUILDKIT_PATH} ]]; then
            say "'${PYBUILDKIT_PATH}' already exists, upgrade"
            cd ${PYBUILDKIT_PATH}
            git pull --rebase
            git submodule update --init --recursive
            cd ${RUNNING_DIR}
        else
            say "clone 'skb666/PyBuildKit' from github"
            ensure_dir ${PYBUILDKIT_PATH}
            git clone https://github.com/skb666/PyBuildKit.git --recursive ${PYBUILDKIT_PATH}
            if [[ $? -ne 0 ]]; then
                say "Failed to install 'PyBuildKit'"
                rm -rf ${PYBUILDKIT_PATH}
                exit 1
            fi
        fi
    else
        say "upgrade the git repository"
        git pull --rebase
        git submodule update --init --recursive
        if [[ ${ASSIGN_PATH} = true ]]; then
            say "copy '${PWD}' to '${PYBUILDKIT_PATH}'"
            ensure_dir ${PYBUILDKIT_PATH}
            ensure_run cp -r ${PWD} ${PYBUILDKIT_PATH}
        else
            PYBUILDKIT_PATH=${PWD}
        fi
    fi
    
    say "install 'PyBuildKit' successfully!"
}

install_vcpkg() {
    if check_cmd vcpkg; then
        say "vcpkg has been installed, upgrade"
        local result=$(command -v vcpkg)
        VCPKG_PATH=${result%/*}
        cd ${VCPKG_PATH}
        git pull --rebase
        cd ${RUNNING_DIR}
    else
        say "clone 'microsoft/vcpkg' from github"
        VCPKG_PATH="${INSTALL_PATH}/vcpkg"
        if [[ -e ${VCPKG_PATH} ]]; then
            say "'${VCPKG_PATH}' already exists, upgrade"
            cd ${VCPKG_PATH}
            git pull --rebase
            cd ${RUNNING_DIR}
        else
            ensure_dir ${VCPKG_PATH}
            git clone https://github.com/microsoft/vcpkg.git --recursive ${VCPKG_PATH}
            if [[ $? -ne 0 ]]; then
                say "Failed to install 'vcpkg'"
                rm -rf ${VCPKG_PATH}
                exit 1
            fi
            ensure_run ${VCPKG_PATH}/bootstrap-vcpkg.sh
        fi
    fi
    
    say "install 'vcpkg' successfully!"
}

save_env() {
    ensure_dir ${INSTALL_PATH}
    ENV_FILE="${INSTALL_PATH}/env"
    
    echo -n > ${ENV_FILE}
    if [[ -n ${PYBUILDKIT_PATH} ]]; then
        echo "export MY_SDK_PATH=\"${PYBUILDKIT_PATH}\"" >> ${ENV_FILE}
    fi
    if [[ -n ${VCPKG_PATH} ]]; then
        echo "export VCPKG_ROOT=\"${VCPKG_PATH}\"" >> ${ENV_FILE}
        echo 'export PATH="$PATH:$VCPKG_ROOT"' >> ${ENV_FILE}
    fi
    echo >> ${ENV_FILE}
    
    say "generate and export 'env' file successfully!"
}

usage() {
    cat 1>&2 <<EOF
USAGE:
    install.sh [FLAGS] [OPTIONS]

FLAGS:
    -h, --help              Prints help information
    -w, --with-vcpkg        Install the vcpkg extension

OPTIONS:
    -d [install_path]       Specify the path to install to
EOF
}

main() {
    get_architecture || return 1
    local _arch="$RETVAL"
    assert_nz ${_arch} "arch"
    
    echo "architecture: ${_arch}"

    check_system_environment
    
    INSTALL_PATH=""
    ASSIGN_PATH=false
    
    local using_vcpkg=false
    local missing_arg=""
    
    for arg in $@; do
        if [[ -n ${missing_arg} ]]; then
            case ${missing_arg} in
                d)
                    missing_arg=""
                    INSTALL_PATH=${arg}
                    continue
                ;;
            esac
        fi
        
        case ${arg} in
            --help)
                usage
                exit 0
            ;;
            --with-vcpkg)
                using_vcpkg=true
            ;;
            *)
                OPTIND=1
                if [ "${arg%%--*}" = "" ]; then
                    # Long option (other than --help);
                    # don't attempt to interpret it.
                    continue
                fi
                while getopts ":hwd" sub_arg ${arg}; do
                    case ${sub_arg} in
                        h)
                            usage
                            exit 0
                        ;;
                        w)
                            using_vcpkg=true
                        ;;
                        d)
                            missing_arg=${sub_arg}
                            ASSIGN_PATH=true
                        ;;
                        *)
                            usage
                            exit 1
                        ;;
                    esac
                done
            ;;
        esac
    done
    
    if [[ -z ${INSTALL_PATH} ]]; then
        INSTALL_PATH="${USER_HOME}/.mysdk"
    fi
    
    say "install to '${INSTALL_PATH}'" && newline
    
    install && newline
    
    if [[ ${using_vcpkg} = true ]]; then
        install_vcpkg && newline
    fi
    
    save_env && newline
    
    echo "All done! You can now run:"
    echo "  . ${ENV_FILE}"
}

main "$@" || exit 1
