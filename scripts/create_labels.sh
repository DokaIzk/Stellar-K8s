#!/bin/bash
# Create all necessary labels for Stellar Wave issues
# Uses || true to ignore errors if label already exists

echo "Creating labels..."

gh label create rust --color DEA584 --description "Rust related" || true
gh label create soroban --color 7F129E --description "Soroban smart contracts" || true
gh label create observability --color C2E0C6 --description "Metrics and logs" || true
gh label create ci --color 0075ca --description "CI/CD" || true
gh label create security --color d73a4a --description "Security related" || true
gh label create reliability --color d93f0b --description "Reliability and stability" || true
gh label create architecture --color 0e8a16 --description "Architecture design" || true
gh label create logic --color 5319e7 --description "Business logic" || true
gh label create kubernetes --color 326ce5 --description "Kubernetes related" || true
gh label create feature --color a2eeef --description "New feature" || true
gh label create testing --color C2E0C6 --description "Tests" || true

echo "Labels created."
