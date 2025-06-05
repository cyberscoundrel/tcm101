# Image Usage Guide for MDX Files

## Setup Complete ✅

Your project now supports images in MDX files! Here's how to use them:

## Image Storage

Place all your images in the `public/images/` directory. The structure should look like:

```
public/
  images/
    lathe-setup.jpg
    bridgeport-controls.png
    threading-diagram.svg
    tooling/
      end-mills.jpg
      drill-bits.png
```

## Using Images in MDX Files

### Basic Image Syntax

In your `.mdx` files, you can use standard Markdown image syntax:

```markdown
![Alt text](image-filename.jpg)
```

### Examples

```markdown
# Lathe Operation Guide

Here's the main control panel:

![Lathe Control Panel](lathe-controls.jpg)

## Threading Setup

The threading dial indicator looks like this:

![Threading Dial](threading-dial.png)

## Tooling

### End Mills
![Various End Mills](tooling/end-mills.jpg)
```

### Advanced Usage

You can also organize images in subdirectories:

```markdown
![Bridgeport Head](milling/bridgeport-head.jpg)
![Collet Chuck](workholding/collet-chuck.png)
```

## Image Features

- **Automatic Optimization**: Images are automatically optimized by Next.js
- **Responsive**: Images scale properly on different screen sizes
- **Lazy Loading**: Images load only when needed
- **Modern Formats**: Supports WebP and AVIF for better performance
- **Styling**: Images are automatically centered with rounded corners and shadows

## Supported Formats

- `.jpg` / `.jpeg`
- `.png`
- `.webp`
- `.avif`
- `.svg`
- `.gif`

## Best Practices

1. **Use descriptive filenames**: `lathe-spindle-controls.jpg` instead of `image1.jpg`
2. **Optimize before uploading**: Compress images to reasonable file sizes
3. **Use appropriate formats**: 
   - Photos: `.jpg` or `.webp`
   - Graphics/diagrams: `.png` or `.svg`
   - Simple illustrations: `.svg`
4. **Add meaningful alt text**: Helps with accessibility
5. **Organize in folders**: Group related images together

## File Size Recommendations

- Photos: Under 500KB each
- Diagrams: Under 200KB each
- Icons/small graphics: Under 50KB each

## Example MDX File with Images

```markdown
# Mill Tooling Guide

## End Mills

End mills are the most common cutting tools for milling operations:

![End Mill Types](tooling/end-mill-types.jpg)

### Selecting the Right End Mill

Consider these factors:

![End Mill Selection Chart](charts/end-mill-selection.png)

## Setup Process

1. **Chuck Installation**
   ![Chuck Installation](setup/chuck-install.jpg)

2. **Tool Insertion**
   ![Tool Insertion Process](setup/tool-insertion.jpg)

3. **Final Check**
   ![Setup Verification](setup/final-check.jpg)
```

## Troubleshooting

If images don't appear:

1. Check the file path is correct
2. Ensure the image is in `public/images/`
3. Verify the file extension matches
4. Check browser console for errors
5. Restart the development server

## Adding Images to Existing Content

You can now add images to any of your existing MDX files:
- `lathe.mdx`
- `bridgeport.mdx`
- `mill-tooling.mdx`
- `lathe-tooling.mdx`
- `threadings.mdx`
- `feeds-speeds.mdx`

Just place the images in `public/images/` and reference them in your MDX files! 