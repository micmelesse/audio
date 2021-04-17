pip3 install --user --progress-bar off jinja2 pyyaml
python3 .circleci/regenerate.py
# git diff --exit-code || (echo ".circleci/config.yml not in sync with config.yml.in! Run .circleci/regenerate.py to update config"; exit 1)