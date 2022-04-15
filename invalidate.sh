#!/bin/bash
echo "INVALIDATE DISTRO $1"
set -e
echo "Invalidation of distribution cache"
AWS_PAGER="cat" aws --profile aoer --no-paginate cloudfront create-invalidation --paths '/*' --distribution-id $1 2>&1
echo "Done invalidation"
