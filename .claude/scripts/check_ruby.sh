#!/usr/bin/env bash
set -euo pipefail
set -x

docker-compose run --rm zyra /bin/bash -c 'bundle exec rspec'
docker-compose run --rm zyra /bin/bash -c 'rubocop'
docker-compose run --rm zyra /bin/bash -c 'bundle exec rake verify_measurements'
docker-compose run --rm circleci /bin/bash -c 'check_specs'
