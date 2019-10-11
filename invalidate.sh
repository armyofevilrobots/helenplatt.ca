#!/bin/bash
aws cloudfront create-invalidation \
    --paths '*' \
    --distribution-id $AWS_CLOUDFRONT_DISTRIBUTION_ID
