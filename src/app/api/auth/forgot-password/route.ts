import { NextResponse } from "next/server";
import { PrismaClient } from "@prisma/client";
import nodemailer from "nodemailer";
import crypto from "crypto";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_SERVER_HOST,
  port: Number(process.env.EMAIL_SERVER_PORT),
  auth: {
    user: process.env.EMAIL_SERVER_USER,
    pass: process.env.EMAIL_SERVER_PASSWORD,
  },
});

export async function POST(req: Request) {
  try {
    const { email, addCode } = await req.json();

    // Verify the add code and user
    const user = await prisma.user.findFirst({
      where: {
        email,
        addCode: {
          code: addCode,
        },
      },
    });

    if (!user) {
      return NextResponse.json(
        { error: "Invalid email or add code" },
        { status: 400 }
      );
    }

    // Generate new password
    const newPassword = crypto.randomBytes(8).toString("hex");

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update user's password
    await prisma.user.update({
      where: { id: user.id },
      data: { password: hashedPassword },
    });

    // Send email with new password
    await transporter.sendMail({
      from: process.env.EMAIL_FROM,
      to: email,
      subject: "Your New Password",
      text: `Your new password is: ${newPassword}`,
      html: `<p>Your new password is: <strong>${newPassword}</strong></p>`,
    });

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Error resetting password:", error);
    return NextResponse.json(
      { error: "Failed to reset password" },
      { status: 500 }
    );
  }
} 