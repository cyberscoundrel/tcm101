import { NextResponse } from "next/server";
import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

export async function POST(req: Request) {
  try {
    const { email, password, verificationCode, addCode } = await req.json();

    // Verify the verification code
    const verification = await prisma.verificationCode.findFirst({
      where: {
        email,
        code: verificationCode,
        expiresAt: {
          gt: new Date(),
        },
      },
    });

    if (!verification) {
      return NextResponse.json(
        { error: "Invalid or expired verification code" },
        { status: 400 }
      );
    }

    // Verify the add code
    const validAddCode = await prisma.addCode.findFirst({
      where: {
        code: addCode,
        used: false,
      },
    });

    if (!validAddCode) {
      return NextResponse.json(
        { error: "Invalid or used add code" },
        { status: 400 }
      );
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        verified: true,
        addCodeId: validAddCode.id,
      },
    });

    // Mark add code as used
    await prisma.addCode.update({
      where: { id: validAddCode.id },
      data: { used: true },
    });

    // Delete verification code
    await prisma.verificationCode.delete({
      where: { id: verification.id },
    });

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Error registering user:", error);
    return NextResponse.json(
      { error: "Failed to register user" },
      { status: 500 }
    );
  }
} 