#!/bin/bash
set -e
echo "Invalidation of distribution cache"
aws cloudfront create-invalidation --paths '/*' --distribution-id $1 2>&1
echo "Done invalidation"
