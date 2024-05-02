#!/usr/bin/env bash

kust_dir=$1
src_root=$(git rev-parse --show-toplevel)
repo_name=$(basename "$src_root")
copy_root="/tmp/kbd/$repo_name"
ref_dir="$copy_root/$kust_dir"
ref_file="$ref_dir/ref.yaml"
mod_file="$ref_dir/mod.yaml"
mod_dir="$src_root/$kust_dir"

echo "src_root: $src_root"
echo "repo_name: $repo_name"
echo "copy_root: $copy_root"
echo "ref_dir: $ref_dir"
echo "mod_dir: $mod_dir" 
echo "ref_file: $ref_file"
echo "mod_file: $mod_file"

rm $copy_root -rf
mkdir -p $ref_dir

git -C "$src_root" archive HEAD | tar -x -C "$copy_root"

echo "Building ref: $ref_dir -> $ref_file"
kustomize build "$ref_dir" > $ref_file
echo "Building mod: $mod_dir -> $mod_file"
kustomize build "$mod_dir" > $mod_file
echo "Delta"

delta $ref_file $mod_file
