// Script to fix users with "null null" or empty names
// Run with: node scripts/fix-user-names.js

const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

async function fixUserNames() {
  try {
    // Find all users with problematic names
    const users = await prisma.user.findMany({
      where: {
        OR: [
          { name: null },
          { name: "" },
          { name: "null null" },
          { name: "null" },
          { name: "undefined undefined" },
        ],
      },
    });

    console.log(`Found ${users.length} users with problematic names`);

    for (const user of users) {
      // Try to get name from email
      let newName = "User";
      if (user.email) {
        newName = user.email.split("@")[0];
        // Capitalize first letter
        newName = newName.charAt(0).toUpperCase() + newName.slice(1);
      }

      await prisma.user.update({
        where: { id: user.id },
        data: { name: newName },
      });

      console.log(`Updated user ${user.id}: "${user.name}" -> "${newName}"`);
    }

    console.log("✅ All user names fixed!");
  } catch (error) {
    console.error("Error fixing user names:", error);
  } finally {
    await prisma.$disconnect();
  }
}

fixUserNames();

