#!/usr/bin/env bash

# Perl plugin for KYMSU
# https://github.com/welcoMattic/kymsu

###############################################################################################
#
# Settings:

# Display info on updated pakages 
display_info=true

# No distract mode (no user interaction)
[[ $@ =~ "--nodistract" ]] && no_distract=true || no_distract=false

# Also add module for prevent to update it.
declare -a do_not_update=('')


perl_app=$(which perl)
perl_v=$(perl -v | sed -n '2p')

echo -e "\033[4mPerl:\033[0m $perl_app"
echo -e "\033[4mVersion:\033[0m $perl_v"
echo ""

module="App::cpanoutdated"
if ! perl -M$module -e 1 2>/dev/null; then
	echo -e "\033[4mRequierement:\033[0m module $module is not installed"
	
	a=$(echo -e "Do you wanna run \033[1mcpan -i "$module"\033[0m ? (y/n)")
	read -p "$a" choice
	if [ "$choice" == "y" ]; then
		cpan -i $module
		install_ok=true
	else
		echo "Bye"
		exit
	fi

else
	install_ok=true
fi

if [ "$install_ok" == "true" ]; then
	echo "$module installed"
	
	       # install with cpan
       # % cpan-outdated | xargs cpan -i

        # install with cpanm
       # % cpan-outdated    | cpanm
       # % cpan-outdated -p | cpanm
	
	outdated=$(cpan-outdated -p)
	nb=$(echo $outdated | wc -w)
	
	a=$(echo -e "Do you wanna update\033[1m "$nb" outdated\033[0m modules ? (y/n/a)")
	read -p "$a" choice
	
	if [ "$choice" == "y" ] || [ "$choice" == "Y" ] || [ "$choice" == "a" ] || [ "$choice" == "A" ]; then
			
		for i in $outdated
		do	
			FOUND=`echo ${do_not_update[*]} | grep "$i"`
				if [ "${FOUND}" = "" ]; then
					echo ""
					if [ "$display_info" = true ]; then
						cpan -D "$i"
					fi
					echo -e "\033[1m"
					if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
						echo "$i" | awk '{print $1}' | xargs -p -n 1 cpan -i
					elif [ "$choice" == "a" ] || [ "$choice" == "A" ]; then
							echo "$i" | awk '{print $1}' | xargs -n 1 cpan -i
					fi				
					echo -e "\033[0m"
					#echo ""
				fi
		done
	else
		echo "Bye"
		exit	
	fi
fi