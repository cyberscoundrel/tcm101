import { NextResponse } from 'next/server';
import { getContentItems } from '@/lib/content';

export async function GET() {
  try {
    const contentItems = getContentItems();
    return NextResponse.json(contentItems);
  } catch (error) {
    console.error('Error fetching content items:', error);
    return NextResponse.json([], { status: 500 });
  }
} 