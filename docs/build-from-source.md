## Build from source

1. **Clone the repository**:
   ```bash
   git clone https://github.com/shommey/dockerized-quartz.git
   cd dockerized-quartz
   ```

2. **Copy docker-compose example**: \
    `cp docker-compose.yml.example docker-compose.yml`

3. **Edit compose file**:
    ```yaml
    version: '3.8'
    services:
        quartz:
            build:
                context: .
            container_name: quartz-notes
            environment:
            # Use your custom Quartz repo or leave blank for the default Quartz repo
            # GIT_REPO: "https://github.com/yourusername/your-quartz-site.git"
            # Optional: specify a branch to checkout
            # GIT_BRANCH: "v4"   # upstream default is v5, set this to stay on v4
            # Optional: Update delay after which quartz build will trigger, default 300 seconds
            BUILD_UPDATE_DELAY: 900
            # Optional: Auto rebuild Quartz after change in Obsidian Vault 
            AUTO_REBUILD: true
            volumes:
            # Mount your Obsidian vault for Quartz to read and build the site from
            - /path/on/host:/vault:ro
            # Optional: Mount existing Quartz repo
            # - /path/on/host:/usr/src/app/quartz
            # Optional: Persist nginx logs if needed
            # - /path/to/nginx/logs:/var/log/nginx
            # Optional: Mount nginx conf
            # - /path/on/host:/etc/nginx
            ports:
            # Map any port on the host to port 80 in the container for web access
            - "80:80"
            restart: unless-stopped
    ```
4. **Run it**: \
    `docker compose up -d` in the repo directory. \
    Access your Quartz site on `http://<YOUR_MACHINE_IP>:<PORT>`