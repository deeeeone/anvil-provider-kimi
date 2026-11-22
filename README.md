# Kimi Chat for Anvil (on device)

An [Anvil](https://github.com/deeeeone/Anvil) provider plugin that brings Kimi models from kimi.ai into Anvil by running [XxxXTeam/kimi2api](https://github.com/XxxXTeam/kimi2api) on your Mac. Anvil sets it up the first time you use it, starts it when you pick a `kimi-web/…` model, and stops it when Anvil quits.

## Install

In Anvil: **Settings → Provider → Add provider → From GitHub**, paste

```
https://github.com/deeeeone/anvil-provider-kimi
```

and confirm, then click **Sign in…** in its Settings row and sign in at kimi.ai (or **Paste cookies**). Pick a `kimi-web/…` model afterwards.

**Needs:** Python 3.9+ and git. Anvil makes a local virtualenv and installs four Python packages; no system packages are touched.

## What it does

| Step | Where |
|---|---|
| First use: download kimi2api at a pinned commit into `upstream/` and install it into `.venv` | [`setup.sh`](setup.sh) |
| Start the API on `127.0.0.1:37991`, bound to this Mac only | [`start.sh`](start.sh) |
| Tell Anvil where it is, its models, and which token counts as signed in | [`anvil-provider.json`](anvil-provider.json) |

Your prompts go from Anvil to the local proxy, and from there to kimi.ai. `start.sh` reads the `access_token` from the session Anvil captured and gives it to kimi2api as `KIMI_TOKEN`. Nothing is sent anywhere else.

Models offered: `kimi-k2.5`, `kimi-2.6-fast` and `kimi-2.6-thinking`. More arrive from the proxy's live list.

Kimi access tokens last 15 minutes. The plugin also captures the `refresh_token` and renews the access token before it expires, so a signed-in session keeps working until the refresh token itself is revoked.

## Good to know

- This is Kimi's website through an unofficial proxy, not Moonshot's paid API. It can break when the site changes, and it may go against Kimi's terms. Use an account you are prepared to risk.
- Kimi auth is an `access_token` in the site's localStorage, not the marketing page's cookies. Sign in through the provider row, or paste a session that contains it.
- If the refresh token itself expires, requests return `unauthorized`: sign in again and the server restarts with the new session.
- kimi2api has no license file; the plugin downloads it instead of copying it. The plugin's own files are MIT.

## License

The plugin's own files are MIT. kimi2api is by [XxxXTeam](https://github.com/XxxXTeam), under its own terms.
