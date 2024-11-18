#!/bin/bash -ex

for build_script in $(find . -name "build.sh"); do
    build_dir=$(dirname "$build_script")

    # Check if the SKIP file exists in the same directory as build.sh
    if [ ! -f "$build_dir/SKIP" ]; then
        echo "Running $build_script in $build_dir"
        # Navigate to the directory and run ./build.sh build
        (cd "$build_dir" && ./build.sh build)
    else
        echo "Skipping $build_dir due to SKIP file"
    fi
done
