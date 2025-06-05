import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
  typography: {
    DEFAULT: {
      css: {
        table: {
          borderCollapse: 'collapse',
          width: '100%',
          marginTop: '2rem',
          marginBottom: '2rem',
        },
        'thead tr': {
          borderBottom: '2px solid #e5e7eb',
        },
        'thead th': {
          padding: '0.75rem 1rem',
          textAlign: 'left',
          fontWeight: '600',
          textTransform: 'uppercase',
          fontSize: '0.75rem',
          color: '#374151',
          backgroundColor: '#f9fafb',
        },
        'tbody tr': {
          borderBottom: '1px solid #e5e7eb',
        },
        'tbody tr:hover': {
          backgroundColor: '#f9fafb',
        },
        'tbody td': {
          padding: '0.75rem 1rem',
          fontSize: '0.875rem',
          color: '#4b5563',
        },
      },
    },
  },
};

export default config; 