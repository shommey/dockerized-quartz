# Dockerized Quartz

[Quartz](https://github.com/jackyzha0/quartz) is a static site generator for publishing
an Obsidian vault as a website. This project runs it in Docker: mount your vault, and the
container builds the site and serves it with NGINX, rebuilding when the notes change.

## Features

- Mount an existing Obsidian vault as a bind volume. Nothing else is required to get a site.
- Rebuilds on its own after a set delay when notes in the vault change.
- Rebuild on demand with a POST to a secret URL, for a cron job or a git hook.
- Notifications on build start, success and failure, through Apprise.
- Uses the upstream Quartz repo by default, or your own fork with your config and theme.
- Works with private repositories, so your Quartz config can stay private.
- Served by NGINX, with a config you can replace.

## Requirements and versions

- Images are published for `linux/amd64` and `linux/arm64`.
- The image ships Node 24. Quartz needs Node 22 or newer. Build with
  `--build-arg NODE_MAJOR=22` if you need the older line.
- Tags on Docker Hub are `latest`, the full version such as `1.1.0`, and the
  `major.minor` alias such as `1.1`. Pin one of the version tags if you would
  rather not move when a new release lands.

### Which Quartz version you get

With no `GIT_REPO` set, the container clones the upstream Quartz repository and uses its
default branch. Upstream has moved that default to **Quartz v5**, so a fresh container now
builds a v5 site.

To stay on v4, set the branch:

```yaml
environment:
  GIT_BRANCH: "v4"
```

That works with the default repository and with your own. If the branch does not exist the
container stops with an error rather than quietly building something else.

## Quick Start

To quickly get started with Quartz in Docker create `docker-compose.yml` file:

1. **Edit compose file**:
    ```yaml
    services:
      quartz:
        image: shommey/dockerized-quartz:latest
        container_name: quartz-notes
        environment:
          # Optional: your own Quartz repo, leave it out for the default one
          # GIT_REPO: "https://github.com/yourusername/your-quartz-site.git"
          # Optional: branch to check out
          # GIT_BRANCH: "v4"   # upstream default is v5, set this to stay on v4
          # Optional: seconds to wait after a vault change before rebuilding
          BUILD_UPDATE_DELAY: 300
          # Optional: rebuild when the vault changes, default true
          AUTO_REBUILD: "true"
        volumes:
          # Your Obsidian vault. Without it the container serves the
          # bundled docs so you can see it working.
          - ./vault:/vault:ro
          # Optional: keep the Quartz checkout between restarts
          # - ./quartz:/usr/src/app/quartz
          # Optional: persist nginx logs
          # - ./logs:/var/log/nginx
        ports:
          - "80:80"
        restart: unless-stopped
    ```
2. **Run it**: \
    `docker compose up -d` in the directory. \
    Access your Quartz site on `http://<YOUR_MACHINE_IP>:<PORT>`

For more detailed setups [see docs](docs/index.md).

### Documentation

1. [Overview](docs/overview.md)
2. [Providing Quartz](docs/providing-quartz.md)
3. [Importing Obsidian Vault](docs/importing-vault.md)
4. [Enabling Basic Auth](docs/basic-auth.md)
5. [Building From Source](docs/build-from-source.md)
6. [Trigger Rebuild With Webhook](docs/trigger-rebuild-with-webhook.md)
7. [Cron Job Trigger](docs/cron-job-trigger.md)
8. [Notifications Setup](docs/notifications.md)

---

### Attribution  

This project builds upon and integrates several open-source projects:  

- [**Quartz**](https://github.com/jackyzha0/quartz) – The core static site generator that powers this project.  
- [**Apprise**](https://github.com/caronc/apprise) – Handles notifications for build status updates.  
- [**NGINX**](https://www.nginx.com/) – Serves the generated Quartz site with a configurable web server.  

Thanks to the maintainers of these projects.
