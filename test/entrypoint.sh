#!/bin/sh

. /app/.venv/bin/activate

sudo Xvfb -ac $DISPLAY -screen 0 1280x1024x16 &

exec "$@"
