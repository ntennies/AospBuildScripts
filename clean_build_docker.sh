#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Illegal number of parameters"
    echo "usage: clean_build_docker.sh <versionnumber> <githubtoken> [gitreponame:gitrepobranch]"
    echo "   gitreponame must be the name of the repo on github. Multiple repo:branch pairs can be included"
    exit 2
fi

echo $1 "<redacted token>" ${@:3} > ~/Android/build_logs/aosp_config_v$1.log

# This is the list of repo directories within ~/Android/LA.UM.5.5.r1-04300-8x96.0_Rel_V2.1
# that will be pulled; the number and order of these directories needs to mach the list
# of repo names in git_repo_names 
git_repo_dirs=(
	"device/qcom/msm8996/"
	"vendor/subcimaging/priv-app/"
	"vendor/subcimaging/libs/"
	"vendor/subcimaging/system/"
	"kernel/msm-3.18/"
)

# This is the list of repo names within github that will be pulled; the number and order
# of these repos nees to mach the list of repo directories in git_repo_dirs
git_repo_names=(
	"AospRayfinDevice"
	"AospVendorSubcApp"
	"AospVendorSubcLibs"
	"AospVendorSubcSystem"
	"AospKernel"
)

# This maintains the list of repo names that should be switched to a branch other than "main"
# This list is populated from the command line arguments after the first one and pairs with
# the branchswitch_repo_branches array
branchswitch_repo_names=()

# This maintains the list of repo branches the repos in branchswitch_repo_names should be
# switched to. This list is populated from the command line arguments after the first one
# and pairs with the branchswitch_repo_branches array
branchswitch_repo_branches=()

for arg in "${@:3}"; do
	branchswitch_repo_names+=($(echo "$arg" | cut -d ":" -f 1))
	branchswitch_repo_branches+=($(echo "$arg" | cut -d ":" -f 2))
done

for repo_index in ${!git_repo_dirs[@]}; do

	repo_name=${git_repo_names[$repo_index]}
	branch_name="main"
	for branchswitch_index in "${!branchswitch_repo_names[@]}"; do
	    	if [[ ${branchswitch_repo_names[$branchswitch_index]} = $repo_name ]]; then
	    		branch_name="${branchswitch_repo_branches[$branchswitch_index]}"
		fi 
	done

	rm -rf ~/Android/LA.UM.5.5.r1-04300-8x96.0_Rel_V2.1/${git_repo_dirs[$repo_index]}
	git clone https://$2@github.com/SubCImaging/${git_repo_names[$repo_index]}.git --branch $branch_name ~/Android/LA.UM.5.5.r1-04300-8x96.0_Rel_V2.1/${git_repo_dirs[$repo_index]}
done

export RAYFIN_ROM_VERSION=$1

rm -rf ~/Android/rayfin_dist/
mkdir -p ~/Android/build_logs/
mkdir -p ~/Android/releases/

cd ~/Android/LA.UM.5.5.r1-04300-8x96.0_Rel_V2.1/
source build/envsetup.sh
echo "envsetup.sh exit code: " ${PIPESTATUS[@]} >> ~/Android/build_logs/aosp_config_v$1.log

if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
	exit 1
fi

lunch msm8996-userdebug
echo "lunch msm8996-userdebug exit code: " ${PIPESTATUS[@]} >> ~/Android/build_logs/aosp_config_v$1.log

if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
	exit 1
fi

make clobber
echo "make clobber exit code: " ${PIPESTATUS[@]} >> ~/Android/build_logs/aosp_config_v$1.log

if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
	exit 1
fi

make -j8 2>&1 | tee ~/Android/build_logs/aosp_build_v$1.log
echo "Exit: " ${PIPESTATUS[@]} >> ~/Android/build_logs/aosp_build_v$1.log

if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
	exit 1
fi

mkdir ~/Android/rayfin_dist
make -j8 dist DIST_DIR=~/Android/rayfin_dist 2>&1 | tee ~/Android/build_logs/aosp_dist_build_v$1.log
echo "Exit: " ${PIPESTATUS[@]} >> ~/Android/build_logs/aosp_dist_build_v$1.log

if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
	exit 1
fi

./build/tools/releasetools/ota_from_target_files -n ~/Android/rayfin_dist/msm8996-target_files-eng.ubuntu.zip ~/Android/releases/rayfin_ota_update_v$1.zip 2>&1 | tee ~/Android/build_logs/aosp_ota_create_v$1.log
echo "Exit: " ${PIPESTATUS[@]} >> ~/Android/build_logs/aosp_ota_create_v$1.log

if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
	exit 1
fi

