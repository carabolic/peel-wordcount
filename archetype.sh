#!/bin/bash

# common options
TEMP_DIR=$(dirname $(mktemp -u))
CURR_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ARCH_DIR="$CURR_DIR/target/generated-sources/archetype"
ARCH_POM="$ARCH_DIR/pom.xml"
ARCH_MDT="$ARCH_DIR/src/main/resources/META-INF/maven/archetype-metadata.xml"

# create archetype from a specific branch
function create_archetype {
    ARCHID=$1
    TARGET=$2
    # 1) create the archetype
    echo "GENERATING ARCHETYPE FROM CURRENT BRANCH"
    mvn archetype:create-from-project                                                                            \
        -Darchetype.properties=./archetype.properties                                                            \
        -Darchetype.artifactId="$ARCHID"

    # 2) fix the archetype file structure
    echo "FIXING FILES IN GENERATED ARCHETYPE"
    # copy explicitly the .gitignore file
    cp ./.gitignore "$ARCH_DIR/src/main/resources/archetype-resources/.gitignore"
    # remove the copy of this shell script in the archetype folder
    find "$ARCH_DIR/src/main/resources/archetype-resources"                                                      \
         -type f -name 'archetype.sh'                                                                            |
         xargs rm -Rf
    # remove obsolete .gitmodules files
    find "$ARCH_DIR/src/main/resources/archetype-resources"                                                      \
         -type f -name '.gitmodules'                                                                             |
         xargs rm -f
    # remove obsolete .iml files
    find "$ARCH_DIR/src/main/resources/archetype-resources"                                                      \
         -type f -name '*.iml'                                                                                   |
         xargs rm -f
    # remove obsolete config subfolders
    find "$ARCH_DIR/src/main/resources/archetype-resources/__rootArtifactId__-bundle/src/main/resources/config"  \
         -mindepth 1 -type d                                                                                     |
         xargs rm -Rf

    # 3) fix the generated archetype-metadata.xml
    echo "FIXING GENERATED 'archetype-metadata.xml'"
    xmlstarlet ed -L -d '//_:include[contains(text(),"archetype.sh")]'                                   $ARCH_MDT
    xmlstarlet ed -L -d '//_:include[contains(text(),".gitmodules")]'                                    $ARCH_MDT
    xmlstarlet ed -L -d '//_:include[contains(text(),".iml")]'                                           $ARCH_MDT
    xmlstarlet ed -L -d '//_:modules//_:includes[not(normalize-space())]'                                $ARCH_MDT
    xmlstarlet ed -L -d '//_:modules//_:directory[not(normalize-space())]'                               $ARCH_MDT
    xmlstarlet ed -L -d '//_:modules//_:fileSet[not(normalize-space())]'                                 $ARCH_MDT

    # 3) fix the generated root pom.xml
    echo "FIXING GENERATED 'pom.xml'"
    xmlstarlet ed -L -i '/_:project/_:name'       -t elem -n properties -v ""                            $ARCH_POM
    xmlstarlet ed -L -s '/_:project/_:properties' -t elem -n project.build.sourceEncoding -v "UTF-8"     $ARCH_POM

    # 5) install the archetype
    echo "COPYING ARCHETYPE TO ROOT PACKAGE"
    rm -R "$TARGET/peel-archetypes/$ARCHID/src"
    cp -R "$ARCH_DIR/src" "$TARGET/peel-archetypes/$ARCHID/."
}

# validate input arguments
if [[ "$#" -lt 2 ]];
    then echo "usage: ./archetype.sh <path_to_peel_src> <arch_branch_1> [<arch_branch_2> ...]"
    exit -1
fi

CUR_BRANCH=$(git rev-parse --abbrev-ref HEAD)

TARGET="$1"
for ARCHID in ${*:2}; do
    if [[ `git branch --list "$ARCHID" | wc -l` -eq "1" ]]; then
        echo "PROCESSING BRANCH '$ARCHID'."
        git checkout "$ARCHID"
        create_archetype "$ARCHID" "$TARGET"
    else
        echo "SKIPPING BRANCH '$ARCHID' (DOES NOT EXIST)."
    fi
done
