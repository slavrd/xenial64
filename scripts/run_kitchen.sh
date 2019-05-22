#!/usr/bin/env bash
# sets up and runs the kitchen test
# Requires: bundler, jq, vagrant

# install required gems 
bundle install || {
    echo "error installing gems" >&2
    exit 1
}

# add box to vagrant
VC_BOX_VER_PRE="$VC_BOX_VER.pre"
vagrant box add --force --box-version $VC_BOX_VER_PRE $VC_BOX_NAME || {
    echo "unable to add box: $VC_BOX_NAME ($VC_BOX_VER_PRE) to vagrant" >&2
    exit 1
}

# run kitchen
bundle exec kitchen test
K_RESULT=$?

# clean up vagrant box
vagrant box remove --force --box-version $VC_BOX_VER_PRE $VC_BOX_NAME

if [ "$K_RESULT" == 0 ]; then

    # remove .pre form version name
    echo "Kitchen test passed. Renaming Vagrant Cloud version..."
    curl -s \
        --header "Content-Type: application/json" \
        --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
        https://app.vagrantup.com/api/v1/box/$VC_BOX_NAME/version/$VC_BOX_VER_PRE \
        --request PUT \
        --data "{\"version\": {\"version\": \"$VC_BOX_VER\"}}" | [ "$(jq -r '.success')" != false ]

    [ "$?" != 0 ] && echo "fialed renaming version $VC_BOX_VER_PRE to $VC_BOX_VER"

else

    # delete provider if Kitchen test failed
    echo "Kitchen test failed. Removing VC box version provider..."
    curl -s \
        --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
        --request DELETE \
        https://app.vagrantup.com/api/v1/box/$VC_BOX_NAME/version/$VC_BOX_VER_PRE/provider/virtualbox

fi

# exit according to kitchen test result
exit $K_RESULT
