import DocsSidebar from "@/components/DocsSidebar";

export default function DocsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="flex">
        <DocsSidebar />
        {/* Main content */}
        <div className="flex-1 p-8">
          <div className="max-w-4xl mx-auto">
            {children}
          </div>
        </div>
      </div>
    </div>
  );
} 