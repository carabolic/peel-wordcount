#!/bin/bash

TEMP_DIR=$(dirname $(mktemp -u))
CURR_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ARCH_DIR="$CURR_DIR/target/generated-sources/archetype"

# 1) create the archetype
mvn archetype:create-from-project -Darchetype.properties=./archetype.properties

# 2) fix the archetype structure
# remove the copy of this shell script in the archetype folder
find "$ARCH_DIR/src/main/resources/archetype-resources"                                                       \
     -type f -name 'archetype.sh'                                                                             |
     xargs rm -Rf
# remove obsolete .gitmodules files
find "$ARCH_DIR/src/main/resources/archetype-resources"                                                       \
     -type f -name '.gitmodules'                                                                              |
     xargs rm -f
# remove obsolete .iml files
find "$ARCH_DIR/src/main/resources/archetype-resources"                                                       \
     -type f -name '*.iml'                                                                                    |
     xargs rm -f
# remove obsolete config subfolders
find "$ARCH_DIR/src/main/resources/archetype-resources/__rootArtifactId__-bundle/src/main/resources/config"   \
     -type d                                                                                                  |
     xargs rm -Rf
find "$ARCH_DIR/target/test-classes/projects/basic/project/basic/basic-bundle/src/main/resources/config/"     \
     -type d                                                                                                  |
     xargs rm -Rf

# remove the corresponding lines in the archetype-metadata.xml
cp "$ARCH_DIR/src/main/resources/META-INF/maven/archetype-metadata.xml" "$TEMP_DIR/."
sed  -i '/archetype.sh/d' "$TEMP_DIR/archetype-metadata.xml"
sed  -i '/.gitmodules/d'  "$TEMP_DIR/archetype-metadata.xml"
sed  -i '/.iml/d'         "$TEMP_DIR/archetype-metadata.xml"
cp "$TEMP_DIR/archetype-metadata.xml" "$ARCH_DIR/src/main/resources/META-INF/maven/."

# fix encoding in generated root pom.xml
cp "$ARCH_DIR/pom.xml" "$TEMP_DIR/."
sed -i '/<name>peel-bootstrap-bundle<\/name>/ a\
\
  <properties>\
    <project.build.sourceEncoding>UTF-8<\/project.build.sourceEncoding>\
  <\/properties>' "$TEMP_DIR/pom.xml"
cp "$TEMP_DIR/pom.xml" "$ARCH_DIR/."

# install the archetype
cd "$ARCH_DIR"
mvn install
cd "$CURR_DIR"