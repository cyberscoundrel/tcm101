# Documentation Site with Authentication

A Next.js documentation site with email/password authentication, email verification, and add code system.

## Features

- Email/password authentication
- Email verification system
- Add code system for registration
- Password reset functionality
- Protected documentation pages
- MySQL database integration
- TypeScript support
- MDX documentation support

## Prerequisites

- Node.js 18+ and npm
- MySQL database
- SMTP server for email functionality

## Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file in the root directory with the following variables:
   ```
   DATABASE_URL="mysql://user:password@localhost:3306/docs_site"
   NEXTAUTH_SECRET="your-secret-key-here"
   NEXTAUTH_URL="http://localhost:3000"
   EMAIL_SERVER_HOST="smtp.example.com"
   EMAIL_SERVER_PORT=587
   EMAIL_SERVER_USER="your-email@example.com"
   EMAIL_SERVER_PASSWORD="your-email-password"
   EMAIL_FROM="noreply@example.com"
   ```

4. Initialize the database:
   ```bash
   npx prisma db push
   ```

5. Create an add code in the database:
   ```sql
   INSERT INTO AddCode (id, code, used) VALUES (UUID(), 'YOUR_ADD_CODE', false);
   ```

6. Start the development server:
   ```bash
   npm run dev
   ```

## Usage

1. Visit `http://localhost:3000`
2. Use the registration page to create a new account
3. Enter your email to receive a verification code
4. Use the add code provided to complete registration
5. Log in with your credentials
6. Access the protected documentation pages

## Development

- The site uses Next.js 14 with the App Router
- Authentication is handled by NextAuth.js
- Database operations use Prisma ORM
- Styling is done with Tailwind CSS
- MDX files can be added to the `src/content` directory for documentation

## Security

- Passwords are hashed using bcrypt
- Email verification is required for account creation
- Add codes are single-use
- Sessions are managed securely with NextAuth.js
- All routes are protected appropriately

## License

MIT
