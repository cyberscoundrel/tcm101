import fs from 'fs';
import path from 'path';

export interface ContentItem {
  slug: string;
  title: string;
  href: string;
}

export function getContentItems(): ContentItem[] {
  const contentDir = path.join(process.cwd(), 'src/content');
  
  try {
    const files = fs.readdirSync(contentDir);
    const mdxFiles = files.filter(file => file.endsWith('.mdx'));
    
    const contentItems: ContentItem[] = mdxFiles.map(file => {
      const slug = file.replace('.mdx', '');
      const filePath = path.join(contentDir, file);
      const content = fs.readFileSync(filePath, 'utf8');
      
      // Extract the first heading (title) from the MDX content
      const titleMatch = content.match(/^#\s+(.+)$/m);
      const title = titleMatch ? titleMatch[1] : formatSlugToTitle(slug);
      
      return {
        slug,
        title,
        href: `/docs/${slug}`
      };
    });
    
    // Sort alphabetically by title for consistent ordering
    return contentItems.sort((a, b) => a.title.localeCompare(b.title));
  } catch (error) {
    console.error('Error reading content directory:', error);
    return [];
  }
}

function formatSlugToTitle(slug: string): string {
  return slug
    .split('-')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
} 