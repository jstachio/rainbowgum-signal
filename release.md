## Explanation

This project does not use the maven release plugin for a variety of reasons:

  * Creates an environment that can be very different from the normal snapshot deploy process by forking
  * Needlessly edits the pom file twice and checkins it in which **requires every pom file in the project to be changed**.
  * Because it constantly changes the SNAPSHOT pom on each release downstream projects have to remember to update their SNAPSHOT version even for patch releases.

Unlike the maven release plugin we do not constantly change the pom for each patch version.
The release version is stored in a properties file called `version.properties`.
The pom only should change (commited change) if the minor or major version changes. 

For example say the pom is `0.7.0-SNAPSHOT` and our last release is `0.6.0`.

If we now want to make a patch version of `0.6.1` the pom file will not need to be updated (except by the release script for deployment).
However if we are actually wanting to finally release `0.7.0` then the pom must be updated to something like `0.8.0-SNAPSHOT`.

The `vh` script will mostly make sure you do not violate this.

## Directions

### Deploying SNAPSHOTs

If you just want to deploy a snapshot to centrals snapshot repositories run:

```
./mvnw clean -T1 deploy -Pcentral -Ddeploy=snapshot -Duser.timezone=UTC
```

`-Ddeploy=snapshot` also activates the `deploy-snapshot` profile, which forces
`maven.build.cache.enabled=false` regardless of any `-Pcache`/`RAINBOWGUM_CACHE`
opt-in so a stale cached artifact never gets deployed in place of a real build.

### Deploying Releases

Here is the process for **release**:

`version.properties` starts at `0.0.0`, meaning nothing has been released yet. The
first release sets it to the pom's version without `-SNAPSHOT` (e.g. `0.1.0`).

1. Edit `version.properties` to the desired release version by calling:

  1. `bin/vh set current NEW_VERSION` 

1. If this is not a patch release you will need to update the pom to a later snapshot
   
  1. `bin/vh set pom VERSION-SNAPSHOT` # where VERSION is the new minor/major version

1. Checkin the file `version.properties` (and pom file if minor or major version change). It will serve as the commit for tagging reproducible builds.
1. run `bin/vh release` which will tag and temporarily update the pom for release. **DO NOT CHECKIN THE ALTERED POM**
1. Run the commands it tells you to run


### Updating Documentation

This is a single module, so its javadoc jar is published with each release and
javadoc.io can host it directly. There is no aggregate javadoc to update.

### Updating the Rainbow Gum version

This project versions independently of Rainbow Gum. The parent pom's managed Rainbow
Gum dependencies use `${project.version}`, so `pom.xml` pins them to the
`rainbowgum.version` property instead. When moving to a new Rainbow Gum release, update
the `<parent>` version and `rainbowgum.version` together.

### Reproducing a release

Because we do not alter the pom file reproducing a release build is less trivial but this not a normal use case anyway

```
git checkout SOME_TAG
bin/vh set pom  # no argument means use the version properties
./mvnw -T1 clean install -Duser.timezone=UTC
```

