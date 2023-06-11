#!/bin/bash

cd $(dirname $0)

PORT=$1

mkdir -p ports versions

if [ -z "$PORT" ]; then
    exit 1
fi

PORT_VERSION=$(jq -r '."port-version"' < ports/$PORT/vcpkg.json)
VERSION=$(jq -r .version < ports/$PORT/vcpkg.json)
SEMVER=$(jq -r '."version-semver"' < ports/$PORT/vcpkg.json)
TREE=$(git rev-parse HEAD:ports/$PORT)

PREFIX=$(echo $PORT | cut -c1-1)

echo $VERSION $SEMVER

mkdir -p versions/${PREFIX}-

VERSIONING="{
    \"versions\": [
        {
            \"port-version\": $PORT_VERSION,
            \"git-tree\": \"$TREE\"
        }
    ]
}"
if [ "$VERSION" != "null" ]; then
    VERSIONING=$(echo "$VERSIONING" | jq ".versions[0] += {\"version\": \"$VERSION\"}")
else
    VERSIONING=$(echo "$VERSIONING" | jq ".versions[0] += {\"version-semver\": \"$SEMVER\"}")
fi

echo $VERSIONING > versions/${PREFIX}-/$PORT.json

cat versions/$PREFIX-/$PORT.json

echo "Updated port $PORT to $VERSION ($TREE)"

if [ ! -f versions/baseline.json ]; then
    echo '{"default": {}}' > versions/baseline.json
fi

if [ "$VERSION" != "null" ]; then
    BASELINE=$(jq ".default += {\"$PORT\":{\"baseline\": \"$VERSION\", \"port-version\": $PORT_VERSION}}" < versions/baseline.json)
else
    BASELINE=$(jq ".default += {\"$PORT\":{\"baseline\": \"$SEMVER\", \"port-version\": $PORT_VERSION}}" < versions/baseline.json)
fi
echo $BASELINE > versions/baseline.json
