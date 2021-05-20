#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 2
fi

export RAYFIN_ROM_VERSION=$1

rm -rf ~/Android/rayfin_dist/

cd ~/Android/LA.UM.5.5.r1-04300-8x96.0_Rel_V2.1/
source build/envsetup.sh
lunch msm8996-userdebug
make clobber
make -j8 2>&1 | tee ~/Android/build_logs/aosp_build_v$1.log

mkdir ~/Android/rayfin_dist
make -j8 dist DIST_DIR=~/Android/rayfin_dist 2>&1 | tee ~/Android/build_logs/aosp_dist_build_v$1.log

./build/tools/releasetools/ota_from_target_files -n ~/Android/rayfin_dist/msm8996-target_files-eng.ubuntu.zip ~/Android/releases/rayfin_ota_update_v$1.zip 2>&1 | tee ~/Android/build_logs/aosp_ota_create_v$1.log

