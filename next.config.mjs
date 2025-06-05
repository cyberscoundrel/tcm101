import createMDX from '@next/mdx';
import remarkGfm from 'remark-gfm';

const withMDX = createMDX({
  options: {
    remarkPlugins: [remarkGfm],
    rehypePlugins: [],
  },
});

/** @type {import('next').NextConfig} */
const nextConfig = {
  pageExtensions: ['js', 'jsx', 'mdx', 'ts', 'tsx'],
  experimental: {
    mdxRs: true,
  },
  images: {
    // Allow images from the local public directory
    domains: [],
    // Enable unoptimized images for more flexibility
    unoptimized: false,
    // Add common image formats
    formats: ['image/webp', 'image/avif'],
  },
};

export default withMDX(nextConfig); 