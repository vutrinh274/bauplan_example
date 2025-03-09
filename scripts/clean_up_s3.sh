#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <bucket name>"
    exit 1
fi

BUCKET_NAME=$1

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS CLI is not configured. Please run 'aws configure' first."
    exit 1
fi

# Check if the bucket exists
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "Error: Bucket '$BUCKET_NAME' does not exist or you do not have access."
    exit 1
fi

echo "Emptying the bucket: $BUCKET_NAME..."

# Delete all objects (non-versioned bucket)
aws s3 rm "s3://$BUCKET_NAME/" --recursive

echo "Deleting the bucket: $BUCKET_NAME..."
aws s3api delete-bucket --bucket "$BUCKET_NAME"

echo "Bucket '$BUCKET_NAME' has been deleted successfully!"