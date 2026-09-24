# devhost

Stable `https://NAME.localhost` URLs for local dev servers on Linux. Caddy runs
as a systemd user service with its own local CA, and `devhost` adds a route per
app. Routes are files in `~/.config/devhost/routes`, so they survive restarts.

```sh
devhost run -- bin/dev                       # Rails: https://<repo>.localhost
devhost run -- bundle exec jekyll serve      # Jekyll: https://<repo>.localhost, or <dir>.<repo> in a subdirectory
devhost add chatwithwork 3000                # route a server that is already running
devhost ls                                   # routes, and whether each app is up
devhost doctor                               # check Caddy, ports and certificate trust
```

`devhost run` names the route after the repository. A linked git worktree
becomes a subdomain (`fix-ui.chatwithwork.localhost`), as does a subdirectory
below the repository root (`docs.archspec.localhost`). `-n NAME` sets the base
name. It keeps `$PORT` when it is set, otherwise it picks a stable free port
between 4000 and 4999. It exports `PORT` and `DEVHOST_URL`, then runs the command.

- Rails: `bin/rails server` and foreman's `bin/dev` listen on `$PORT`. Rails
  already allows `*.localhost` hosts in development. Caddy sends
  `X-Forwarded-Proto: https`, so request URLs, OAuth callbacks and the CSRF
  origin check all use the HTTPS address.
- Jekyll: `jekyll serve` ignores `$PORT` and sets `site.url` to
  `http://localhost:PORT`. `devhost run` adds `--port` for you, and loads
  `jekyll/devhost.rb`, which sets `site.url` to the devhost URL.

## Install

```sh
./install                       # links devhost into ~/.local/bin and enables the user service
bin/devhost-system-setup        # once, uses sudo: see below
systemctl --user restart devhost
devhost trust                   # Chromium's NSS database (~/.pki/nssdb)
devhost doctor
```

`bin/devhost-system-setup` does the steps that need root:

1. It installs `caddy` (and `nss` for `certutil`) from the Arch repos.
2. It runs `setcap cap_net_bind_service=+ep /usr/bin/caddy`, so the user
   service can bind ports 80 and 443.
3. It adds a pacman hook that reapplies that capability when caddy is upgraded.
4. It disables the packaged system-wide `caddy.service`, so it won't compete
   for the ports.
5. It trusts devhost's CA with `trust anchor --store`. This covers curl, Ruby,
   Go and Node. On Arch it also covers Chromium, because NSS reads p11-kit.

Caddy listens on 127.0.0.1 and ::1 only. Its admin API is a Unix socket in
`$XDG_RUNTIME_DIR/devhost`.
