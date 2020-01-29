# Maven Base

Maven base Docker images.

## Supported Builds
The following builds are supported.
- Maven 3.6 with Java 12 (`3.6-jdk-12`)
- Maven 3.6 with Java 13 (`3.6-jdk-13`)

## Build Process
Run `build.sh [12|13]` to generate images. Omit version to build all supported images.

Tags will be appended with _-$VERSION_ (e.g. `3.6-jdk-13-1.0.0-SNAPSHOT`) for pre-release
builds. This is done primarily to prevent Jenkins from using a pre-release image to build
any applications.

Upon release, images will be retagged to remove _-$VERSION_ and pushed to Docker Hub.
