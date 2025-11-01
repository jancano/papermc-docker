#!/usr/bin/env sh

# Enter server directory
cd papermc

# Set nullstrings back to 'latest'
: ${MC_VERSION:='latest'}
: ${PAPER_BUILD:='latest'}

PROJECT="paper"

# Lowercase these to avoid 404 errors on wget
MC_VERSION="${MC_VERSION,,}"
PAPER_BUILD="${PAPER_BUILD,,}"

VERSION_CHECK=$(curl -s https://fill.papermc.io/v3/projects/${PROJECT}/versions/${MC_VERSION}/builds)

# Check if the API returned an error
if echo "$VERSION_CHECK" | jq -e '.ok == false' > /dev/null 2>&1; then
  ERROR_MSG=$(echo "$VERSION_CHECK" | jq -r '.message // "Unknown error"')
  echo "Error: $ERROR_MSG"
  exit 1
fi

JAR_NAME="paper-${MC_VERSION}-${PAPER_BUILD}.jar"
# Get the download URL directly, or null if no stable build exists
PAPERMC_URL=$(curl -s https://fill.papermc.io/v3/projects/${PROJECT}/versions/${MC_VERSION}/builds | \
  jq -r '(first(.[] | select(.channel == "STABLE")) // first(.[] | select(.channel == "BETA")) | .downloads."server:default".url) // "null"')

if [ "$PAPERMC_URL" != "null" ]; then
  # Download the latest Paper version
  if [ ! -e "$JAR_NAME" ]
  then
    # Remove old server jar(s)
    rm -f *.jar
    # Download new server jar
    curl -o "$JAR_NAME" $PAPERMC_URL
  fi
  echo "Download completed"
else
  echo "No stable build for version $MC_VERSION found :("
fi

# Update eula.txt with current setting
echo "eula=${EULA:-false}" > eula.txt

# Add RAM options to Java options if necessary
if [ -n "$MC_RAM" ]
then
  JAVA_OPTS="-Xms${MC_RAM} -Xmx${MC_RAM} $JAVA_OPTS"
fi

# Start server
exec java -server $JAVA_OPTS -jar "$JAR_NAME" nogui
