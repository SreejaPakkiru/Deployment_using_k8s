#!/bin/bash
set -e

chmod +x /tests/smoke-test.sh
chmod +x /tests/integration-test.sh

echo "Running Smoke Tests..."
/tests/smoke-test.sh

echo "Running Integration Tests..."
/tests/integration-test.sh

echo "All tests passed successfully!"
