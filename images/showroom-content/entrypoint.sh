#!/bin/bash

if [ -z "$GIT_REPO_URL" ]; then
  echo "GIT_REPO_URL is not set. Exiting."
  exit 1
fi

if [ -z "$ANTORA_PLAYBOOK" ]; then
  echo "ANTORA_PLAYBOOK not defined.  Falling back to ANTORA_PLAYBOOK=default-site.yml"
  ANTORA_PLAYBOOK="default-site.yml"
fi


WORKDIR=/showroom/repo/
test -d $WORKDIR && rm -rfv ${WORKDIR}

echo
echo "git clone the $GIT_REPO_URL into $WORKDIR"
git clone $GIT_REPO_URL $WORKDIR
cd $WORKDIR

echo
echo "Original user_data in content/antora.yml"
cat $WORKDIR/content/antora.yml

if [ -z "$USER_DATA_FILE" ]; then
  echo
  echo "USER_DATA_FILE not defined.  Falling back to USER_DATA_FILE=/user_data/user_data.yml"
  USER_DATA_FILE="/user_data/user_data.yml"
fi

if test -r ${USER_DATA_FILE}
then
  echo
  echo "Merging ${USER_DATA_FILE} and antora.yml"}
  yq -i ".asciidoc.attributes *= load(\"${USER_DATA_FILE}\")" $WORKDIR/content/antora.yml
  echo "new user_data in content/antora.yml"
else
  echo
  echo "USER_DATA_FILE: ${USER_DATA_FILE} not found."
  exit 1
fi
cat $WORKDIR/content/antora.yml
echo

WWW_ROOT=/showroom/www/
test -d $WWW_ROOT || mkdir $WWW_ROOT

echo
echo "Antora version"
antora --version

# Run antora command (adjust the playbook file as needed)
echo
echo "Run antora $ANTORA_PLAYBOOK"



antora --to-dir=$WWW_ROOT $ANTORA_PLAYBOOK

echo
echo "Run httpd"
cd $WWW_ROOT
python3 -m http.server

# Additional commands or logic can be added here if needed
