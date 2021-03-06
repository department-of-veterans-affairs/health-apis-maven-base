# Maven Base

Maven base Docker images.

## Supported Builds
The following builds are supported.
- Maven 3.5 with Java 8 (`3.5-jdk-8`, `latest`)
- Maven 3.6 with Java 12 (`3.6-jdk-12`)

## Build Process
Run `build.sh [8|12]` to generate images. Omit version to build all supported images.

Tags will be appended with _-$VERSION_ (e.g. `3.6-jdk-12-1.0.0-SNAPSHOT`). This is done primarily to prevent Jenkins from using a pre-release image to build any applications.

Upon release, images will be retagged to remove _-$VERSION_ and pushed to Docker Hub.

## Notes
The `3.5-jdk-8` is also tagged with `latest` to be backwards compatible with applications that use Jenkin's `standardMavenPipeline` without specifying a `healthApisMavenImage`.

