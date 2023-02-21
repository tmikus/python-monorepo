## Introduction

This blog posts describes my take on how to create a Python monorepo using native Python tools and [direnv](https://direnv.net/).

The project created this way is much easier to use than using dedicated tools like [Poetry](https://python-poetry.org/) or [Bazel](https://bazel.build/) as it doesn't require any esoteric knowledge on how to best use these tools.

## Prerequisites

- [Direnv](https://direnv.net/)
- [Python 3.x](https://www.python.org/downloads/)

**Python packages (for building the .whl files)**
- [build (pypi)](https://pypi.org/project/build/)
- [setuptools (pypi)](https://pypi.org/project/setuptools/)
- [setuptools-scm (pypi)](https://pypi.org/project/setuptools-scm/)
- [wheel (pypi)](https://pypi.org/project/wheel/)

## Why direnv?

I've been using [direnv](https://direnv.net/) for a while now and I've found it to be a very useful tool. It allows you to configure your environment based on the current directory. This is very useful when working with monorepos as you can have different configurations for different projects.

In our case we will use it to automatically create and set the Python virtual environment for the project whenever we enter the project directory in the terminal. We'll also use this Python virtual environment to provide the Python interpreter for the IDE.

## Project structure

Each package should be structured like this:
```text
python-monorepo               # The root of the project (the name of the folder doesn't matter)
|-- .envrc                    # Contains a configuration for direnv
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

## Creating .envrc

In your project create a `.envrc` file with the following content:
```text
layout python3
```

This will tell `direnv` to create a Python virtual environment for the project and use it as the default Python interpreter.

By default, `direnv` is forbidden from executing the `.envrc` files, so when you navigate to the root of the project in terminal you'll be greeted with the following error:

![direnv: error python-monorepo/.envrc is blocked. Run `direnv allow` to approve its content](/assets/posts/2023-02-21-python-monorepo/before_direnv_allow.png)

The first time you use the repository on your device you'll have to allow `direnv` to use that `.envrc` file.
To do that simply run the following command in the root of your project:

```shell
direnv allow .
```

Once you do this you should be greeted with the following log:

![direnv: loading python-monorepo/.envrc
direnv: export +VIRTUAL_ENV ~PATH](assets/posts/2023-02-21-python-monorepo/after_direnv_allow.png)


## Creating requirements.txt

This file should list all the dependencies required by your project to run locally, as well as a list of all the packages
belonging to the monorepo.

The packages that belong to the monorepo should be installed as editable dependencies:

```text
# Monorepo packages
-e api      # Corresponds to the api folder
-e utils    # Corresponds to the utils folder

# Dependencies
# returns >= 0.19.0

# Dev Dependencies
# pytest >= 7.2.1

# Build dependencies that are needed to build this project
build
setuptools
setuptools-scm
wheel
```

The `requirements.txt` file won't be used in production as the runtime dependencies of each package will be specified in the `setup.cfg` file for each package.

## Creating packages

To create a new package, simply create a new folder in the root of the project with the name of the package and the following directory structure:

```text
myPackage
|-- pyproject.toml        # Boilerplate for setuptools
|-- setup.cfg             # Contains package configuration: dependencies, name, author
|-- src
    |-- __init__.py       # empty file
    |-- myPackage         # Note that the name matches the parent folder name
        |-- __init__.py   # empty file
        |-- file1.py      # Some file that belongs to the package
```

The `pyproject.toml` file should contain the following content:

```toml
[build-system]
requires = ["setuptools", "setuptools-scm", "wheel"]
build-backend = "setuptools.build_meta"
```

The `setup.cfg` file should contain the following content:

```ini
[metadata]
name = myPackage    # Change this to whatever you want
version = 1.0.0

[options]
package_dir =
    = src
packages = find:
python_requires = >=3.9
include_package_data = true
zip_safe = true
install_requires =
    # List runtime dependencies in the same format as in the requirements.txt file

[options.extras_require]
# List of optional runtime dependencies

[options.packages.find]
where = src

[options.package_data]
# * = **/*.json, **/*.txt # Uncomment if your package comes with any JSON or TXT files you'd like to bundle
```

Notice the `install_requires` section. This is where you specify the runtime dependencies of the package. The dependencies should be listed in the same format as in the `requirements.txt` file.

## Adding cross-package dependencies

To add a dependency between two packages, simply add the name of the package to the `install_requires` section of the `setup.cfg` file of the package that depends on the other package.

For example, given the project with the packages `utils` and `api`, to add a dependency from `api` to `utils`, simply add the following line to the `setup.cfg` file of the `api` package:

```ini
install_requires =
    # List runtime dependencies in the same format as in the requirements.txt file
    utils
```

## Building the packages

To build a specific package, navigate to the root directory of the package (the directory that contains the `setup.cfg` file) and run the following command:

```shell
python -m build
```

By default, the build command will create a `dist` folder in the root of the package and will place the `.whl` file there.

This command also takes a while to complete as it will create a new isolated virtual environment, and build the package in that isolated environment.

To speed up that build you can run the command without the virtual environment by running the following command:

```shell
python -m build --no-isolation
```

## IntelliJ IDE configuration

To configure the IDE to use the Python virtual environment created by `direnv` you'll have to do the following:

1. Open the project in the IDE
2. Go to `File -> Project Structure...`
3. Expand the `SDK` dropdown, and click `Add new SDK... -> Python SDK`
4. In `Virtualenv environment` select radio button `Existing environment`, and click `...` to the right of the text field
5. Select the Python interpreter from the virtual environment created by `direnv` (it should be in the `.direnv` folder in the root of the project). In my case it's in `/Users/tmikus/projects/python-monorepo/.direnv/python-3.9.6/bin/python`
6. Click `OK`
7. Make sure that this new Python SDK is selected in the `Project SDK` dropdown
8. Click `OK`

## Visual Studio Code configuration

From experience, there's no need for any custom configuration in VS Code. This project setup should simply work out of the box.
