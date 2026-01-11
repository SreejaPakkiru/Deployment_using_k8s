#!/bin/bash
# Quick sanity check for container

echo "Running smoke test inside $(hostname)..."

# Example: Check if service responds
curl -s http://localhost:5000/health | grep "OK" && echo "Smoke test passed" || exit 1
