# Gitpod auto playwright server forwarding

This launches a local playwright server on your MacBook and automatically sets up reverse port forwarding so that the playwright server is accessible from all your Gitpod workspaces.

It monitors for newly created Gitpod workspaces using the `gitpod` CLI in the background.

# Prerequisites

Open a terminal on your MacBook and run following commands. This will install nodejs (if missing) and Gitpod CLI. Homebrew is necessary.

```bash
brew install gitpod-io/tap/gitpod bash
! which npm && brew install node

gitpod login --host gitpod.io # change the host to your enterprise instance if needed
```

After you're logged in to Gitpod. Run this final command:

```bash
curl --proto '=https' --tlsv1.2 -sSfL "https://raw.githubusercontent.com/gitpod-samples/playwright-local-server/31686f5/gitpod-autopwf" | bash -s selfinstall
```

# Setup

Add the following line to your gitpod Dockerfile and push to your repository:

```dockerfile
ENV PW_TEST_CONNECT_WS_ENDPOINT=ws://127.0.0.1:3000
```

This only needs to be done once and by someone who maintains the Gitpod configuration files.

Now all your newly created Gitpod workspaces should use the local playwright server running on your MacBook for `playwright test` commands.
