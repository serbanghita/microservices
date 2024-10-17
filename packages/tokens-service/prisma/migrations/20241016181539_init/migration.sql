-- CreateEnum
CREATE TYPE "ClaimType" AS ENUM ('STRING', 'INTEGER', 'BOOLEAN');

-- CreateEnum
CREATE TYPE "TokenType" AS ENUM ('ACCESS_TOKEN', 'REFRESH_TOKEN');

-- CreateTable
CREATE TABLE "ApiClient" (
    "id" SERIAL NOT NULL,
    "organisationId" INTEGER NOT NULL,
    "username" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "ApiClient_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Scope" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "Scope_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ApiClientAssignedScopes" (
    "id" SERIAL NOT NULL,
    "clientId" INTEGER NOT NULL,
    "scopeId" INTEGER NOT NULL,
    "claimId" INTEGER NOT NULL,

    CONSTRAINT "ApiClientAssignedScopes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Claim" (
    "id" SERIAL NOT NULL,
    "key" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "type" "ClaimType" NOT NULL,

    CONSTRAINT "Claim_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Token" (
    "id" SERIAL NOT NULL,
    "type" "TokenType" NOT NULL DEFAULT 'ACCESS_TOKEN',
    "clientId" INTEGER NOT NULL,
    "content" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL,
    "isRevoked" BOOLEAN NOT NULL DEFAULT false,
    "revokedAt" TIMESTAMP(3),

    CONSTRAINT "Token_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ApiClient_username_key" ON "ApiClient"("username");

-- CreateIndex
CREATE UNIQUE INDEX "Scope_name_key" ON "Scope"("name");

-- CreateIndex
CREATE UNIQUE INDEX "ApiClientAssignedScopes_clientId_scopeId_claimId_key" ON "ApiClientAssignedScopes"("clientId", "scopeId", "claimId");

-- AddForeignKey
ALTER TABLE "ApiClientAssignedScopes" ADD CONSTRAINT "clientId" FOREIGN KEY ("clientId") REFERENCES "ApiClient"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ApiClientAssignedScopes" ADD CONSTRAINT "scopeId" FOREIGN KEY ("scopeId") REFERENCES "Scope"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ApiClientAssignedScopes" ADD CONSTRAINT "claimId" FOREIGN KEY ("clientId") REFERENCES "Claim"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Token" ADD CONSTRAINT "Token_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "ApiClient"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
