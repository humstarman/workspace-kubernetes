#!/bin/bash

GOOGLE_IMAGE=$1

if [ -z "$GOOGLE_IMAGE" ]; then
  echo "$(date) - [ERROR] - no image info provided."
  sleep 2
  exit 1
fi

git init
PWD=$(pwd)
REPO=${PWD##*/}
GITHUB_URL="git@github.com:humstarman/${REPO}.git"
git remote add origin $GITHUB_URL

cat > $(pwd)/README.md << EOF
<div>
for kubeflow v0.1.2
</div>
EOF
cat > $(pwd)/Dockerfile << EOF
FROM ${GOOGLE_IMAGE}
EOF

git add .
git commit -m "init"
git push origin master

TAG="$(cat Dockerfile | awk -F ':' '{print $2}')"
echo $TAG
git branch $TAG
git checkout $TAG
git push origin $TAG
