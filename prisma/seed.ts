const { PrismaClient } = require('@prisma/client');
// const crypto = require('crypto');

const prisma = new PrismaClient();

async function main() {
  // Create sample add codes
  const addCodes = [
    'WELCOME2024',
    'DOCS2024',
    'ADMIN2024',
  ];

  for (const code of addCodes) {
    await prisma.addCode.create({
      data: {
        code,
        used: false,
      },
    });
  }

  console.log('Database seeded successfully');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  }); 