# Docker Images Folder

This folder is used to store Docker image tar files that will be automatically loaded during deployment.

## Usage

1. **Save your Docker image as a tar file:**
   ```bash
   docker save -o docker-images/my-app-latest.tar my-app:latest
   ```

2. **Place the tar file in this folder:**
   - The deployment script will automatically detect any `.tar` files in this folder
   - Multiple tar files are supported and will all be loaded

3. **Run the deployment script with the correct image name:**
   ```bash
   ./deploy-image.sh my-app:latest
   ```
   
   The script will:
   - Automatically find and load all `.tar` files from this folder
   - Verify that the specified image name exists after loading
   - Skip pulling from registry if the image is already available locally

## Image Name Verification

The script will verify that the image name you specify exists after loading the tar files. If the image is not found, it will:
- Show available images
- Provide troubleshooting tips
- Exit with an error

## Example Usage

```bash
# Load and deploy a specific image
./deploy-image.sh docs-app:latest

# With custom IP
./deploy-image.sh docs-app:latest 192.168.1.100
```

## Notes

- You must specify the exact image name and tag that exists in your tar file
- Tar files can be large (like the 984MB `docs-app-latest.tar` currently in this folder)
- The script will load all tar files found, so remove old ones you don't need
- Loading from tar files is faster than pulling from remote registries
- Use `docker images` after loading to see available image names and tags
