#/usr/env/bin bash
# Sets the environment variables referenced in the packer template
# for given Ubuntu version

# usage run.sh <ubuntu_version> <vc_box_name> <vc_box_version>

# input viars

UBUNTU_VER=$1

if [ "$1" == "" ]; then
    echo "ERROR: Need to pass an Ubuntu version XX.XX.X" >&2
    exit 1
fi

# end input vars

export ISO_URL="http://releases.ubuntu.com/$UBUNTU_VER/ubuntu-$UBUNTU_VER-server-amd64.iso"

export VC_BOX_NAME=$2

if [ "$3" == "" ]; then
    export VC_BOX_VER=$1
else
    export VC_BOX_VER=$3
fi

# get ISO_SHA
export ISO_SHA=$(
    curl -s "http://releases.ubuntu.com/$UBUNTU_VER/SHA256SUMS" | 
        while read -r SHA ARCH; do
            if [ "$ARCH" == '*ubuntu-16.04.6-server-amd64.iso' ]; then
                echo $SHA
                break
            fi
        done
)

if [ "$ISO_SHA" == "" ]; then
    echo "ERROR: SHA256 SUM not found for version $UBUNTU_VER . Make sure the version is correct" >&2
    exit 1
fi

# execute packer
packer validate template.json && { 
    packer build template.json || exit 1
} || exit 1