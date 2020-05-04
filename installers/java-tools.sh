#!/bin/bash
################################################################################
##  File:  java-tools.sh
##  Desc:  Installs Java and related tooling (Ant, Gradle, Maven)
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

DEFAULT_JDK_VERSION=11
ARCH=$(dpkg --print-architecture)

set -e

# Install the AdoptOpenJDK JDKs
# See https://adoptopenjdk.net/installation.html#linux-pkg
wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -
add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://adoptopenjdk.jfrog.io/adoptopenjdk/deb $(lsb_release -cs) main"
apt-get -q update
apt-get -y install adoptopenjdk-8-hotspot=\*
apt-get -y install adoptopenjdk-11-hotspot=\*
apt-get -y install adoptopenjdk-12-hotspot=\*
apt-get -y install adoptopenjdk-13-hotspot=\*
update-java-alternatives -s "/usr/lib/jvm/adoptopenjdk-$DEFAULT_JDK_VERSION-hotspot-$ARCH"
echo "JAVA_HOME_8=/usr/lib/jvm/adoptopenjdk-8-hotspot-$ARCH" | tee -a /etc/environment
echo "JAVA_HOME_11=/usr/lib/jvm/adoptopenjdk-11-hotspot-$ARCH" | tee -a /etc/environment
echo "JAVA_HOME_12=/usr/lib/jvm/adoptopenjdk-12-hotspot-$ARCH" | tee -a /etc/environment
echo "JAVA_HOME_13=/usr/lib/jvm/adoptopenjdk-13-hotspot-$ARCH" | tee -a /etc/environment
echo "JAVA_HOME=/usr/lib/jvm/adoptopenjdk-$DEFAULT_JDK_VERSION-hotspot-$ARCH" | tee -a /etc/environment
echo "JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8" | tee -a /etc/environment

# Install Ant
apt-fast install -y --no-install-recommends ant ant-optional
echo "ANT_HOME=/usr/share/ant" | tee -a /etc/environment

# Install Maven
curl -sL https://www-eu.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.zip -o maven.zip
unzip -d /usr/share maven.zip
rm maven.zip
ln -s /usr/share/apache-maven-3.6.3/bin/mvn /usr/bin/mvn
echo "M2_HOME=/usr/share/apache-maven-3.6.3" | tee -a /etc/environment

# Install Gradle
# This script downloads the latest HTML list of releases at https://gradle.org/releases/.
# Then, it extracts the top-most release download URL, relying on the top-most URL being for the latest release.
# The release download URL looks like this: https://services.gradle.org/distributions/gradle-5.2.1-bin.zip
# The release version is extracted from the download URL (i.e. 5.2.1).
# After all of this, the release is downloaded, extracted, a symlink is created that points to it, and GRADLE_HOME is set.
wget -O gradleReleases.html https://gradle.org/releases/
gradleUrl=$(grep -m 1 -o "https:\/\/services.gradle.org\/distributions\/gradle-.*-bin\.zip" gradleReleases.html | head -1)
gradleVersion=$(echo $gradleUrl | sed -nre 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p')
rm gradleReleases.html
echo "gradleUrl=$gradleUrl"
echo "gradleVersion=$gradleVersion"
curl -sL $gradleUrl -o gradleLatest.zip
unzip -d /usr/share gradleLatest.zip
rm gradleLatest.zip
ln -s /usr/share/gradle-"${gradleVersion}"/bin/gradle /usr/bin/gradle
echo "GRADLE_HOME=/usr/share/gradle" | tee -a /etc/environment

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
for cmd in gradle java javac mvn ant; do
    if ! command -v $cmd; then
        echo "$cmd was not installed or found on path"
        exit 1
    fi
done

# Document what was added to the image
echo "Lastly, documenting what we added to the metadata file"
DocumentInstalledItem "AdoptOpenJDK:"
DocumentInstalledItemIndent "8 ($("/usr/lib/jvm/adoptopenjdk-8-hotspot-$ARCH/bin/java" -showversion |& head -n 1))"
DocumentInstalledItemIndent "11 ($("/usr/lib/jvm/adoptopenjdk-11-hotspot-$ARCH/bin/java" -showversion |& head -n 1)) (default)"
DocumentInstalledItemIndent "12 ($("/usr/lib/jvm/adoptopenjdk-12-hotspot-$ARCH/bin/java" -showversion |& head -n 1))"
DocumentInstalledItemIndent "13 ($("/usr/lib/jvm/adoptopenjdk-13-hotspot-$ARCH/bin/java" -showversion |& head -n 1))"
DocumentInstalledItem "Ant ($(ant -version))"
DocumentInstalledItem "Gradle ${gradleVersion}"
DocumentInstalledItem "Maven ($(mvn -version | head -n 1))"
