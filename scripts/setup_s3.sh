#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <bucket name>"
    exit 1
fi

BUCKET_NAME=$1
FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/adventure_works_data"


# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS CLI is not configured. Please run 'aws configure' first."
    exit 1
fi

# Check if the folder exists
if [ ! -d "$FOLDER_PATH" ]; then
    echo "Error: Folder '$FOLDER_PATH' does not exist."
    exit 1
fi

# Get AWS region from the configured AWS CLI
AWS_REGION=$(aws configure get region)

# Create S3 bucket if it doesn't exist
echo "Creating S3 bucket: $BUCKET_NAME..."
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" \
    --create-bucket-configuration LocationConstraint="$AWS_REGION" || echo "Bucket may already exist."

# Disable block public access (this is necessary for public buckets)
echo "Disabling block public access..."
aws s3api delete-public-access-block --bucket "$BUCKET_NAME"

# Set up a public bucket policy
echo "Applying public bucket policy..."
PUBLIC_POLICY=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        },
        {
            "Sid": "PublicListBucket",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::$BUCKET_NAME"
        }
    ]
}
EOF
)

echo "$PUBLIC_POLICY" > bucket-policy.json
aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy file://bucket-policy.json
rm bucket-policy.json

# Upload all files from the folder to S3 with public-read permission
echo "Uploading all files from $FOLDER_PATH to S3..."
aws s3 cp "$FOLDER_PATH" "s3://$BUCKET_NAME/" --recursive

echo "All files uploaded successfully!"
echo "Publicly accessible at: https://$BUCKET_NAME.s3.$AWS_REGION.amazonaws.com/"
