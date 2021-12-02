#!/bin/bash

set -e

function drop_dead {
	echo "Killing docker..."
	docker kill hpca_updater_test
}

function restart_docker {
  echo "Restarting..."
  docker restart hpca_updater_test
  echo "Restarted, getting logs..."
  docker logs -f hpca_updater_test &
}

export -f restart_docker

trap drop_dead EXIT

echo "Building"
docker build . -t 489816546912.dkr.ecr.us-west-2.amazonaws.com/helenplatt_hugo:latest
echo "Running"
docker run -d --name hpca_updater_test --rm --env-file .env.dockertest -v `pwd`:/var/task -p 9000:8080  489816546912.dkr.ecr.us-west-2.amazonaws.com/helenplatt_hugo:latest
docker logs -f hpca_updater_test &
echo "Watching for changes..."
fswatch -or --event=Updated -e ".*" -i "\\.py$" `pwd` | xargs -n1 -I{} bash -c "restart_docker"