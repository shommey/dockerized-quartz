# Dockerized Quartz

[Quartz](https://github.com/jackyzha0/quartz) is a static site generator for publishing an Obsidian vault as a website. This project runs it in Docker: mount your vault, and the container builds the site and serves it with NGINX.

## Features

- **Minimal Configuration**: Simply plug in your existing Obsidian Vault as read-only docker bind volume.

- **Automated Builds**: Quartz will rebuild every time after set delay as files in your docker voulume change.

- **Webhook Trigger**: Additional way of triggering Quartz build by sending POST request to secret URL.

- **Notifications**: Notifications on build start, success or fail. 

- **Default or Custom Quartz Repository**: If none present, container will clone git repo on startup, [the Quartz repo](https://github.com/jackyzha0/quartz). This can be used to quickly test and evaluate stuff.

- **Support for Private Repositories**: If you want to hide your Quartz config. 

- **NGINX Web Server**: Served with NGINX, basic configuration by default, can be extended by mounting docker volume and editing `nginx.conf`

### Table of Contents

1. [Overview](overview.md)
2. [Providing Quartz](providing-quartz.md)
3. [Importing Obsidian Vault](importing-vault.md)
4. [Enabling Basic Auth](basic-auth.md)
5. [Building From Source](build-from-source.md)
6. [Trigger Rebuild With Webhook](trigger-rebuild-with-webhook.md)
7. [Cron Job Trigger](cron-job-trigger.md)
8. [Notifications Setup](notifications.md)