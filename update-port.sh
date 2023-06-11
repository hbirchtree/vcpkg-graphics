#!/bin/bash

cd $(dirname $0)

PORT=$1

if [ -z "$PORT" ]; then
    exit 1
fi

PORT_VERSION=$(jq -r '."port-version"' < ports/$PORT/vcpkg.json)
VERSION=$(jq -r .version < ports/$PORT/vcpkg.json)
SEMVER=$(jq -r '."version-semver"' < ports/$PORT/vcpkg.json)
TREE=$(git rev-parse HEAD:ports/$PORT)

PREFIX=$(echo $PORT | cut -c1-1)

mkdir -p versions/${PREFIX}-

VERSIONING="{
    \"versions\": [
        {
            \"port-version\": $PORT_VERSION,
            \"git-tree\": \"$TREE\"
        }
    ]
}"
if [ -n "$SEMVER" ]; then
    VERSIONING=$(echo "$VERSIONING" | jq ".versions[0] += {\"version-semver\": \"$SEMVER\"}")
else
    VERSIONING=$(echo "$VERSIONING" | jq ".versions[0] += {\"version\": \"$VERSION\"}")
fi

echo $VERSIONING > versions/${PREFIX}-/$PORT.json

cat versions/$PREFIX-/$PORT.json

echo "Updated port $PORT to $VERSION ($TREE)"

BASELINE=$(jq ".default += {\"pvrtcdec\":{\"baseline\": \"$VERSION\", \"port-version\": $PORT_VERSION}}" < versions/baseline.json)
echo $BASELINE > versions/baseline.json
