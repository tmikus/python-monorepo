## Prerequisites

- [Direnv](https://direnv.net/)
- [Python 3.x](https://www.python.org/downloads/)

## Packages

Each package should be structured like this:
```text
python-monorepo
|-- .envrc                    # Contains a configuration for venv
|-- .gitignore                # Ignore the .direnv, Intellij, vs-code and build outputs
|-- requirements.txt          # Dependencies needed for local development
|-- myPackage1
|   |-- pyproject.toml        # Boilerplate for setuptools
|   |-- setup.cfg             # Contains package configuration: dependencies, name, author
|   |-- src
|       |-- __init__.py       # empty file
|       |-- myPackage1        # Note that the name matches the parent folder name
|           |-- __init__.py   # empty file
|           |-- file1.py
|-- myPackage2
    |-- pyproject.toml        # Boilerplate for setuptools
    |-- setup.cfg             # Contains package configuration: dependencies, name, author
    |-- src
        |-- __init__.py       # empty file
        |-- myPackage1        # Note that the name matches the parent folder name
            |-- __init__.py   # empty file
            |-- file1.py
```

## Steps

### .envrc

In your project create a `.envrc` file with the following content:
```
layout python3
```

Navigate your terminal to the root directory of the project.
By default, `direnv` is forbidden from executing the `.envrc` files, so you'll be greeted with the following error:

![direnv: error python-monorepo/.envrc is blocked. Run `direnv allow` to approve its content](./images/before_direnv_allow.png)

The first time you use the repository on your device you'll have to allow `direnv` to use that `.envrc` file.
To do that simply run the following command in the root of your project:

```shell
direnv allow .
```

Once you do this you should be greeted with the following log:

![direnv: loading python-monorepo/.envrc
direnv: export +VIRTUAL_ENV ~PATH](./images/after_direnv_allow.png)


### requirements.txt

This file should list all the dependencies required by your project to run locally, as well as a list of all the packages
belonging to the monorepo.
The packages that belong to the monorepo should be installed as editable dependencies:

```text
# Dependencies
returns >= 0.19.0

# Dev Dependencies
pytest >= 7.2.1

# Monorepo packages
-e api      # Corresponds to the api folder
-e utils    # Corresponds to the utils folder
```

