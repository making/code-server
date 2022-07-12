#!/bin/bash
set -e
if [ ! -f $HOME/.pivnetrc ];then
    if [ "${TANZUNET_TOKEN}" == "" ]; then
        echo -n "TanzuNet UAA API TOKEN (https://network.tanzu.vmware.com/users/dashboard/edit-profile): "
        read -s TANZUNET_TOKEN
    fi
    pivnet login --api-token=${TANZUNET_TOKEN}
fi

if [ "${TAP_VERSION}" == "" ]; then
    DEFAULT_TAP_VERSION=1.1.2
    echo -n "TAP Vesion (default: ${DEFAULT_TAP_VERSION}): "
    read TAP_VERSION
    if [ "${TAP_VERSION}" == "" ]; then
        TAP_VERSION=${DEFAULT_TAP_VERSION}
    fi
fi

set -x
pivnet download-product-files --product-slug='tanzu-application-platform' --release-version=${TAP_VERSION} --glob='*.vsix'
set +x

for vsix in $(ls *.vsix);do
    /usr/lib/code-server/bin/code-server --install-extension ${vsix}
done
rm -f *.vsix