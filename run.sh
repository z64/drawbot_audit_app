#!/bin/bash

export CRYSTAL_LOG_SOURCES="log,discord.*"
export CRYSTAL_LOG_LEVEL="INFO"

export DISCORD_TOKEN="Bot TOKEN"
export OWNER_ID=USER_ID_HERE

exec bin/app
