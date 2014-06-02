# Groom your app’s Cloud Foundry environment with `cfenv`.
[![Build Status](https://travis-ci.org/nebhale/cfenv.svg?branch=master)](https://travis-ci.org/nebhale/cfenv)

Use `cfenv` to pick a Cloud Foundry environment for your application and reduce the number of logins and targeting that you do.

**Powerful in development.** Specify your app's Cloud Foundry environment once, in a single file.  Changing directrories changes your Cloud Foundry environment.

**One thing well.** `cfenv` is concerned solely with switching Cloud Foundry environments. It's simple and predictable. A plugin architecture lets you tailor it to suit your needs.

### Special Thanks
Without [`rbenv`](https://github.com/sstephenson/rbenv) this project would not exist.  `rbenv` provided to be amazingly high quality and amenable to the modifications that make `cfenv` possible.  I cannot recommend `rbenv` enough if you're a Ruby developer and it's a model for a well written project for everyone else.  Finally, thanks to Dan Mikusa for the [inspiration](https://groups.google.com/a/cloudfoundry.org/d/msg/vcap-dev/Hy1WEJ452Xc/EGudP63gIfgJ) to create this project.

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Cloud Foundry Environment](#choosing-the-cloud-foundry-environment)
  * [Locating the Cloud Foundry Environment](#locating-the-cloud-foundry-environment)
* [Installation](#installation)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
  * [Homebrew on Mac OS X](#homebrew-on-mac-os-x)
  * [How cfenv hooks into your shell](#how-cfenv-hooks-into-your-shell)
  * [Creating Cloud Foundry Environments](#creating-cloudfoundry-environments)
  * [Destroying Cloud Foundry Environments](#destroying-cloudfoundry-environments)
* [Command Reference](#command-reference)
  * [cfenv local](#cfenv-local)
  * [cfenv global](#cfenv-global)
  * [cfenv shell](#cfenv-shell)
  * [cfenv environments](#cfenv-environments)
  * [cfenv environment](#cfenv-environment)
  * [cfenv rehash](#cfenv-rehash)
  * [cfenv which](#cfenv-which)
  * [cfenv whence](#cfenv-whence)
* [Development](#development)
  * [Version History](#version-history)
  * [License](#license)

## How It Works

At a high level, `cfenv` intercepts the `cf` command using a shim executable injected into your `PATH`, determines which Cloud Foundry environment has been specified by your application, and passes your commands along after setting `CF_HOME` to the appropriate location.

### Understanding PATH

When you run a command like `cf`, your operating system searches through a list of directories to find an executable file with that name. This list of directories lives in an environment variable called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching executable in a directory at the beginning of the list takes precedence over another one at the end. In this example, the `/usr/local/bin` directory will be searched first, then `/usr/bin`, then `/bin`.

### Understanding Shims

`cfenv` works by inserting a directory of _shims_ at the front of your `PATH`:

    ~/.cfenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, `cfenv` maintains a `cf` shim in that directory.

The shim is a lightweight executables that simply passes your command along to `cfenv`. So with `cfenv` installed, when you run, `cf`, your operating system will do the following:

* Search your `PATH` for an executable file named `cf`
* Find the `cfenv` shim named `cf` at the beginning of your `PATH`
* Run the shim named `cf`, which in turn passes the command along to `cfenv`

### Choosing the Cloud Foundry Environment

When you execute the shim, `cfenv` determines which Cloud Foundry environment to use by reading it from the following sources, in this order:

1. The `CFENV_ENVIRONMENT` environment variable, if specified. You can use the [`cfenv shell`](#cfenv-shell) command to set this environment variable in your current shell session.

2. The first `.cf-environment` file found by searching the directory of the script you are executing and each of its parent directories until reaching the root of your filesystem.

3. The first `.cf-environment` file found by searching the current working directory and each of its parent directories until reaching the root of your filesystem. You can modify the `.cf-environment` file in the current working directory with the [`cfenv local`](#cfenv-local) command.

4. The global `~/.cfenv/environment` file. You can modify this file using the [`cfenv global`](#cfenv-global) command. If the global environment file is not present, `cfenv` assumes you want to use the "system" Cloud Foundry environment—i.e. whatever environment would be used if `cfenv weren't in your path.

### Locating the Cloud Foundry Environment

Once `cfenv` has determined which Cloud Foundry environment your application has specified, it passes the prepends the corresponding `CF_HOME` environment variable to the command.

Each Cloud Foundry environment is installed into its own directory under `~/.cfenv/environments`. For example, you might have these environments
installed:

* `~/.cfenv/environments/development/`
* `~/.cfenv/environments/testing/`
* `~/.cfenv/environments/production/`

Environment names to `cfenv` are simply the names of the directories in `~/.cfenv/environments`.

## Installation

If you're on Mac OS X, consider [installing with Homebrew](#homebrew-on-mac-os-x).

### Basic GitHub Checkout

This will get you going with the latest version of `cfenv` and make it easy to fork and contribute any changes back upstream.

1. Check out `cfenv` into `~/.cfenv`.

    ```sh
    $ git clone https://github.com/nebhale/cfenv.git ~/.cfenv
    ```

2. Add `~/.cfenv/bin` to your `$PATH` for access to the `cfenv` command-line utility.

    ```sh
    $ echo 'export PATH="$HOME/.cfenv/bin:$PATH"' >> ~/.bash_profile
    ```

    **Ubuntu Desktop note**: Modify your `~/.bashrc` instead of `~/.bash_profile`.

    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.

3. Add `cfenv init` to your shell to enable shims and autocompletion.

    ```sh
    $ echo 'eval "$(cfenv init -)"' >> ~/.bash_profile
    ```

    _Same as in previous step, use `~/.bashrc` on Ubuntu, or `~/.zshrc` for Zsh._

4. Restart your shell so that PATH changes take effect. (Opening a new terminal tab will usually do it.) Now check if `cfenv` was set up:

    ```sh
    $ type cfenv
    #=> "cfenv is a function"
    ```

5. _(Optional)_ Install [cf-build][], which provides the `cfenv create` command that simplifies the process of [creating new Cloud Foundry environments](#creating-cloud-foundry-environments).

#### Upgrading

If you've installed `cfenv` manually using git, you can upgrade your installation to the cutting-edge version at any time.

```sh
$ cd ~/.cfenv
$ git pull
```

To use a specific release of cfenv, check out the corresponding tag:

```sh
$ cd ~/.cfenv
$ git fetch
$ git checkout v0.3.0
```

If you've [installed via Homebrew](#homebrew-on-mac-os-x), then upgrade via its `brew` command:

```sh
$ brew update
$ brew upgrade cfenv cf-build
```

### Homebrew on Mac OS X

As an alternative to installation via GitHub checkout, you can install `cfenv` and [cf-build][] using the [Homebrew](http://brew.sh) package manager on Mac OS X:

```sh
$ brew tap nebhale/personal
$ brew update
$ brew install cfenv cf-build
```

Afterwards you'll still need to add `eval "$(cfenv init -)"` to your profile as stated in the caveats. You'll only ever have to do this once.

### How `cfenv` hooks into your shell

Skip this section unless you must know what every line in your shell profile is doing.

`cfenv init` is the only command that crosses the line of loading extra commands into your shell. Here's what `cfenv init` actually does:

1. Sets up your shims path. This is the only requirement for `cfenv` to function properly. You can do this by hand by prepending `~/.cfenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty useful. Sourcing `~/.cfenv/completions/cfenv.bash` will set that up. There is also a `~/.cfenv/completions/cfenv.zsh` for Zsh users.

3. Rehashes shims. From time to time you'll need to rebuild your shim files. Doing this automatically makes sure everything is up to date. You can always run `cfenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows `cfenv` and plugins to change variables in your current shell, making commands like `cfenv shell` possible. The sh dispatcher doesn't do anything crazy like override `cd` or hack your shell prompt, but if for some reason you need `cfenv` to be a real script rather than a shell function, you can safely skip it.

Run `cfenv init -` for yourself to see exactly what happens under the hood.

### Creating Cloud Foundry Environments

The `cfenv create` command doesn't ship with `cfenv` out of the box, but is provided by the [cf-build][] project. If you installed it either as part of GitHub checkout process outlined above or via Homebrew, you should be able to:

```sh
$ cfenv install development
```

Alternatively to the `create` command, you can create an environment manually as a subdirectory of `~/.cfenv/environments/`. An entry in that directory can also be a symlink to a Cloud Foundry environment installed elsewhere on the filesystem. `cfenv` doesn't care; it will simply treat any entry in the `environments/` directory as a separate Cloud Foundry environment.

### Destroying Cloud Foundry Environments

As time goes on, Cloud Foundry environments  you create will accumulate in your `~/.cfenv/environments` directory.

To remove old Cloud Foundry environments, simply `rm -rf` the directory of the environment you want to remove. You can find the directory of a particular Cloud Foundry environment with the `cfenv prefix` command, e.g. `cfenv prefix development`.

The [cf-build][] plugin provides an `cfenv destroy` command to automate the removal process.

## Command Reference

Like `git`, the `cfenv` command delegates to subcommands based on its first argument. The most common subcommands are:

### `cfenv local`

Sets a local application-specific Cloud Foundry environment by writing the environment name to a `.cf-environment` file in the current directory. This environment overrides the global environment, and can be overridden itself by setting the `CFENV_ENVIRONMENT` environment variable or with the `cfenv shell` command.

    $ cfenv local development

When run without an environment name, `cfenv local` reports the currently configured local environment. You can also unset the local environment:

    $ cfenv local --unset

### `cfenv global`

Sets the global Cloud Foundry environment to be used in all shells by writing the environment name to the `~/.cfenv/environment` file. This environment can be overridden by an application-specific `.cf-environment` file, or by setting the `CFENV_ENVIRONMENT` environment variable.

    $ cfenv global test

The special environment name `system` tells `cfenv` to use the system Cloud Foundry environment.

When run without an environment name, `cfenv global` reports the currently configured global environment.

### `rbenv shell`

Sets a shell-specific Cloud Foundry environment by setting the `CFENV_ENVIRONMENT` environment variable in your shell. This environment overrides application-specific environments and the global environment.

    $ cfenv shell production

When run without an environment name, `cfenv shell` reports the current value of `CFENV_ENVIRONMENT`. You can also unset the shell environment:

    $ cfenv shell --unset

Note that you'll need `rbenv`'s shell integration enabled (step 3 of the installation instructions) in order to use this command. If you prefer not to use shell integration, you may simply set the `CFENV_ENVIRONMENT` variable yourself:

    $ export CFENV_ENVIRONMENT=production

### `rbenv environments`

Lists all Cloud Foundry environments known to `cfenv`, and shows an asterisk next to the currently active environment.

    $ cfenv environments
      development
      test
    * production (set by /Users/bhale/.cfenv/environment)

### `rbenv environment`

Displays the currently active Cloud Foundry environment, along with information on how it was set.

    $ cfenv environment
    production (set by /Users/bhale/dev/sources/nebhale/build-monitor/.cf-environment)

### `cfenv rehash`

Installs the `cf` shim.

    $ cfenv rehash

### `cfenv which`

Displays the full path to the executable that `cfenv` will invoke when you run the given command.

    $ cfenv which cf
    /Users/bhale/.cfenv/environments/test/bin/cf

### `cfenv whence`

Lists all Cloud Foundry environments with the given command installed.

    $ cfenv whence cf
    development
    test
    production

## Development

The `cfenv` source code is [hosted on GitHub](https://github.com/nebhale/cfenv). It's clean, modular, and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue tracker](https://github.com/nebhale/cfenv/issues).

### Version History

**1.0.0** (June 2, 2014)

* Initial public release.

### License

(The MIT license)

Copyright (c) 2013 Ben Hale

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


  [cf-build]: https://github.com/nebhale/cf-build#readme
