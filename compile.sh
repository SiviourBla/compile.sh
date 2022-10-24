#!/usr/bin/env bash
#---------
# Encoding: UTF-8
# License: MIT
# Original Author: Blake Siviour
# Year: 2022
# Project: compile.sh
# Project Summary: A simple bash script that compiles and launches simple C programs.
# Project Repo: https://github.com/SiviourBla/compile.sh
# File Summary: Main script, does everything except store configuration.
#---------

Command="$(basename "$0")"
Version="1.1.4"
DisplayVersionText="$Command v$Version"
#SC: Set colour ID e.g "$(${SC} 2)"
SC="tput setaf"
FadedText="$(${SC} 8)"
#Clear colour
CF="$(tput sgr0)"

#Check if running on mac
if [[ "$(uname)" != "Darwin" ]]
then
	echo "Warning: this script has only been tested on macOS!"
fi

#Check if getoptions is installed
if [[ "$(which getoptions)" == "" ]]
then
	echo "$(${SC} 1)Warning: getoptions does not appear to be installed!"
	echo "This script will likely fail to run."
	echo "getoptions can be downloaded at:${CF} https://github.com/ko1nksm/getoptions/"
fi

#Define options
parser_definition() {
	setup   REST help:usage -- \
		"${2##*/} v$Version

Usage:
	${2##*/} [options...] -- [executable arguments...]" ''
	msg -- 'Options:'
	flag    F_ClearPre          -c  --cl-pre        -- "Clear the console immediately"
	flag    F_ClearPost         -C  --cl-pst        -- "Clear the console after compiling"
	msg -- ''
	flag    F_ReadInFile        -r  --re-inf        -- "Print the contents of the input file after compiling"
	flag    F_ReadExecOutFile   -R  --re-xout       -- "Print the contents of the executable's outputted file after it has finished running"
	msg -- ''
	flag    F_KeepExecFile      -s  --sk-exc        -- "Don't compile if the executable already exists"
	flag    F_DeleteExecFile    -d  --rm-exc        -- "Delete the executable first if it already exists"
	flag    F_DeleteExecOutFile -D  --rm-xout       -- "Delete the executable's outputted file after it has finished running"
	flag    F_ReplaceInFile     -i  --rp-inf        -- "Overwrite the input file"
	msg -- ''
	msg -- "      --                      Redirect everyting after into the executable's arguments"
	disp    :usage              -h  --help          -- "Display this help page and exit"
	flag    F_EgText            -H  --help-examples -- "Display examples and exit"
	disp    DisplayVersionText  --version           -- "Print the version and exit"
	msg -- ''
}

#https://stackoverflow.com/a/41555511
#CommandLine1Line2Line3...
	#Formatting "$(${SC} ID)TEXT${CF}"
	#Used https://unix.stackexchange.com/a/269085 to get IDs
ExamplesText=(
	"$Command --Compiles, overwriting the executable if the file already existsGenerates new input files if they are missing and input files are enabled in the configThe executable is launched without any arguments"
	"$Command -- arg1 arg2 arg3Compiles, overwriting the executable if the file already existsGenerates new input files if they are missing and input files are enabled in the configThe executable is launched with the arguments 'arg1', 'arg2' and 'arg3'"
	"$Command -$(${SC} 2)i${CF} -- arg1 arg2 arg3Compiles, overwriting the executable if the file already exists$(${SC} 2)Generates new input files, overwriting any that already exist if input files are enabled in the configThe executable is launched with the arguments 'arg1', 'arg2' and 'arg3'"
	"$Command -$(${SC} 2)z${CF} -- arg1 arg2 arg3$(${SC} 2)Throws an error as -z isn't an option"
	"$Command -- -z arg1 arg2 arg3Compiles, overwriting the executable if the file already existsGenerates new input files if they are missing and input files are enabled in the configThe executable is launched with the arguments '-z', 'arg1', 'arg2' and 'arg3'"
	"$Command -$(${SC} 2)i${CF}$(${SC} 3)c${CF}$(${SC} 4)s${CF}$(${SC} 5)C${CF}$(${SC} 6)R${CF} -- -h arg1 arg2 arg3$(${SC} 3)Clears the console$(${SC} 4)Skips compilation the executable already exists$(${SC} 2)Generates new input files, overwriting any that already exist if input files are enabled in the config$(${SC} 5)Clears the console againThe executable is launched with the arguments '-h', 'arg1', 'arg2' and 'arg3'$(${SC} 6)After the executable has stopped running, print the contents of the executable's outputted file if it exists"
	"$Command -$(${SC} 2)h$(${SC} 2)Print the help menu"
	"$Command -$(${SC} 2)H$(${SC} 2)Print this list of examples"
	#""
)

#To reduce confusion, remove all executable args before "--"
RemainingSearchArgCount="$#"
CurrentSearchArgIndex="1"
FoundInvalidBefore="N"
while [[ $RemainingSearchArgCount != 0 ]]
do
	if [[ "${!CurrentSearchArgIndex}" == "--" ]]
	then
		RemainingSearchArgCount=1;
	elif [[ "${!CurrentSearchArgIndex}" != "-"* ]]
	then
		if [[ "$FoundInvalidBefore" == "N" ]]
		then
			FoundInvalidBefore="Y"
			printf "$(${SC} 3)Warning: argument(s) \"${!CurrentSearchArgIndex}\""
		else
			printf ", \"${!CurrentSearchArgIndex}\""
		fi
		set -- "${@:1:CurrentSearchArgIndex-1}" "${@:CurrentSearchArgIndex+1}"
	else
		CurrentSearchArgIndex=$(($CurrentSearchArgIndex+1))
	fi
	RemainingSearchArgCount=$(($RemainingSearchArgCount-1))
done
if [[ "$FoundInvalidBefore" != "N" ]]
then
	echo " were entered before \"--\" and thus aren't being passed to the executable.${CF}"
fi

#Parse options
RawArgCount="$#"
eval "$(getoptions parser_definition - "$0") exit 1"

#If no options
if [[ $RawArgCount == 0 ]]
then
	usage
	echo "$(${SC} 3)----------
To run this script without any args, use:
	$Command --${CF}"
#Display examples
elif [[ $F_EgText ]]
then
	usage
	echo "Examples: "
	for ExampleRawIndex in "${!ExamplesText[@]}"
	do
		ExampleRaw="${ExamplesText[$ExampleRawIndex]}"
		OldIFS="$IFS"
		export IFS=""
		read -ra Lines <<< "$ExampleRaw"
		IsCommand="Y"
		for Line in "${Lines[@]}"
		do
			if [[ "$IsCommand" == "Y" ]]
			then
				IsCommand="N"
				echo "	$Line$CF"
			else
				echo "		$Line$CF"
			fi
		done
		echo ""
		export IFS="$OldIFS"
	done
#Can be used if you don't want to risk running the script accidentally on another device
elif [[ ! -f "${0}vpath" || "$(cat $(cat "${0}vpath"))" == "CanCompile" ]]
then
	# -c/--cl-pre
	if [[ $F_ClearPre ]]
	then
		clear
		#For some reason clear does not actually clear the terminal in monterey and instead just prints a bunch of newlines.
		#So I am using a workaround below (https://apple.stackexchange.com/a/318217)
		printf '\e[2J\e[3J\e[H'
	fi
	
	#Setup (Could have done it earlier, but then the clear option would hide errors)
	cd "$(dirname "$0")"
	if [ ! -f "./${Command}cfg" ]
	then
		echo "$(${SC} 1)Config missing, stopping!"
		echo "Documentation can be found at:${CF} https://github.com/SiviourBla/compile.sh#Configuration"
		exit 1
	fi
	source ./${Command}cfg
	
	#Exec exists and -d/--rm-exc
	if [[ -f "./$ExecName" && $F_DeleteExecFile ]]
	then
		rm "./$ExecName"
	fi
	
	#Exec does not exist or no -s/--sk-exc
	if [[ ! -f "./$ExecName" || ! $F_KeepExecFile ]]
	then
		cd "$SourceFolder"
		Files="$(find . -maxdepth $MaxDepth -iname "*.c")"
		gcc $Files -o "$ReturnPath/$ExecName"
		cd "$ReturnPath"
	fi
	
	#Input file should exist and (the file is missing or -i/--rp-inf)
	if [[ "$HasInputFile" == "Y" && ( ! -f "$InputFile" || $F_ReplaceInFile ) ]]
	then
		"$InputCommand" > "$InputFile"
	fi
	
	#Input file exists and -r/--re-inf
	if [[ $F_ReadInFile && -f "$InputFile" ]] 
	then
		echo "----------Input----------"
		cat "$InputFile"
		echo "-------------------------"
	fi
	
	#-C	--cl-pst
	if [[ $F_ClearPost ]]
	then
		clear
		#For some reason clear does not actually clear the terminal in monterey and instead just prints a bunch of newlines.
		#So I am using a workaround below (https://apple.stackexchange.com/a/318217)
		printf '\e[2J\e[3J\e[H'
	fi
	
	#Run the executable
	"./$ExecName" "$@"
	
	#Output file exists and -R/--re-xout
	if [[  $F_ReadExecOutFile && -f "$ExecOutputFile" ]] 
	then
		echo "----------Output----------"
		cat "$ExecOutputFile"
		echo "--------------------------"
	fi
	
	#Output file exists and -D/--rm-xout
	if [[ $F_DeleteExecOutFile && -f "$ExecOutputFile" ]] 
	then
		rm "$ExecOutputFile"
	fi
else
	echo "To reduce the risk of accidental damage and/or confusion, this script won't run on another computer without a specific file."
	echo "For more info, refer to: https://github.com/SiviourBla/compile.sh#Additional-Configuration"
fi