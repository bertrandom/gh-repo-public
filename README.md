# gh-repo-public

A small script that makes the GitHub repo in the current directory public, after showing you what you're about to change and asking for confirmation.

## Requirements

- [`gh`](https://cli.github.com/) — the GitHub CLI, authenticated (`gh auth login`)
- [`gum`](https://github.com/charmbracelet/gum) — for the styled output and confirmation prompt

On macOS:

```sh
brew install gh gum
```

## Usage

From inside a clone of the repo you want to make public:

```sh
/path/to/gh-repo-public.sh
```

The script will:

1. Look up the repo's details with `gh repo view` and show a summary: name, description, URL, current visibility, default branch, last push, stars/forks, and whether it's a fork or archived.
2. Warn that making it public exposes all code **and full git history**, so any committed secrets become visible.
3. Ask for confirmation (defaults to **No**).
4. Run `gh repo edit --visibility public --accept-visibility-change-consequences`.
5. Re-check the repo and confirm it's now public.

If the repo is already public, it says so and exits without changing anything.

## Exit codes

| Code | Meaning |
| ---- | ------- |
| `0`  | Repo is now public, or already was |
| `1`  | Cancelled, missing dependency, not authenticated, no GitHub repo found, or the change failed |

## Before you make a repo public

Changing visibility can have side effects, including losing stars and watchers and detaching forks. See GitHub's docs on [setting repository visibility](https://gh.io/setting-repository-visibility).
