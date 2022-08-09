default:
    just --list

# https://github.com/rnorth/gh-combine-prs
# use combine-prs extension to bump all requirements files
dependabot:
    gh combine-prs --query "author:app/dependabot"

# set up virtual environment in working directory
bootstrap:
    if test ! -e .venv; then python  -m venv  {{invocation_directory()}}/.venv; fi
    python  -m pip install --upgrade pip wheel setuptools

# remove virtual environment from working directory
clean:
    rm -rf {{invocation_directory()}}/.venv