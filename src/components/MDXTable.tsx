"use client";

import React from 'react';

export function MDXTable({ children }: { children: React.ReactNode }) {
  return (
    <div className="overflow-x-auto my-8">
      <table className="min-w-full border border-gray-300">
        {children}
      </table>
    </div>
  );
}

export function MDXTableHead({ children }: { children: React.ReactNode }) {
  return (
    <thead className="bg-gray-100">
      {children}
    </thead>
  );
}

export function MDXTableBody({ children }: { children: React.ReactNode }) {
  return (
    <tbody>
      {children}
    </tbody>
  );
}

export function MDXTableRow({ children }: { children: React.ReactNode }) {
  return (
    <tr className="border-b border-gray-300 hover:bg-gray-50">
      {children}
    </tr>
  );
}

export function MDXTableHeader({ children }: { children: React.ReactNode }) {
  return (
    <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900 border-r border-gray-300">
      {children}
    </th>
  );
}

export function MDXTableCell({ children }: { children: React.ReactNode }) {
  return (
    <td className="px-6 py-4 text-sm text-gray-600 border-r border-gray-300">
      {children}
    </td>
  );
} 