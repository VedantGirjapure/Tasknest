/*
  Warnings:

  - The primary key for the `Project` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `key` on the `Project` table. All the data in the column will be lost.
  - The `id` column on the `Project` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - A unique constraint covering the columns `[name]` on the table `Sprint` will be added. If there are existing duplicate values, this will fail.
  - Changed the type of `projectId` on the `Issue` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `organizationId` on the `Project` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `projectId` on the `Sprint` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.

*/
-- DropForeignKey
ALTER TABLE "Issue" DROP CONSTRAINT "Issue_projectId_fkey";

-- DropForeignKey
ALTER TABLE "Sprint" DROP CONSTRAINT "Sprint_projectId_fkey";

-- DropIndex
DROP INDEX "Project_organizationId_key_key";

-- AlterTable
ALTER TABLE "Issue" DROP COLUMN "projectId",
ADD COLUMN     "projectId" INTEGER NOT NULL;

-- AlterTable
ALTER TABLE "Project" DROP CONSTRAINT "Project_pkey",
DROP COLUMN "key",
DROP COLUMN "id",
ADD COLUMN     "id" SERIAL NOT NULL,
DROP COLUMN "organizationId",
ADD COLUMN     "organizationId" INTEGER NOT NULL,
ADD CONSTRAINT "Project_pkey" PRIMARY KEY ("id");

-- AlterTable
ALTER TABLE "Sprint" DROP COLUMN "projectId",
ADD COLUMN     "projectId" INTEGER NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "Sprint_name_key" ON "Sprint"("name");

-- AddForeignKey
ALTER TABLE "Sprint" ADD CONSTRAINT "Sprint_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Issue" ADD CONSTRAINT "Issue_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;
