#!/bin/bash

# set -x
set -e

current_dir=$(pwd)

git_url=$1
git_tag=$2
target_dir=$3
parent_dir=$(dirname ${target_dir})

echo "fetch [${git_url}][${git_tag}] to ${target_dir}"

mkdir -p ${parent_dir}

if [ ! -d ${target_dir} ]; then
  cd ${parent_dir} && git clone --branch ${git_tag} --depth 1 --recursive ${git_url} ${target_dir} && cd ${target_dir}
else
  cd ${target_dir} && git fetch origin ${git_tag} && git reset --hard FETCH_HEAD
fi

git lfs install && git lfs pull
git submodule update --init --recursive
