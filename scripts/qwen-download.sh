#!/usr/bin/env bash

download_directory=$1
min=1
max=5
total=$(printf "%05d" $max)
for i in $(seq $min $max); do
    current=$(printf "%05d" $i)
    asset_name="qwen2.5-32b-instruct-q4_k_m-$current-of-$total.gguf"
    asset_url="https://huggingface.co/Qwen/Qwen2.5-32B-Instruct-GGUF/resolve/main/$asset_name"
    if [ ! -e "$download_directory/$asset_name" ]; then
        echo "Downloading $asset_url to $download_directory"
        wget -P $download_directory $asset_url &
    fi
done
# https://huggingface.co/Qwen/Qwen2.5-32B-Instruct-GGUF/resolve/main/qwen2.5-32b-instruct-q4_k_m-00001-of-00005.gguf?download=true
# https://huggingface.co/Qwen/Qwen2.5-32B-Instruct-GGUF/blob/main/qwen2.5-32b-instruct-q4_k_m-00001-of-00005.gguf