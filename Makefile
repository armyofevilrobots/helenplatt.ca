# Build/run/upload the hugo site to an S3 destination

REPO?="https://github.com/armyofevilrobots/helenplatt.ca.git"
BUCKET?="s3://helenplatt.ca/"
DISTRIBUTIONS=EQHBN8JGAB1PH E2AQZO73BPIN3E
SHELL=/bin/bash

.PHONY: hugo s3 all invalidate cicd whoami

docker:
	docker build -f Dockerfile .

hugo:
	hugo

s3: hugo
	aws s3 sync public/. "${BUCKET}"

invalidate: $(DISTRIBUTIONS)
$(DISTRIBUTIONS):
	# echo "${DISTRIBUTIONS}" | xargs -d " " -I DIST ./invalidate.sh DIST
	./invalidate.sh $@

checkout:
	git clone ${REPO} checkout

all: hugo s3 invalidate

whoami:
	whoami

cicd: whoami checkout
	$(MAKE) -C checkout all
