#!/bin/bash

set -e

_profiles="$1"
if [ -z "$_profiles" ]; then
  _profiles="checkerframework errorprone nullaway"
fi

# Maven only warns about an unknown -P profile and then runs a plain build with no
# analysis, so a typo like "checker" would otherwise look like a clean run.
_valid_profiles="checkerframework errorprone nullaway"
for profile in $_profiles; do
  if [[ " $_valid_profiles " != *" $profile "* ]]; then
    echo "analyze.sh: unknown profile '$profile'. Valid profiles: $_valid_profiles" >&2
    exit 2
  fi
done

_ignored_profiles="-enforce-maven-version,-format-apply,-deploy-local,-javadoc-jar"

for profile in $_profiles; do
echo ""
echo "--------------------- Running $profile -----------------------"
echo ""

./mvnw $MAVEN_CLI_OPTS clean verify -P${profile},show-profiles,${_ignored_profiles} -Dmaven.javadoc.skip -DskipTests -Dmaven.source.skip=true
done

# Checker or the maven compiler leaves these files around
find . -name "javac.*.args" | xargs rm -f
