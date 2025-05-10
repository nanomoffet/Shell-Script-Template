# Shell Script Template

This repository provides a template for creating new Bash scripts. It includes common best practices, argument parsing, dependency checking, and examples for using `gh` (GitHub CLI), `jq` (JSON processor), `gum` (for glamorous shell interactions), and other standard Linux command-line utilities.

## Features

* **Strict Mode**: `set -eou pipefail` for robust error handling.
* **Structured Layout**: Clear separation of configuration, functions, and main logic.
* **Dependency Checking**: Ensures required tools are installed.
* **Argument Parsing**: Example using `getopts`-style loop for flags and options.
* **Logging Function**: `gum` styled `INFO`, `ERROR`, `WARN`, `DEBUG`, `SUCCESS` messages.
* **Usage/Help Function**: Automatically generated help message.
* **Tool Integration Examples**:
  * **`gh`**: Authenticating (checking status) and fetching data from GitHub API.
  * **`jq`**: Parsing JSON responses from `gh` or other sources.
  * **`gum`**:
    * `gum input`: For text input.
    * `gum choose`: For selecting from a list.
    * `gum confirm`: For yes/no prompts.
    * `gum spin`: For showing activity during long tasks.
    * `gum style`: For formatted and colored output.
    * `gum table`: For displaying data in tables.
  * **Common Linux Utilities**: `date`, `mkdir`, `curl`, `grep`, `head`, etc.

## Requirements

* **Bash**: Version 4.0 or higher recommended.
* **`gh`**: [GitHub CLI](https://cli.github.com/).
* **`jq`**: [JSON processor](https://stedolan.github.io/jq/).
* **`gum`**: [Glamorous shell tool](https://github.com/charmbracelet/gum).
* **Coreutils**: Standard Linux utilities like `date`, `grep`, `mkdir`, `curl`, etc. (usually pre-installed).

## Setup

1. **Install Dependencies**:
    Ensure all tools listed under "Requirements" are installed on your system.
    * `gh`: Follow instructions at [cli.github.com](https://cli.github.com/)
    * `jq`: e.g., `sudo apt-get install jq` or `brew install jq`
    * `gum`: Follow instructions at [github.com/charmbracelet/gum](https://github.com/charmbracelet/gum)

2. **Make Script Executable**:

    ```bash
    chmod +x script_template.sh
    ```

3. **(Optional) Authenticate GitHub CLI**:
    For `gh` commands that require authentication:

    ```bash
    gh auth login
    ```

## Usage

The template script can be run with various options:

```bash
./script_template.sh [OPTIONS] [ARGUMENTS...]
Options:

-h, --help: Show the help message and exit.
-v, --verbose: Enable verbose/debug output.
-f, --file <path>: Specify an input file for processing.
-o, --output <dir>: Specify an output directory (default: current directory).
Arguments:

arg1 arg2 ...: Positional arguments that the script can use.
Examples:

Show help:
bash
./script_template.sh --help
Run with verbose mode, an input file, a custom output directory, and positional arguments:
bash
./script_template.sh -v -f mydata.txt -o ./processed_results itemA itemB
Run with minimal options:
bash
./script_template.sh
Customizing the Template

Update Header: Change Script Name, Description, Author, Date, and Usage in the script's header comments.
Modify Script Variables: Adjust default values for INPUT_FILE, OUTPUT_DIR, or add new global configuration variables.
Adapt Argument Parsing:
Modify the process_arguments function to handle new options or change existing ones.
Update the usage function to reflect these changes.
Implement Core Logic: Replace the example sections within the main() function with your script's specific functionality.
Add/Remove Functions: Create new helper functions or remove unused ones to keep the script organized.
Adjust Dependencies: Update the check_dependencies call if your script requires different tools.
License

This project is licensed under the MIT License - see the LICENSE file for details

