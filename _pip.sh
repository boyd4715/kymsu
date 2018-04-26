#!/usr/bin/env bash

# pip plugin for KYMSU
# https://github.com/welcoMattic/kymsu

#version: pip ou pip3
version=pip3
#user: "" or "--user"
user=""
#add module to do_not_update array
declare -a do_not_update=( "tornado")

if ! [ -x "$(command -v $version)" ]; then
  echo "Error: $version is not installed." >&2
  exit 1
fi

echo ""
echo "🐍  Update $version (Python 3)"
echo ""
$version install --upgrade pip
echo ""

pip_outdated=$($version list --outdated --format columns)
upd=$(echo "$pip_outdated" | sed '1,2d' | awk '{print $1}')

if [ -n "$upd" ]; then

	echo -e "\033[4mAvailables updates:\033[0m"
	#echo $pip3_outdated_freeze | tr [:space:] '\n'
	echo "$pip_outdated"
	echo ""
	
	if [ -x "$(command -v pipdeptree)" ]; then
		echo -e "\033[4mCheck dependancies:\033[0m"
		echo "Be carefull!! This updates can be a dependancie for some modules. Check for any incompatible version."
	fi
	echo ""
	for i in $upd
		do
			if [ -x "$(command -v pipdeptree)" ]; then
				dependencies=$(echo "$i" | xargs pipdeptree -r -p | grep "$upd")

				z=0
				while read -r line; do
					if [[ $line = *"<"* ]]; then
						echo -e "\033[31m$line\033[0m"
					else
						if [ "$z" -eq 0 ]; then
							echo -e "\033[3m$line\033[0m"
						else
							echo "$line"
						fi
						z=$((z+1))
					fi
				done <<< "$dependencies"
			fi
			
			# si la m-à-j n'est pas dans le tableau do_not_update, on propose de l'installer
			
			FOUND=`echo ${do_not_update[*]} | grep "$i"`
			if [ "${FOUND}" = "" ]; then
			
				b=$(echo -e "Do you wanna run \033[1m$version install $user --upgrade "$i"\033[0m ? (y/n)")
  				read -p "$b" choice
  				case "$choice" in
    				y|Y|o ) echo $i | xargs $version install $user --upgrade ;;
    				n|N ) echo "Ok, let's continue";;
    				* ) echo "invalid";;
  				esac
  				echo ""

			fi			
		done

else
	echo -e "\033[4mNo availables updates.\033[0m"
fi

echo ""
