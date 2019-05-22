#!/usr/bin/env bash
# sets up and runs the kitchen test
# Requires: bundler, jq, vagrant

# install required gems 
bundle install || {
    echo "error installing gems" >&2
    exit 1
}

# add box to vagrant
vagrant box add --force --box-version $VC_BOX_VER $VC_BOX_NAME || {
    echo "unable to add box: $VC_BOX_NAME ($VC_BOX_VER) to vagrant" >&2
    exit 1
}

# run kitchen
bundle exec kitchen test
K_RESULT=$?

# in case kitchen test fails
if [ "$K_RESULT" != 0 ]; then

    # remove box from vagrant
    vagrant box remove --force --box-version $VC_BOX_VER $VC_BOX_NAME

    # delete provider if Kitchen test failed
    echo "Kitchen test failed. Removing VC box version provider..."
    curl -s \
        --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
        --request DELETE \
        https://app.vagrantup.com/api/v1/box/$VC_BOX_NAME/version/$VC_BOX_VER/provider/virtualbox

fi

# exit according to kitchen test result
exit $K_RESULT
