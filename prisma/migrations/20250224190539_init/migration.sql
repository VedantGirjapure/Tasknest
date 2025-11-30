/*
  Warnings:

  - The primary key for the `Project` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - A unique constraint covering the columns `[organizationId,key]` on the table `Project` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `key` to the `Project` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "Issue" DROP CONSTRAINT "Issue_projectId_fkey";

-- DropForeignKey
ALTER TABLE "Sprint" DROP CONSTRAINT "Sprint_projectId_fkey";

-- AlterTable
ALTER TABLE "Issue" ALTER COLUMN "projectId" SET DATA TYPE TEXT;

-- AlterTable
ALTER TABLE "Project" DROP CONSTRAINT "Project_pkey",
ADD COLUMN     "key" TEXT NOT NULL,
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ADD CONSTRAINT "Project_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "Project_id_seq";

-- AlterTable
ALTER TABLE "Sprint" ALTER COLUMN "projectId" SET DATA TYPE TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "Project_organizationId_key_key" ON "Project"("organizationId", "key");

-- AddForeignKey
ALTER TABLE "Sprint" ADD CONSTRAINT "Sprint_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Issue" ADD CONSTRAINT "Issue_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;
