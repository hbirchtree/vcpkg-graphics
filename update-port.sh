#!/bin/bash

cd $(dirname $0)

PORT=$1

if [ -z "$PORT" ]; then
    exit 1
fi

PORT_VERSION=$(jq -r '."port-version"' < ports/$PORT/vcpkg.json)
VERSION=$(jq -r .version < ports/$PORT/vcpkg.json)
TREE=$(git rev-parse HEAD:ports/$PORT)

PREFIX=$(echo $PORT | cut -c1-1)

mkdir -p versions/${PREFIX}-

echo "{
    \"versions\": [
        {
            \"version\": \"$VERSION\",
            \"port-version\": $PORT_VERSION,
            \"git-tree\": \"$TREE\"
        }
    ]
}" | jq > versions/${PREFIX}-/$PORT.json

cat versions/$PREFIX-/$PORT.json

echo "Updated port $PORT to $VERSION ($TREE)"

BASELINE=$(jq ".default += {\"pvrtcdec\":{\"baseline\": \"$VERSION\", \"port-version\": $PORT_VERSION}}" < versions/baseline.json)
echo $BASELINE > versions/baseline.json
