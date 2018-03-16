#!/bin/bash

. /lib/init/vars.sh
. /lib/lsb/init-functions

# gets path of file being executed
DIR=$(dirname $(readlink -e $0))

#
# for i in `ls $DIR/*.patch | sort -V`;
# do
#     log_daemon_msg "Applying patch $i..."
#
#     if patch -p1 --ignore-whitespace -i  $i; then
#         # log_success_msg "Success"
#         log_end_msg 0
#     else
#         log_end_msg 1
#         exit 1;
#     fi
# done
#

echo -e "\n"
read -p "Apply current config? [Y/n] " -n 1 -r
echo -e "\n"

if [[ ! $REPLY =~ ^[Yy]$ ]];
then
    log_warning_msg "Skipped"
else
    log_daemon_msg "Applying current config..."
    if cp /boot/config-`uname -r` .config; then
        log_end_msg 0
    else
        log_end_msg 1
    fi
fi

echo -e "\n"
read -p "Set permissions? [Y/n] " -n 1 -r
echo -e "\n"

if [[ ! $REPLY =~ ^[Yy]$ ]];
then
    log_warning_msg "Skipped"
else
    log_daemon_msg "permitting execution for debian/*"
    if chmod a+x debian/*; then
        log_end_msg 0
    else
        log_end_msg 1
    fi

    log_daemon_msg "adding execution permissions for debian/scripts/*"
    if chmod a+x debian/scripts/*; then
        log_end_msg 0
    else
        log_end_msg 1
    fi

    log_daemon_msg "Adding execution permissions for debian/scripts/misc/*"
    if chmod a+x debian/scripts/misc/*; then
        log_end_msg 0
    else
        log_end_msg 1
    fi
fi

echo -e "\n"
read -p "Copy ipts firmware from /lib/firmware/intel/ipts/ipts_fw_config.bin to firmware/intel/ipts?" -n 1 -r
echo -e "\n"

if [[ ! $REPLY =~ ^[Yy]$ ]];
then
    log_warning_msg "Skipped"
else
    log_daemon_msg "Creating firmware folders"
    if mkdir -p firmware/intel/ipts; then
        log_end_msg 0
    else
        log_end_msg 1
    fi

    log_daemon_msg "Copying firmware"
    if cp -f /lib/firmware/intel/ipts/ipts_fw_config.bin firmware/intel/ipts; then
        log_end_msg 0
    else
        log_end_msg 1
    fi
    
fi


echo -e "\n"
read -p "Set config items? [Y/n]" -n 1 -r
echo -e "\n"

if [[ ! $REPLY =~ ^[Yy]$ ]];
then
    log_warning_msg "Skipped"
else
    log_daemon_msg "disable DEBUG_INFO"
    if fakeroot scripts/config --disable DEBUG_INFO; then
    # if fakeroot scripts/config -m DEBUG_INFO; then
        log_end_msg 0
    else
        log_end_msg 1
    fi
    
    log_daemon_msg "adding module INTEL_IPTS"
    if fakeroot scripts/config -m INTEL_IPTS; then
        log_end_msg 0
    else
        log_end_msg 1
    fi


    log_daemon_msg "Disabling MODULE_SIG"
    if fakeroot scripts/config --disable MODULE_SIG; then
        log_end_msg 0
    else
        log_end_msg 1
    fi

    log_daemon_msg "Disabling SYSTEM_TRUSTED_KEYRING"
    if fakeroot scripts/config --disable SYSTEM_TRUSTED_KEYRING; then
        log_end_msg 0
    else
        log_end_msg 1
    fi

    log_daemon_msg "Enabling BLK_DEV_NVME"
    if fakeroot scripts/config --enable BLK_DEV_NVME; then
        log_end_msg 0
    else
        log_end_msg 1
    fi

    log_daemon_msg "Setting firmware directory in .config"
    if fakeroot scripts/config --set-val EXTRA_FIRMWARE_DIR 'firmware'; then
        log_end_msg 0
    else
        log_end_msg 1
    fi

    log_daemon_msg "Adding ipts firmware to extra firmware to build"
    if fakeroot scripts/config --set-val EXTRA_FIRMWARE 'intel/ipts/ipts_fw_config.bin'; then
        log_end_msg 0
    else
        log_end_msg 1
    fi

    log_daemon_msg "Disabling 80211 powersaving "
    if fakeroot scripts/config --disable CFG80211_DEFAULT_PS; then
        log_end_msg 0
    else
        log_end_msg 1
    fi
fi

echo -e "\n\nComplete!\n\nTo compile kernel run:\n\n$ make oldconfig\n\n$ make -j 3 bindeb-pkg LOCALVERSION=-surface4-or-wahtever\n\n"
exit 0
