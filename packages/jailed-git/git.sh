#!/usr/bin/env bash

REAL_GIT="@git@"
GIT_NAME="@gitName@"
GIT_EMAIL="@gitEmail@"

export GIT_AUTHOR_NAME="$GIT_NAME"
export GIT_AUTHOR_EMAIL="$GIT_EMAIL"
export GIT_COMMITTER_NAME="$GIT_NAME"
export GIT_COMMITTER_EMAIL="$GIT_EMAIL"

exec "$REAL_GIT" "$@"
