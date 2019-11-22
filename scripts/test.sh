#!/bin/bash
set -e
scripts/wait_db.sh
mix test
