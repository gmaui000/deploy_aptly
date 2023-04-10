#!/bin/bash

function find_target_version() {
    search_dir=$1
    pattern="voyance_[0-9].[0-9].[0-9]_amd64.deb"
    files=$(find "$search_dir" -name "$pattern")
    sorted=$(echo "$files" | sort -t_ -k2 -k3 -k4)
    target=$(echo "$sorted" | tail -n 1)

    echo "$target"
}

if [ -n "${TZ}" ]; then
    rm -f /etc/timezone /etc/localtime
    echo "${TZ}" > /etc/timezone
    ln -sfr /usr/share/zoneinfo/${TZ} /etc/localtime
fi

if [ ! -d /aptly/repo ]; then
    mkdir -p /aptly/repo
fi

if [ ! -d /aptly/aptly ]; then
    mkdir -p /aptly/aptly
fi

if [ ! -d /aptly/incoming ]; then
    mkdir -p /aptly/incoming
fi

sudo chown root:root ~/.gnupg -R

gpg-agent --daemon

bash /aptly/polling.sh &

target=$(find_target_version /aptly/repo)
echo "$target"

if [ -z $target ]; then
    echo "search dir is emtpy."
else
    echo "search dir has target:$target."
    version=$(echo "$target" | cut -d _ -f 2)
    echo "target version:$version."
    aptly repo create voyance
    aptly repo add voyance $target
    aptly snapshot create voyance-$version-snapshot from repo voyance
    aptly publish snapshot -batch=true  -distribution=$APT_DISTRIBUTION -passphrase="$GPG_PASSPHRASE" voyance-$version-snapshot voyance
    aptly serve
fi

echo "done. it will enter loop..."

while true; do sleep 10; done
