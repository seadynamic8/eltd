# Eltd

Command-line ultilities to manage concurrent app workflows.

## Installation

  Prerequiste: Erlang and mix (optional) have to be installed.

  1. Run escript install:

    ```
    mix escript.install
    ```

  2. Append "/Users/jkwan/.mix/escripts" to your PATH

  3. Run the program


     eltd

  OR

  1. Just run it

    ./eltd

## Usage

  ```
  usage: eltd [checkout | co] <branch>            # Checkout branch concurrently
         eltd [execute | e] "<command string>"    # Run any command concurrently
  ```
