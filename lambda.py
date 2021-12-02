import re

import boto3
import subprocess
import json
import logging
import os
import os.path
import pprint
import sys
import traceback

def build_hugo(hugo, build_dir):
    """Builds hugo in build_dir, with the executable hugo"""
    build_dir = os.path.normpath(build_dir)
    old_dir = os.curdir
    try:
        os.chdir(build_dir)
        print("Hugo is", hugo)
        print(os.listdir())
        p = subprocess.run([hugo, ],
                           capture_output=True,
                           cwd=os.path.normpath(build_dir))
        print(p)
        if p.returncode == 0:
            return True
        return False
    finally:
        os.chdir(old_dir)


def checkout_git(repo: str, src_dir: str):
    old_dir = os.curdir
    try:
        os.chdir(src_dir)
        if os.path.isdir("checkout"):
            cmd = ["git", "pull"]
            os.chdir("checkout")
        else:
            cmd = ["git", "clone", repo, "checkout"]
        print("Running: ", cmd)
        p = subprocess.run(cmd,
                           capture_output=True)
        print(p)
        if p.returncode == 0:
            return True
        return False
    finally:
        os.chdir(old_dir)


def sync_site(localpath: str, bucket: str):
    print(f"Syncing site to bucket: '{bucket}'")
    cmd = ["/usr/bin/aws", "s3", "sync", f"{localpath}/.", bucket]
    print("Running: ", cmd)
    p = subprocess.run(cmd,
                       capture_output=True)
    print(p)
    if p.returncode == 0:
        return True
    return False


def invalidate_cache(dist):
    print(f"Invalidate distribution: {dist}")
    cmd = ["/usr/bin/aws", "--no-paginate", "cloudfront",
           "create-invalidation", "--paths", '/*', "--distribution-id", dist]
    print("Running: ", cmd)
    p = subprocess.run(cmd,
                       capture_output=True)
    print(p)
    if p.returncode == 0:
        return True
    return False


def handler(event, context):
    """Lambda handler"""
    try:
        if not checkout_git(os.environ["GIT_REPO"], "/tmp"):
            raise RuntimeError("Failed to perform git checkout.")
        if not build_hugo("/usr/bin/hugo", "/tmp/checkout"):
            raise RuntimeError("Failed to build hugo")
        if not sync_site("/tmp/checkout/public", os.environ["S3_BUCKET"]):
            raise RuntimeError("Could not sync site to S3")
        for dist in os.environ["INVALIDATE_DISTRIBUTIONS"].split(" "):
            if not invalidate_cache(dist):
                raise RuntimeError(f"Could not invalidate distro: {dist}")
        return {
            'statusCode': 200,
            'body': json.dumps({"message": 'Updater ran.',
                                "context": str(context),
                                "event": str(event),
                                "logs": ["top of logs"]}),
            "isBase64Encoded": False}
    except Exception as exc:
        sys.stderr.write("Error: %s" % str(exc))
        traceback.print_exc()
        exc_out = traceback.format_exc()
        return {
            'statusCode': 500,
            'body': json.dumps({'exception': str(exc_out)}),
            "isBase64Encoded": False
        }
