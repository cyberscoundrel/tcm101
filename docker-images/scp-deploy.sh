#!/bin/bash

# SCP Docker Images Deployment Script
echo "🚀 Starting SCP deployment of Docker images to EC2..."

# Check if IP address is provided
if [ -z "$1" ]; then
    echo "❌ Error: IP address is required!"
    echo "Usage: ./scp-deploy.sh <IP_ADDRESS> [USERNAME] [REMOTE_FOLDER]"
    echo "Example: ./scp-deploy.sh 54.123.45.67 ec2-user docker-images"
    exit 1
fi

# Parameters
IP_ADDRESS="$1"
USERNAME="${2:-ubuntu}"
REMOTE_FOLDER="${3:-~/tcm101/docker-images}"

# Validate IP format
if [[ ! $IP_ADDRESS =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "❌ Error: Invalid IP address format: $IP_ADDRESS"
    echo "Usage: ./scp-deploy.sh <IP_ADDRESS> [USERNAME] [REMOTE_FOLDER]"
    echo "Example: ./scp-deploy.sh 54.123.45.67 ec2-user"
    exit 1
fi

echo "📍 Target EC2 IP: $IP_ADDRESS"
echo "👤 Username: $USERNAME"
echo "📁 Remote folder: $REMOTE_FOLDER"

# Auto-detect .pem file in current directory
SCP_OPTIONS=""
SSH_OPTIONS=""
PEM_FILES=(*.pem)

if [ ! -f "${PEM_FILES[0]}" ]; then
    echo "⚠️  No .pem key file found in current directory. Attempting connection without key..."
else
    if [ ${#PEM_FILES[@]} -eq 1 ]; then
        KEY_FILE="${PEM_FILES[0]}"
        echo "🔑 Found key file: $KEY_FILE"
    else
        echo "🔑 Found multiple .pem files:"
        for i in "${!PEM_FILES[@]}"; do
            echo "  $((i+1)). ${PEM_FILES[i]}"
        done
        KEY_FILE="${PEM_FILES[0]}"
        echo "🔑 Using first key file: $KEY_FILE"
    fi
    
    SCP_OPTIONS="-i \"$KEY_FILE\""
    SSH_OPTIONS="-i \"$KEY_FILE\""
fi

# Get all .tar files in the current directory
TAR_FILES=(*.tar)

# Check if any .tar files exist
if [ ! -f "${TAR_FILES[0]}" ]; then
    echo "❌ No .tar files found in the current directory!"
    echo "Please ensure you have Docker image tar files in the docker-images folder."
    exit 1
fi

echo "📦 Found ${#TAR_FILES[@]} .tar file(s):"
for file in "${TAR_FILES[@]}"; do
    if [ -f "$file" ]; then
        size_mb=$(du -m "$file" | cut -f1)
        size_gb=$(echo "scale=2; $size_mb / 1024" | bc -l 2>/dev/null || echo "$(($size_mb / 1024))")
        echo "  - $file (${size_gb} GB)"
    fi
done

# Create remote directory first
echo "📁 Creating remote directory if it doesn't exist..."
ssh_cmd="ssh $SSH_OPTIONS $USERNAME@$IP_ADDRESS \"mkdir -p $REMOTE_FOLDER\""
echo "🔄 Running: $ssh_cmd"
eval $ssh_cmd

if [ $? -ne 0 ]; then
    echo "❌ Failed to create remote directory!"
    exit 1
fi

# Copy each .tar file
total_files=${#TAR_FILES[@]}
current_file=0

for tar_file in "${TAR_FILES[@]}"; do
    if [ -f "$tar_file" ]; then
        current_file=$((current_file + 1))
        echo ""
        echo "📤 Copying file $current_file/$total_files: $tar_file"
        
        scp_cmd="scp $SCP_OPTIONS \"$tar_file\" $USERNAME@$IP_ADDRESS:$REMOTE_FOLDER/"
        echo "🔄 Running: $scp_cmd"
        
        start_time=$(date +%s)
        eval $scp_cmd
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        
        if [ $? -eq 0 ]; then
            echo "✅ Successfully copied $tar_file in ${duration} seconds"
        else
            echo "❌ Failed to copy $tar_file!"
            exit 1
        fi
    fi
done

echo ""
echo "✅ All Docker images copied successfully!"
echo "🌐 Files copied to: $USERNAME@$IP_ADDRESS:$REMOTE_FOLDER/"
echo ""
echo "📋 Next steps:"
echo "  1. SSH into your EC2 instance: ssh $SSH_OPTIONS $USERNAME@$IP_ADDRESS"
echo "  2. Navigate to the directory: cd $REMOTE_FOLDER"
echo "  3. Load the Docker images: docker load -i *.tar"
echo "  4. Verify loaded images: docker images" 