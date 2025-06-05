"use client";

import { ReactElement } from 'react';
import listStyles from '@/styles/list.module.css';
import codeStyles from '@/styles/code.module.css';
import headerStyles from '@/styles/headers.module.css';

interface MDXContentProps {
  content: ReactElement;
}

const components = {
  ul: ({ children, ...props }: any) => (
    <ul className={listStyles.list} {...props}>
      {children}
    </ul>
  ),
  ol: ({ children, ...props }: any) => (
    <ol className={listStyles.orderedList} {...props}>
      {children}
    </ol>
  ),
  li: ({ children, ...props }: any) => (
    <li className={listStyles.listItem} {...props}>
      {children}
    </li>
  ),
  pre: ({ children, ...props }: any) => (
    <pre className={codeStyles.codeBlock} {...props}>
      {children}
    </pre>
  ),
  code: ({ children, ...props }: any) => (
    <code className={codeStyles.inlineCode} {...props}>
      {children}
    </code>
  ),
  h1: ({ children, ...props }: any) => (
    <h1 className={headerStyles.h1} {...props}>
      {children}
    </h1>
  ),
  h2: ({ children, ...props }: any) => (
    <h2 className={headerStyles.h2} {...props}>
      {children}
    </h2>
  ),
  h3: ({ children, ...props }: any) => (
    <h3 className={headerStyles.h3} {...props}>
      {children}
    </h3>
  ),
};

export default function MDXContent({ content }: MDXContentProps) {
  return (
    <article className="prose prose-slate max-w-none
      prose-p:text-gray-600 prose-p:leading-7 prose-p:my-6
      prose-a:text-blue-600 prose-a:no-underline hover:prose-a:underline
      prose-strong:text-gray-900 prose-strong:font-semibold
      prose-img:rounded-lg prose-img:shadow-md prose-img:my-8
      prose-blockquote:border-l-4 prose-blockquote:border-blue-500 prose-blockquote:pl-6 prose-blockquote:italic prose-blockquote:bg-gray-50 prose-blockquote:py-4 prose-blockquote:px-6 prose-blockquote:my-8
      prose-hr:my-12 prose-hr:border-gray-200
      [&>*:first-child]:mt-0
      [&>*:last-child]:mb-0
      prose-headings:scroll-mt-24">
      {content}
    </article>
  );
} 