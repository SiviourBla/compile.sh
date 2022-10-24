# compile.sh

A simple bash script that compiles and launches simple C programs.
### ![!](https://via.placeholder.com/15/ff1111/ff1111.png) **This script has been written and tested on macOS only and thus is likely to break on other operating systems.**

## Usage
	compile.sh [options...] -- [executable arguments...]

## Options

 - `-c`, `--cl-pre`
	 - Clear the console immediately
 - `-C`, `--cl-pst`
	 - Clear the console after compiling
<br>

 - `-r`, `--re-inf`
	 - Print the contents of the input file after compiling
 - `-R`,` --re-xout`
	 - Print the contents of the executable's outputted file after it has finished running
<br>

 - `-s`, `--sk-exc`
	 - Don't compile if the executable already exists
 - `-d`, `--rm-exc`
	 - Delete the executable first if it already exists
 - `-D`, `--rm-xout`
	 - Delete the executable's outputted file after it has finished running
 - `-i`, `--rp-inf`
	 - Overwrite the input file
<br>

 - `--`
	 - Redirect everyting after into the executable's arguments
 - `-h`, `--help`
	 - Print the help page and exit
 - `-H`, `--help-examples`
	 - Print examples and exit
 - `--version`
	 - Print the version and exit

## Examples

 - `compile.sh --`
	 - Compiles, overwriting the executable if the file already exists
	 - Generates new input files if they are missing and input files are enabled in the config
	 - The executable is launched without any arguments

 - `compile.sh -- arg1 arg2 arg3`
	 - Compiles, overwriting the executable if the file already exists
	 - Generates new input files if they are missing and input files are enabled in the config
	 - The executable is launched with the arguments 'arg1', 'arg2' and 'arg3'

 - `compile.sh -i -- arg1 arg2 arg3`
	 - Compiles, overwriting the executable if the file already exists
	 - Generates new input files, overwriting any that already exist if input files are enabled in the config
	 - The executable is launched with the arguments 'arg1', 'arg2' and 'arg3'

 - `compile.sh -z -- arg1 arg2 arg3`
	 - Throws an error as -z isn't a valid option

 - `compile.sh -- -z arg1 arg2 arg3`
	 - Compiles, overwriting the executable if the file already exists
	 - Generates new input files if they are missing and input files are enabled in the config
	 - The executable is launched with the arguments '-z', 'arg1', 'arg2' and 'arg3'

 - `compile.sh -icsCR -- -h arg1 arg2 arg3`
	 - Clears the console
	 - Skips compilation the executable already exists
	 - Generates new input files, overwriting any that already exist if input files are enabled in the config
	 - Clears the console again
	 - The executable is launched with the arguments '-h', 'arg1', 'arg2' and 'arg3'
	 - After the executable has stopped running, print the contents of the executable's outputted file if it exists

 - `compile.sh -h`
	 - Print the help menu

 - `compile.sh -H`
	 - Print this list of examples

## Configuration

The configuration values are stored in `compile.shcfg`.

If `compile.sh` is renamed, `compile.shcfg` will also have to be renamed.

Example values:

 - `SourceFolder="./ExampleSource"`
	 - Path of the source folder, can be relative to `compile.sh`
 - `ReturnPath="../"`
	 - Path of the outputted executable's folder, can be relative to the `SourceFolder`
 - `ExecName="ExampleExec"`
	 - Name of the outputted executable
 - `MaxDepth="1"`
	 - Value inputted to `find`'s 'maxdepth' option
	 - Increasing or decreasing this value can allow/prevent different *.c files from being used
	 - A value of '1' will make it use each file in `SourceFolder` without traversing any deeper
<br>

 - `HasInputFile="N"`
	 - If set to 'Y', `InputCommand` will be run and the output will be saved to `InputFile`
 - `InputCommand="echo"`
	 - The command used to generate an input file
 - `InputFile="./input.txt"`
	 - Path of the input file, can be relative to `ReturnPath`
<br>

 - `ExecOutputFile="./output.txt"`
	 - Path of the executable's outputted file, can be relative to `ReturnPath`

## Additional Configuration

If the file `compile.shvpath` exists the script will read the contents of the file and won't run if it is not a path to a file containing the string 'CanCompile'.

As with `compile.shcfg`, if `compile.sh` is renamed, `compile.shvpath` will also have to be renamed.

This can be useful in situations where you don't want to accidentally run this script on another device.
