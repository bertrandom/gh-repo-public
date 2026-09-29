#!/usr/bin/env bash
#
# Make the GitHub repo for the current directory public, after showing
# some details about it and confirming with the user.
#
# Requires: gh (authenticated), gum

set -euo pipefail

die() {
  gum style --foreground 196 "✗ $*" >&2
  exit 1
}

for cmd in gh gum; do
  command -v "$cmd" >/dev/null 2>&1 || die "'$cmd' is not installed."
done

gh auth status >/dev/null 2>&1 || die "gh is not authenticated. Run 'gh auth login' first."

fields='nameWithOwner,url,description,visibility,isFork,isArchived,stargazerCount,forkCount,defaultBranchRef,pushedAt'
query='[.nameWithOwner, .url, (.description // ""), .visibility, .isFork, .isArchived,
        .stargazerCount, .forkCount, (.defaultBranchRef.name // "—"), .pushedAt]
       | map(tostring) | join("\u001f")'

info=$(gh repo view --json "$fields" --jq "$query" 2>/dev/null) \
  || die "Couldn't find a GitHub repo for $(pwd)."

IFS=$'\x1f' read -r name url description visibility is_fork is_archived \
  stars forks branch pushed_at <<<"$info"

if [[ "$visibility" == "PUBLIC" ]]; then
  gum style --foreground 42 "✓ $name is already public."
  exit 0
fi

gum style \
  --border rounded --border-foreground 212 --padding "1 2" --margin "1 0" \
  "$(gum style --bold --foreground 212 "$name")" \
  "${description:-$(gum style --italic --faint 'No description')}" \
  "" \
  "URL:             $url" \
  "Visibility:      $(gum style --bold --foreground 214 "$visibility")" \
  "Default branch:  $branch" \
  "Last push:       $pushed_at" \
  "Stars / forks:   $stars / $forks" \
  "Fork:            $is_fork" \
  "Archived:        $is_archived"

gum style --foreground 214 \
  "⚠ Making this repo public exposes all of its code and full git history." \
  "  Check for secrets, credentials, or private data before continuing." \
  "  See https://gh.io/setting-repository-visibility for other consequences."
echo

gum confirm --default=false "Make $name public?" || {
  gum style --faint "Cancelled. $name is still $visibility."
  exit 1
}

gum spin --spinner dot --title "Making $name public..." -- \
  gh repo edit "$name" --visibility public --accept-visibility-change-consequences \
  || die "Failed to change visibility of $name."

new_visibility=$(gh repo view "$name" --json visibility --jq '.visibility')
if [[ "$new_visibility" == "PUBLIC" ]]; then
  gum style --foreground 42 "✓ $name is now public: $url"
else
  die "Visibility is still $new_visibility after the change."
fi
