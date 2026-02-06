# Making a more secure nix shell

In `modules/home-manager/zsh/initExtra.zsh` I define a very handy command `s` that lets me spawn into a nix shell with the added packages

The goal is to make a `ss` command (or script or whatever, the point is that it is called by `ss` in the terminal) that spawn a nixos container for situations where I want isolation.

## Requirements
- Once inside the container, it should feel like the outside. For now this means more or less importing the current home manager config inside the containers. (later steps will try to make this less exposed)
- The current directory where the command was lauched should be mounted in the container and the shell we are left in should be that mount point.
- The container should be a rootless container
- It should be a fresh container each time the command is called. The container should auto destroy itself once we leave.
- The container is stateless (i.e., all data outside of what is mounted should be wipe on exit)
