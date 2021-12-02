FROM public.ecr.aws/lambda/python:3.9 as hpca_updater

# Copy function code
ENV AWS_ACCESS_KEY_ID=
ENV AWS_SECRET_ACCESS_KEY=
ENV AWS_DEFAULT_REGION=
ENV GIT_REPO=
ENV S3_BUCKET=
ENV INVALIDATE_DISTRIBUTIONS=

WORKDIR ${LAMBDA_TASK_ROOT}
COPY lambda.py requirements.txt ${LAMBDA_TASK_ROOT}
RUN yum install -y tar gzip git awscli \
    && python3 -m pip install -r requirements.txt

RUN curl -L -O https://github.com/gohugoio/hugo/releases/download/v0.89.4/hugo_0.89.4_Linux-64bit.tar.gz \
    && tar xzvf hugo_0.89.4_Linux-64bit.tar.gz \
    && mv hugo /usr/bin/

VOLUME /var/task
VOLUME /tmp

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "lambda.handler" ]