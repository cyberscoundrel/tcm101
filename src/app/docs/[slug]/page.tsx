import fs from 'fs';
import path from 'path';
import { notFound } from 'next/navigation';
import { compileMDX } from 'next-mdx-remote/rsc';
import remarkGfm from 'remark-gfm';
import Image from 'next/image';
import MDXContent from '@/components/MDXContent';
import styles from '@/styles/table.module.css';
import listStyles from '@/styles/list.module.css';
import codeStyles from '@/styles/code.module.css';
import headerStyles from '@/styles/headers.module.css';
import { MDXComponents } from 'mdx/types';

const components: MDXComponents = {
  img: ({ src, alt, width, height, ...props }) => {
    const imageSrc = src?.startsWith('/') ? src : `/images/${src}`;
    
    return (
      <div className="my-6 flex justify-center">
        <Image
          src={imageSrc}
          alt={alt || ''}
          width={typeof width === 'number' ? width : 800}
          height={typeof height === 'number' ? height : 600}
          className="rounded-lg shadow-md max-w-full h-auto"
          style={{ objectFit: 'contain' }}
          {...props}
        />
      </div>
    );
  },
  table: ({ children, ...props }) => (
    <div className={styles.tableWrapper}>
      <table {...props} className={styles.table}>
        {children}
      </table>
    </div>
  ),
  thead: ({ children, ...props }) => (
    <thead {...props} className={styles.thead}>
      {children}
    </thead>
  ),
  tbody: ({ children, ...props }) => (
    <tbody {...props} className={styles.tbody}>
      {children}
    </tbody>
  ),
  tr: ({ children, ...props }) => (
    <tr {...props} className={styles.tr}>
      {children}
    </tr>
  ),
  th: ({ children, ...props }) => (
    <th {...props} className={styles.th}>
      {children}
    </th>
  ),
  td: ({ children, ...props }) => (
    <td {...props} className={styles.td}>
      {children}
    </td>
  ),
  ul: ({ children, ...props }) => (
    <ul className={listStyles.list} {...props}>
      {children}
    </ul>
  ),
  ol: ({ children, ...props }) => (
    <ol className={listStyles.orderedList} {...props}>
      {children}
    </ol>
  ),
  li: ({ children, ...props }) => (
    <li className={listStyles.listItem} {...props}>
      {children}
    </li>
  ),
  pre: ({ children, ...props }) => (
    <pre className={codeStyles.codeBlock} {...props}>
      {children}
    </pre>
  ),
  code: ({ children, ...props }) => (
    <code className={codeStyles.inlineCode} {...props}>
      {children}
    </code>
  ),
  h1: ({ children, ...props }) => (
    <h1 className={headerStyles.h1} {...props}>
      {children}
    </h1>
  ),
  h2: ({ children, ...props }) => (
    <h2 className={headerStyles.h2} {...props}>
      {children}
    </h2>
  ),
  h3: ({ children, ...props }) => (
    <h3 className={headerStyles.h3} {...props}>
      {children}
    </h3>
  ),
};

export default async function DocsPage({ params }: { params: { slug: string } }) {
  const filePath = path.join(process.cwd(), 'src/content', `${params.slug}.mdx`);
  
  try {
    const source = fs.readFileSync(filePath, 'utf8');
    
    const { content } = await compileMDX({
      source,
      options: {
        parseFrontmatter: true,
        mdxOptions: {
          remarkPlugins: [remarkGfm],
        },
      },
      components,
    });

    return (
      <div className="container mx-auto px-4 py-8">
        <MDXContent content={content} />
      </div>
    );
  } catch (error) {
    notFound();
  }
} 