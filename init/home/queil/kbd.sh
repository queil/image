#!/usr/bin/env bash

kust_dir=$1
src_root=$(git rev-parse --show-toplevel)
repo_name=$(basename "$src_root")
copy_root="/tmp/kbd/$repo_name"
ref_dir="$copy_root/$kust_dir"
ref_out="$ref_dir/.ref"
mod_dir="$src_root/$kust_dir"
mod_out="$ref_dir/.mod"

echo "src_root: $src_root"
echo "repo_name: $repo_name"
echo "copy_root: $copy_root"
echo "ref_dir: $ref_dir"
echo "mod_dir: $mod_dir" 
echo "ref_file: $ref_file"
echo "mod_file: $mod_file"

rm $copy_root -rf
mkdir -p $ref_out
mkdir -p $mod_out

base=main
echo "Comparing against: $base"

git -C "$src_root" archive "$base" | tar -x -C "$copy_root"

echo "Building ref: $ref_dir -> $ref_out"

kustomize build "$ref_dir" -o $ref_out

if [ $? -ne 0 ]; then
    read -p "Kustomize failed. Press enter"
    exit 1
fi

echo "Building mod: $mod_dir -> $mod_out"
kustomize build "$mod_dir" -o $mod_out

if [ $? -ne 0 ]; then
    read -p "Kustomize failed. Press enter"
    exit 1
fi

echo "delta"
cd $ref_dir

delta --relative-paths .ref .mod --paging=always
