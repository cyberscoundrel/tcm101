"use client";

import { useSearchParams } from "next/navigation";
import Link from "next/link";
import { Suspense } from "react";

// Force dynamic rendering
export const dynamic = 'force-dynamic';

function AuthErrorContent() {
  const searchParams = useSearchParams();
  const error = searchParams.get("error");

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full space-y-8 p-8 bg-white rounded-lg shadow">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Authentication Error
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            {error || "An error occurred during authentication"}
          </p>
        </div>
        <div className="mt-8 space-y-6">
          <Link
            href="/"
            className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Return to Login
          </Link>
        </div>
      </div>
    </div>
  );
}

export default function AuthError() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <AuthErrorContent />
    </Suspense>
  );
} 