# Build/run/upload the hugo site to an S3 destination

REPO?="https://github.com/armyofevilrobots/helenplatt.ca.git"
PROFILE?="aoer"
BUCKET?="s3://helenplatt.ca/"
DISTRIBUTIONS?="EQHBN8JGAB1PH E2AQZO73BPIN3E"

.PHONY: hugo s3 all invalidate cicd

docker:
	docker build -f Dockerfile .

hugo:
	hugo

s3: hugo
	aws --profile "${PROFILE}" s3 sync public/. "${BUCKET}"

invalidate:
	echo "${DISTRIBUTIONS}" | xargs ./invalidate.sh

checkout:
	git clone ${REPO} checkout

all: hugo s3 invalidate

cicd: checkout
	$(MAKE) -C checkout all