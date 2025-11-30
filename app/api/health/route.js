import { db } from "@/lib/prisma";

export async function GET() {
  try {
    // Test database connection
    await db.$queryRaw`SELECT 1`;
    
    return Response.json(
      {
        status: "ok",
        timestamp: new Date().toISOString(),
        database: "connected",
      },
      { status: 200 }
    );
  } catch (error) {
    return Response.json(
      {
        status: "error",
        timestamp: new Date().toISOString(),
        database: "disconnected",
        error: error.message,
      },
      { status: 503 }
    );
  }
}

