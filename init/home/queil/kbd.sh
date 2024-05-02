#!/usr/bin/env bash

if [ ! -d /tmp/kb ]; then 
  mkdir -p /tmp/kb
fi

if [ ! -f /tmp/kb/pre.yaml ]; then
    git stash -u && \
    kustomize build > /tmp/kb/pre.yaml && \
    git stash pop
fi

if [ -f /tmp/kb/post.yaml ]; then
  rm /tmp/kb/post.yaml
fi

kustomize build > /tmp/kb/post.yaml && git diff --no-index /tmp/kb/pre.yaml /tmp/kb/post.yaml
