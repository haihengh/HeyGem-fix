# Heygem - Open Source Alternative to Heygen [【中文原文】](./README_zh.md)  [【English readme】](./README_en.md)


# this is a folk from  Caladog/HeyGem, mainly fix issues with the client unable to make proper connection to the docker containers

# here's how to rebuild and redeploy the application and Docker:

## **Rebuild the Electron Application**

```powershell
# 1. Install/update dependencies
npm install

# 2. Build the application (development build)
npm run build

```

## to run locally, run the following command should bring up the test client, which I use

```powershell

npm run dev 

```
# building executable 
```powershell
# Build executable for your platform
npm run build:win      # For Windows
npm run build:linux    # For Linux
npm run build:unpack   # For preview/testing
```

## **Rebuild and Deploy Docker**

For your Docker deployment, you have three compose configurations:

**1. Full Production Setup:**
```powershell
docker-compose -f deploy/docker-compose.yml up -d --build
```
This starts all services: TTS, ASR, and video generation.

**2. Lite Version (if you prefer minimal resources):**
```powershell
docker-compose -f deploy/docker-compose-lite.yml up -d --build
```

**3. Linux-specific Setup:**
```powershell
docker-compose -f deploy/docker-compose-linux.yml up -d --build
```

## **Complete Rebuild & Redeploy Workflow**

```powershell
# Step 1: Stop existing containers
docker-compose -f deploy/docker-compose.yml down

# Step 2: Rebuild application
npm run build

# Step 3: Build Windows executable (optional)
npm run build:win

# Step 4: Redeploy Docker services
docker-compose -f deploy/docker-compose.yml up -d --build

# Step 5: Check status
docker-compose -f deploy/docker-compose.yml ps
```

## **Useful Docker Commands**

```powershell
# View logs
docker-compose -f deploy/docker-compose.yml logs -f

# Restart services
docker-compose -f deploy/docker-compose.yml restart

# Clean up everything (containers + volumes)
docker-compose -f deploy/docker-compose.yml down -v

# View specific service logs
docker logs heygem-gen-video -f
```

**Note:** The Docker images (guiji2025/fish-speech-ziming, etc.) are pre-built and pulled from a registry. If you need to rebuild those images, you'd need their source Dockerfiles.

