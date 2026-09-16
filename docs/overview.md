## Overview

This project uses simple bash scripts to deploy and rebuild a [Quartz](https://github.com/jackyzha0/quartz.git) site within a Docker container.

By default, if no volumes provided, container will clone default Quartz repo and use docs as content.

### The Scripts

1. **`bootstrap.sh`**  
   This is the main script that runs at the startup of the container. It performs the following tasks:
   
   - Checks if the Quartz repository is already cloned.
   - If the repository is not present, it clones the specified Quartz repository (private or public) into the container.
   - If the repository is already cloned, it skips the cloning step and prepares the environment for Quartz to run.
   - Optionally checks out a custom branch if defined in the environment variables.
   - Perfroms initial Quartz build by running `build-quartz.sh`
   - Optionally runs `watch-and-build-quartz.sh`script. Defaults to true.
   - Starts webhook service, if enabled.

2. **`build-quartz.sh`**  
    A simple script that runs `npx quartz build`.
    - It looks for the Obsidian vault at `$VAULT_DIR`, which defaults to `/vault`.
    - It stops with an error if that directory does not exist. An existing but empty one is fine,
      it builds an empty site and says so in the log.
    - It outputs build files into `/usr/share/nginx/html`

3. **`watch-and-build-quartz.sh`**  
   This script triggers a rebuild of the Quartz site:
   
   - Watches the vault for changes, including subfolders, and folders added later.
   - When notes are updated, the script waits for a set delay to ensure no more edits are happening, then runs the `build-quartz.sh`.

4. **`server.js`**
    Simple node express app that serves as webhook to start Quartz build on demand. More [here](trigger-rebuild-with-webhook.md)

### Paths in the Container

- **Obsidian Vault**:  
  Each time `build-quartz.sh` runs, it instructs Quartz to look in `$VAULT_DIR` for content, which
  defaults to `/vault`.  
  When mounting, make sure to use the root directory of your Obsidian vault and mount it to `/vault`.  
  Set `VAULT_DIR` if the notes live somewhere else in the container, for example in the `content`
  folder of your own Quartz repo. See [Importing Obsidian Vault](importing-vault.md).

- **Quartz Directory**:  
  The Quartz repository is cloned into `/usr/src/app/quartz`.  
  This is where all the Quartz files will be stored inside the container.  
  For more details on how to provide your own Quartz repository, see [Providing Quartz](providing-quartz.md).

- **Scripts Directory**:  
  The `bootstrap.sh`, `build-quartz.sh` and `build-and-watch-quartz.sh` scripts are located in `/usr/src/app/scripts`.

- **NGINX Configuration**:  
  During the image build, `nginx.conf` is copied to `/etc/nginx/nginx.conf`.  
  To persist and customize the NGINX configuration, you can use bind mounts.

- **Logs Directory**:  
  NGINX logs are stored in `/var/log/nginx`, which can be helpful for monitoring access and error logs.

### Environment Variables

- **`GIT_REPO`**:  
  The URL of your Quartz repository.

- **`GIT_BRANCH`**:  
  The branch to check out (optional).

- **`BUILD_UPDATE_DELAY`**:  
  The delay (in seconds) the script will wait after detecting file changes before triggering a Quartz rebuild.

- **`AUTO_REBUILD`**:  
  Set this to enable automatic rebuilding when file changes are detected. 
  Use `true` to enable or `false` to disable.

- **`REBUILD_WEBHOOK_SECRET`**:
  Set to something strong, for example: `UQjO8DJKf9CfA9Gd8cDJmhsjPnKl8MLZ`
  If set, you can send a post request to `http://<ip>:<port>/rebuild/UQjO8DJKf9CfA9Gd8cDJmhsjPnKl8MLZ` to trigger Quartz Build

- **`NOTIFY_TARGET`**
  Apprise target to send notifications to (Slack, Discord, Telegram, Ntfy, etc.).
  Triggers on build start, success or fail.

- **`VAULT_DO_GIT_PULL_ON_UPDATE`**
  Execute git pull in the vault directory before rebuild
  Usefull when storing vault in git repository
  Do initial pull before setting this and make sure container can access the repo
  default false

- **`VAULT_DIR`**
  Where the notes are inside the container. Defaults to `/vault`, which is the mount point
  everything else in the docs uses. Point it at `/usr/src/app/quartz/content` to build the
  notes that came with your own Quartz repo. If the directory does not exist the container
  stops with an error.