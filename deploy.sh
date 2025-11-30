#!/bin/bash

# Deployment script for Jira Clone
# Usage: ./deploy.sh [production|staging]

set -e

ENVIRONMENT=${1:-production}
DEPLOY_PATH="/var/www/jira-clone"
BRANCH="main"

echo "🚀 Starting deployment to $ENVIRONMENT..."

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Are you in the project root?"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm ci

# Generate Prisma Client
echo "🔧 Generating Prisma Client..."
npx prisma generate

# Run database migrations
echo "🗄️  Running database migrations..."
npx prisma migrate deploy

# Build the application
echo "🏗️  Building Next.js application..."
npm run build

# Create deployment package
echo "📦 Creating deployment package..."
mkdir -p deploy
cp -r .next deploy/
cp -r public deploy/
cp -r node_modules deploy/
cp -r prisma deploy/
cp package.json deploy/
cp package-lock.json deploy/
cp next.config.mjs deploy/
cp -r app deploy/
cp -r components deploy/
cp -r actions deploy/
cp -r lib deploy/
cp -r hooks deploy/
cp -r data deploy/
cp middleware.js deploy/
cp jsconfig.json deploy/
cp tailwind.config.js deploy/
cp postcss.config.mjs deploy/

# Copy environment file (if exists)
if [ -f ".env.production" ]; then
    cp .env.production deploy/.env
    echo "✅ Copied production environment file"
elif [ -f ".env" ]; then
    cp .env deploy/.env
    echo "✅ Copied environment file"
else
    echo "⚠️  Warning: No .env file found. Make sure to set environment variables on the server."
fi

echo "✅ Deployment package created successfully!"
echo "📤 Next steps:"
echo "   1. Transfer 'deploy' folder to server: $DEPLOY_PATH"
echo "   2. On server, run: cd $DEPLOY_PATH && npm install --production"
echo "   3. Restart the application (PM2/Docker/systemd)"

