# Set up some environment variables as /etc/environment
# isn't sourced in chroot

set -e
set -x

export JAVA_HOME="$(dirname $(dirname $(realpath $(which javac))))"
VERSION=0.29.1

# download the release
cd /root
wget https://github.com/bazelbuild/bazel/releases/download/${VERSION}/bazel-${VERSION}-dist.zip
unzip -d bazel-release bazel-${VERSION}-dist.zip

# Apply patches and build
chmod u+w bazel-release/* -R
patch -p0 < bazel-bootstrap.patch
cd bazel-release
env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" ./compile.sh
cp -f output/bazel /usr/local/bin/bazel

# cleanup
cd /root
rm -rf *.zip *.patch bazel-release

