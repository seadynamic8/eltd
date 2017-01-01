# Eltd

Command-line utilities to manage concurrent app workflows.

Currently 2 functions:
* Checkout (or create) branch concurrently across apps (safely)
* Execute command concurrently across apps

What does safely mean?
- Checkout
  * First checks status, if clean, checkout or create/checkout branch
  * if staged changes, ask if you want to commit with 'temp commit' message and
    then continue checkout or create/checkout branch
  * if unstaged changes, ask you want to save changes and commit with 'temp commit'
    message and then continue checkout or create/checkout branch
  * if there are changes, if you don't want to commit, will stop there.

## Installation

  Prerequiste: Erlang and mix (optional) have to be installed.

  1. Run escript install:

  ```
  mix escript.install
  ```

  2. Append "/Users/jkwan/.mix/escripts" to your PATH

  3. Run the program

  ```
  eltd
  ```

  OR

  Just run it (with Erlang installed)

  ```
  ./eltd
  ```

## Usage

  ```
  usage: eltd [checkout | co] <branch>           # Checkout branch concurrently across apps
         eltd [execute | ex] "<command string>"  # Execute command concurrently across apps
  example: eltd -a w ex "git ci -am 'temp commit'"

  Options:
  --apps or -a
    <comma seperated apps>  # List of comma seperated apps.  Ex: admin,client,provider
                            # Abbreviations: a = admin, c = client, cc = callcenter
                            # Example: -a a,p,m
  ```

Shorthand for apps:

  ```
  "tc"   -> "teladoc_constants_gem"
  "tf"   -> "teladoc_framework"
  "t"    -> "tas"
  "p"    -> "provider"
  "a"    -> "admin"
  "m"    -> "member"
  "c"    -> "client"
  "cc"   -> "callcenter"
  "ma"   -> "mobile_api"
  "o"    -> "oms"
  "k"    -> "kronos"
  "w"    -> ["provider", "admin", "member", "client"]  # Web
  "wtf"  -> ["provider", "admin", "member", "client", "teladoc_framework"] # Web with teladoc_framework
  "tcao" -> ["teladoc_constants_gem", "teladoc_framework", "tas", "callcenter", "mobile_api"] # teladoc_constants_gem apps only
  ```
### Defaults

```
default_apps: ["teladoc_framework", "provider", "admin", "member", "client"]

commit_message: "temp commit"  # For checkout command
```

### Configuration file:

Optional configuration file can be created in ~/.mix/escripts/

Need to call it config.exs and use Mix.Config format

Example file:
```
use Mix.Config  # Need to add this

config :eltd, default_apps: ["member", "client"]

config :eltd, commit_message: "a new commit message"  # For checkout command

config :eltd, top_level_directory: "~/Code/Teladoc/"  # Setting this allows you to run
                                                      # the program from another directory.
                                                      # Helpful for quick testing.
```

Note: If you want to change the configuration file name or location,
do so in config/config.exs, and then you will need to recompile

### Recompile procedure:

1. Make changes
2. Run
```
mix do escript.build, escript.install
```
If you want to only a local instance of the program
```
mix escript.build
```
