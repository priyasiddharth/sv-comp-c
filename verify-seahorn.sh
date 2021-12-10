#!/usr/bin/env bash

: ${1?"Usage: $0 <directory> <sea_dir>  Need to pass directory with C source files"}
: ${2:?"Usage: $0 <directory> <sea_dir> Need to pass SEA_DIR - i.e. the dir which contains the sea{,horn,opt} cmds e.g. seahorn/build/run/bin/"}

INPUT_DIR=${1}
shift
SEA_DIR=${1}
shift
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


REL_INPUT_DIR=$(realpath --relative-to ${SCRIPT_DIR} ${INPUT_DIR})
OBJ_DIR=${SCRIPT_DIR}/bin/${REL_INPUT_DIR}

# Get the expected object(bitcode) filenames
# 1. We only want to generate files,
#    which have an unreachability job defined in the config(yml) file
# 2. We want to add expected file extension
# 3. We want only the filenames so strip out the preceeding path
OBJ_FILENAMES=$(grep -rl --include=*.yml "unreach-call.prp" ${INPUT_DIR} | \
    sed 's/\.yml$/.sea.bc/' | \
    xargs -n1 basename)

# change to source directory and run make
cd ${INPUT_DIR}
for f in $OBJ_FILENAMES;do
    make CC=clang-10 EMIT_LLVM=1 $f;
done

# Now that object files are built, we want to run sea command
SEA_CMD=${SEA_DIR}/sea

for f in $OBJ_FILENAMES;do
    if [ ! -f ${OBJ_DIR}/${f} ]
    then
       echo ${f} "not built - skipping!"
    else
        echo -ne ${f} " ";  # print filename
        ${SEA_CMD} bpf \
            -O3 \
            --inline \
            --enable-loop-idiom \
            --enable-indvar \
            --no-lower-gv-init-struct \
            --externalize-addr-taken-functions \
            --no-kill-vaarg \
            --with-arith-overflow=true \
            --horn-unify-assumes=true \
            --horn-gsa \
            --dsa=sea-cs-t \
            --devirt-functions=types \
            --bmc=opsem \
            --horn-vcgen-use-ite \
            --horn-vcgen-only-dataflow=true \
            --horn-bmc-coi=true \
            --sea-opsem-allocator=static \
            --horn-explicit-sp0=false \
            --horn-bv2-lambdas \
            --horn-bv2-simplify=true \
            --horn-bv2-extra-widemem -S \
            --keep-temps --temp-dir=/tmp/sv-comp \
            --horn-stats=true \
            --horn-bv2-word-size=8 \
            --horn-bmc-tactic=default \
            ${OBJ_DIR}/${f} \
            2> /dev/null | \
            grep "sat";
    fi
done

# change back to where we came from
cd ${SCRIPT_DIR}
