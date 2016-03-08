#!/bin/bash

set -euo pipefail

function configureTravis {
  mkdir ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/v27 | tar zx --strip-components 1 -C ~/.local
  source ~/.local/bin/install
}
configureTravis

case "$TEST" in

ci)
  SONAR_PROJECT_VERSION=`maven_expression "project.version"`
 
  # Do not deploy a SNAPSHOT version but the release version related to this build
  set_maven_build_version $TRAVIS_BUILD_NUMBER
 
  # the profile "deploy-sonarsource" is defined in parent pom v28+
  mvn org.jacoco:jacoco-maven-plugin:prepare-agent deploy sonar:sonar \
    -Pcoverage-per-test,deploy-sonarsource \
    -Dmaven.test.redirectTestOutputToFile=false \
    -Dsonar.host.url=$SONAR_HOST_URL \
    -Dsonar.login=$SONAR_TOKEN \
    -Dsonar.projectVersion=$SONAR_PROJECT_VERSION \
    -B -e -V
  ;;

ruling)

  mvn -B -e -Dsonar.runtimeVersion="LATEST_RELEASE" -Dmaven.test.redirectTestOutputToFile=false -Pit-$TEST package
  ;;

*)
  echo "Unexpected TEST mode: $TEST"
  exit 1
  ;;

esac
