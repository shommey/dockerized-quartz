# Dockerized Quartz

[Quartz (v4)](https://github.com/jackyzha0/quartz) is a lightweight static site generator that helps you host your digital garden. This project provides automated dockerized solution to build and serve Quartz sites with minimal configuration.

## Features

- **Minimal Configuration**: Simply plug in your existing Obsidian Vault as docker bind volume.

- **Automated Builds**: Quartz will rebuild every time after set delay as notes in your docker voulume change.

- **Default or Custom Quartz Repository**: If none present, container will clone git repo on startup, [the Quartz repo](https://github.com/jackyzha0/quartz) or your custom one.

- **Support for Private Repositories**: If you want to hide your Quartz config. 

- **NGINX Web Server**: Served with NGINX, basic configuration by default, can be extended by mounting docker volume and editing `nginx.conf`

### Table of Contents

1. [Overview](overview.md)
2. [Providing Quartz](providing-quartz.md)
3. [Enabling Basic Auth](basic-auth.md)
4. [Building From Source](build-from-source.md)