## Mounting the Vault as a Volume

The container path of the Obsidian vault is located at `/vault`. If no volume bind is provided, the container will copy example documentation to `/vault`, allowing it to be used as a demonstration.

The recommended way to provide the Obsidian vault to the container is by using a bind-mount volume:

```sh
-v /path/on/host:/vault:ro
```

**Note**
When possible use the `:ro` (read-only) flag to prevent unintentional modifications to the vault from within the container.

## Using a Different Path with `VAULT_DIR`

`VAULT_DIR` sets the directory Quartz builds from. It defaults to `/vault`, so if you mount your
vault there you never need to set it.

Set it when the notes live somewhere else in the container:

```sh
-e VAULT_DIR=/notes -v /path/on/host:/notes:ro
```

If the directory does not exist, the container stops at startup with an error instead of building
an empty site.

### Notes That Live in Your Own Quartz Repo

Quartz keeps its notes in the `content` folder of the repository. If you set `GIT_REPO` to your own
Quartz repo and committed your notes to it, point `VAULT_DIR` at that folder and skip the vault
mount entirely:

```yaml
environment:
  GIT_REPO: "https://github.com/yourusername/your-quartz-site.git"
  VAULT_DIR: "/usr/src/app/quartz/content"
```

The check happens after the clone, so a path inside the checkout is fine. Note that the upstream
Quartz `.gitignore` excludes `content`, so make sure your notes are actually committed.

Also keep in mind that an existing Quartz checkout wins over `GIT_REPO`, see
[Providing Quartz](providing-quartz.md). If you mounted a volume at `/usr/src/app/quartz` and it
already has content, a changed `GIT_REPO` is ignored and so are the notes in it.

## Updating the Vault

There are two main methods to update the vault contents: **External Updates** and **Git-based Updates**.

### 1. External Updates

If you are using an external tool such as **Syncthing**, **direct editing with Obsidian**, or any other synchronization method, you can trigger a rebuild of the Quartz site through an **auto-rebuild mechanism**, a **cron job**, or a **webhook**.

#### Example: Syncthing Setup

- Syncthing can sync the entire Obsidian vault to a directory, e.g., `/home/user/Obsidian/`.
- Bind volume to container `-v /home/user/Obsidian:/vault:ro`
- Quartz will detect changes when syncthing syncs and execute rebuild
- If auto update (detect on file changes) is disabled, cronjob or webhook can be used to execute update. 

[Post Webhook Plugin](https://github.com/Masterb1234/obsidian-post-webhook/) can be useful for this scenario.

### 2. Git-based Updates

If your Obsidian vault is hosted in a Git repository (e.g., **GitHub**), follow these steps:

1. Prepare the vault folder on the host machine:
   ```sh
   mkdir /path/on/host/vault
   ````
2. Perform an initial Git clone or pull into this folder:
   ```sh
   git clone <your-repo-url> /path/on/host/vault
   ```
3. Set the environment variable to enable automatic Git pulls:
   ```sh
   VAULT_DO_GIT_PULL_ON_UPDATE=true
   ```
4. Choose an update strategy:
   - **Cron job**: Schedule periodic updates
   - **Webhook**: Trigger rebuilds on repository changes

Before rebuilding, the container will execute a `git pull` inside the vault directory to fetch the
latest changes. That is `/vault` unless you set `VAULT_DIR`, in which case it is that directory.

**Note**:
When using Git-based updates volume **needs** read-write permissions to execute `git pull`. Mount volume with `/path/on/host/git_vault:/vault` without the `:ro` flag.