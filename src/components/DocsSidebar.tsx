"use client";

import { useSession, signOut } from "next-auth/react";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import Link from "next/link";
import { ContentItem } from "@/lib/content";

export default function DocsSidebar() {
  const { data: session, status } = useSession();
  const router = useRouter();
  const [contentItems, setContentItems] = useState<ContentItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (status === "unauthenticated") {
      router.replace("/");
    }
  }, [status, router]);

  useEffect(() => {
    // Fetch content items from API route
    const fetchContentItems = async () => {
      try {
        const response = await fetch('/api/content');
        if (response.ok) {
          const items = await response.json();
          setContentItems(items);
        }
      } catch (error) {
        console.error('Error fetching content items:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchContentItems();
  }, []);

  const handleSignOut = async () => {
    await signOut({ 
      callbackUrl: "/",
      redirect: true 
    });
  };

  if (status === "loading" || loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-xl">Loading...</div>
      </div>
    );
  }

  return (
    <div className="w-64 min-h-screen bg-white border-r border-gray-200">
      <div className="p-4">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Machine Shop Fundamentals & CNC Operation</h2>
        <nav className="space-y-1 mb-8">
          {contentItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="block px-3 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md"
            >
              {item.title}
            </Link>
          ))}
        </nav>
        
        {/* User info and sign out section */}
        <div className="border-t border-gray-200 pt-4">
          <div className="mb-3">
            <p className="text-xs text-gray-500 mb-1">Signed in as:</p>
            <p className="text-sm font-medium text-gray-900 truncate">
              {session?.user?.email}
            </p>
          </div>
          <button
            onClick={handleSignOut}
            className="w-full flex items-center justify-center px-3 py-2 text-sm font-medium text-red-600 hover:text-red-700 hover:bg-red-50 rounded-md border border-red-200 hover:border-red-300 transition-colors"
          >
            <svg 
              className="w-2 h-2 mr-2" 
              fill="none" 
              stroke="currentColor" 
              viewBox="0 0 24 24"
            >
              <path 
                strokeLinecap="round" 
                strokeLinejoin="round" 
                strokeWidth={2} 
                d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" 
              />
            </svg>
            Sign Out
          </button>
        </div>
      </div>
    </div>
  );
} 