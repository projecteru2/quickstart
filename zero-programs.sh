#!/usr/bin/env bash

# start zero api at :8000
# start zero overwatch "zero monitor"
# start zero worker "zero run"

set -e

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
  exit -1
fi

for subcmd in api run monitor
do
	docker rm -f "zero$subcmd" || true
	docker run -d --name "zero$subcmd" \
		--restart unless-stopped \
		--network host \
		-v /etc/zero.yaml:/etc/zero.yaml \
		$ZEROIMAGE /usr/bin/zero "$subcmd"
	echo started zero $subcmd
done
