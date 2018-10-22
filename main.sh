#!/bin/bash

#VARIABLES
CLASHSAVESFOLDER="false"
DEFAULTSFOLDER="false"
SAVEGAMEFOLDER="false"

#general functions
function backtomain {
	read -n1 -r -p "Please press any key to get back in the main menu..." ANYKEY
	mainmain
}
function clashsavesfolder {
	#set CLASHSAVESFOLDER variable correct
	if [ -d ClashSaves ]; then
		CLASHSAVESFOLDER="true"
	else 
		CLASHSAVESFOLDER="false"
	fi
	#make "ClashSaves" folder if it doesnt exists
	if [ "$CLASHSAVESFOLDER" == "false" ]; then
		mkdir ClashSaves/
	fi
}
function defaultsfolder {
	#set DEFAULTSFOLDER variable correct
	if [ -d defaults ]; then
		DEFAULTSFOLDER="true"
	else 
		DEFAULTSFOLDER="false"
	fi
	#writes files if dir doesnt exist
	if [ "$DEFAULTSFOLDER" == "false" ]; then
		mkdir defaults/
		echo "No default set yet" > defaults/Pass_PROD2
		echo "No default set yet" > defaults/High_PROD2
		echo "No default set yet" > defaults/Low_PROD2
	fi
}
function savegamefolder {
	#sets SAVEGAMEFOLDER variable correct 
	if [ -d CLashSaves/$SAVEGAMENAMEDELETE ]; then
		SAVEGAMEFOLDER="true"
	else
		SAVEGAMEFOLDER="false"
	fi
}



function mainmain {
clear 
echo "Welcome to the CoC savegame manager BETA 1.1!
Developed by Alexis aka superusername.
For questions, help or problems please contact me here: http://goo.gl/lUBK6X
Be warned: I don't take any responsibility if this will brick, burn or harm your device in any other way!

What would you like to do?""
1) Show all savagames
2) Create a new savegame
3) Load a new savegame
4) Delete a savegame
5) Delete current account to start a new one
6) exit"
#folder/file checks
clashsavesfolder
defaultsfolder
#VARIABLES for defaults
DEFAULTPASSPROD2=$(cat defaults/Pass_PROD2)
DEFAULTHIGHPROD2=$(cat defaults/High_PROD2)
DEFAULTLOWPROD2=$(cat defaults/Low_PROD2)
#check user imput
read numbers
if [ $numbers == 1 ]; then
	#this shows a list of the savegames
	clear
	echo "Below is a list of all the savegames available to load:"
	echo "——————————————————"
	ls -1 ClashSaves
	echo "——————————————————"
	backtomain
fi

if [ $numbers == 2 ]; then
	clear
	#General Info
	echo "To create a savegame you have to enter your the specific rowids."
	echo "Rowids only change if you change your account via gamecenter or you created a new one with this script."
	echo "To select the default rowid just press [ENTER] without typing anything"
	echo "——————————————————"
	#read name of the savegame to create
	read -p "Please enter name of your new savegame:" SAVEGAMENAME

	clear
	echo "You choose \"$SAVEGAMENAME\" as the name for your savegame."
	echo "——————————"
	#read the rowid for Pass_PRDO2
	read -p "Please enter the rowid for Pass_PROD2 (default: $DEFAULTPASSPROD2):" ROWID4PASS_PROD2WRITE
	ROWID4PASS_PROD2WRITE=${ROWID4PASS_PROD2WRITE:-$DEFAULTPASSPROD2}

	clear
	echo "For Pass_PROD2 the rowid \"$ROWID4PASS_PROD2WRITE\" is saved in temp. memory."
	echo "——————————"
	#read rowid for High_PROD2
	read -p "Please enter the rowid for High_PROD2 (default: $DEFAULTHIGHPROD2):" ROWID4HIGH_PROD2WRITE
	ROWID4HIGH_PROD2WRITE=${ROWID4HIGH_PROD2WRITE:-$DEFAULTHIGHPROD2}

	clear
	echo "For High_PROD2 the rowid \"$ROWID4HIGH_PROD2WRITE\" is saved in temp. memory."
	echo "——————————"
	#read rowid for Low_PROD2
	read -p "Please enter the rowid for Low_PROD2 (default: $DEFAULTLOWPROD2):" ROWID4LOW_PROD2WRITE
	ROWID4LOW_PROD2WRITE=${ROWID4LOW_PROD2WRITE:-$DEFAULTLOWPROD2}

	#show all information entered
	clear
	echo "You have entered all the information needed."
	echo "Here you can see the information you entered:"
	echo "——————————"
	echo "name of your savegame: $SAVEGAMENAME"
	echo "rowid for Pass_PROD2 : $ROWID4PASS_PROD2WRITE"
	echo "rowid for High_PROD2 : $ROWID4HIGH_PROD2WRITE"
	echo "rowid for Low_PROD2  : $ROWID4LOW_PROD2WRITE"
	echo "——————————"
	#ask for conformation
	read -r -p "Are you sure you want to create this savegame? [y/N] " response
	case $response in
	    [yY][eE][sS]|[yY]) 
	        clear
			#create folder for the savegame
			mkdir ClashSaves/$SAVEGAMENAME
			#copy Pass_PROD2
			sqlite3 /var/Keychains/keychain-2.db "SELECT quote(data) FROM genp WHERE rowid = '$ROWID4PASS_PROD2WRITE'" > ClashSaves/$SAVEGAMENAME/Pass_PROD2.alexis
			#copy High_PROD2
			sqlite3 /var/Keychains/keychain-2.db "SELECT quote(data) FROM genp WHERE rowid = '$ROWID4HIGH_PROD2WRITE'" > ClashSaves/$SAVEGAMENAME/High_PROD2.alexis
			#copy Low_PROD2
			sqlite3 /var/Keychains/keychain-2.db "SELECT quote(data) FROM genp WHERE rowid = '$ROWID4LOW_PROD2WRITE'" > ClashSaves/$SAVEGAMENAME/Low_PROD2.alexis

			#write default rowids...
			#... for Pass_PROD2
			echo "$ROWID4PASS_PROD2WRITE" > defaults/Pass_PROD2
			#...for High_PROD2
			echo "$ROWID4HIGH_PROD2WRITE" > defaults/High_PROD2
			#...for Low_PROD2
			echo "$ROWID4LOW_PROD2WRITE" > defaults/Low_PROD2

			echo "Savegame created. See above if any erors happened."
			backtomain
	        ;;
	    *)
	        clear
			echo "Creation of savegame canceled."
			backtomain
	        ;;
	esac
fi

if [ $numbers == 3 ]; then
	#this code loads a savegame
	clear
	#lists all the savegames availible
	echo "Please type one of the savegames listed below to load it:"
	echo "——————————"
	ls -1 ClashSaves
	echo "——————————"
	read -p "Please enter the name of the savegame here (case sensitive):" savegamename
	
	#checks if the folder of the savegame exist
	if [ -d ClashSaves/$savegamename ]; then 
		#checks if all files exist 
		if [ -a ClashSaves/$savegamename/Pass_PROD2.alexis ] && [ -a ClashSaves/$savegamename/High_PROD2.alexis ] && [ -a ClashSaves/$savegamename/Low_PROD2.alexis ]; then
			#collects all the information needed to load the savegame
			clear
			echo "To load a savegame you have to enter your the specific rowids."
			echo "Rowids only change if you change your account via gamecenter or create a new one with this script."
			echo "To select the default rowid just press [ENTER] without typing anything"
			echo "——————————"
			#read rowid for Pass_PRDO2
			read -p "Pleas enter the rowid for Pass_PROD2 (default: $DEFAULTPASSPROD2):" ROWID4PASS_PROD2LOAD
			ROWID4PASS_PROD2LOAD=${ROWID4PASS_PROD2LOAD:-$DEFAULTPASSPROD2}
			clear

			#read rowid for High_PROD2
			echo "For Pass_PROD2 the rowid \"$ROWID4PASS_PROD2LOAD\" is saved in temp. memory."
			echo "——————————"
			read -p "Pleas enter the rowid for High_PROD2 (default: $DEFAULTHIGHPROD2):" ROWID4HIGH_PROD2LOAD
			ROWID4HIGH_PROD2LOAD=${ROWID4HIGH_PROD2LOAD:-$DEFAULTHIGHPROD2}
			clear

			#read rowid for Low_PROD2
			echo "For High_PROD2 the rowid \"$ROWID4HIGH_PROD2LOAD\" is saved in temp. memory."
			echo "——————————"
			read -p "Pleas enter the rowid for Low_PROD2 (default: $DEFAULTLOWPROD2):" ROWID4LOW_PROD2LOAD
			ROWID4LOW_PROD2LOAD=${ROWID4LOW_PROD2LOAD:-$DEFAULTLOWPROD2}
			clear

			#show all the information entered
			echo "You have entered all the information needed."
			echo "Below you can see the information you entered:"
			echo "——————————"
			echo "name of your savegame: $savegamename"
			echo "rowid for Pass_PROD2 : $ROWID4PASS_PROD2LOAD"
			echo "rowid for High_PROD2 : $ROWID4HIGH_PROD2LOAD"
			echo "rowid for Low_PROD2  : $ROWID4LOW_PROD2LOAD"
			echo "——————————"
			#ask for verification
			echo "Loading a savegame will overwrite your current account."
			echo "Make sure your current village is somehow backuped."
			read -r -p "Are you sure you want to load the savegame \"$savegamename\"? [y/N] " response
			case $response in
			    [yY][eE][sS]|[yY]) 
					clear
					#writing of the savegame verificated -> writing it
					#writes Pass_PROD2 in the keychain
					sqlite3 /var/Keychains/keychain-2.db "UPDATE genp SET data= $(cat ClashSaves/$savegamename/Pass_PROD2.alexis ) WHERE rowid= '$ROWID4PASS_PROD2LOAD'"
					#writes High_PROD2 in the keychain
					sqlite3 /var/Keychains/keychain-2.db "UPDATE genp SET data= $(cat ClashSaves/$savegamename/High_PROD2.alexis ) WHERE rowid= '$ROWID4HIGH_PROD2LOAD'"
					#writes Low_PROD2 in the Keychain
					sqlite3 /var/Keychains/keychain-2.db "UPDATE genp SET data= $(cat ClashSaves/$savegamename/Low_PROD2.alexis ) WHERE rowid= '$ROWID4LOW_PROD2LOAD'"

					#overwrite default rowids...
					#... for Pass_PROD2
					echo "$ROWID4PASS_PROD2LOAD" > defaults/Pass_PROD2
					#...for High_PROD2
					echo "$ROWID4HIGH_PROD2LOAD" > defaults/High_PROD2
					#...for Low_PROD2
					echo "$ROWID4LOW_PROD2LOAD" > defaults/Low_PROD2

					echo "Savegame loaded. See above if any erorrs happened."
					backtomain
			        ;;
			    *)
					#verification canceled -> display error
					clear
			        echo "Savegame loading canceled."
					backtomain
			        ;;
			esac
		else
			#error message that savegame is incomplete
			clear
			echo "The savegame \"$savegamename\" is incomplete and cant be loaded."
			backtomain
		fi
	else
		#error message that the folder (savegame) doesnt exist
		clear
		echo "The savegame \"$savegamename\" does not exist. Make sure you write case sensitiv."
		backtomain
	fi	
fi
if [ $numbers == 4 ]; then 
	clear
	echo "Here you can delete a savegame. A list of your savegames is below:"
	echo "——————————"
	ls -1 ClashSaves
	echo "——————————"
	read -p "Please type the name of the savegame you want to delete (case sensitive):" SAVEGAMENAMEDELETE
	savegamefolder
	if [ "$SAVEGAMEFOLDER" == "true" ]; then
		clear
		echo "Are you sure you want to delete the savegame \"$SAVEGAMENAMEDELETE\"?"
		echo "Please wait 10 seconds before you proceed..."
		sleep 10

		read -r -p "Are you sure you want to delete the savegame \"$SAVEGAMENAMEDELETE\"? [y/N]" response
		case $response in
		    [yY][eE][sS]|[yY]) 
				clear
				rm ClashSaves/$SAVEGAMENAMEDELETE/*
				rmdir ClashSaves/$SAVEGAMENAMEDELETE
				echo "Savegame deleted. See above if any errors happened"
				backtomain
		        ;;
		    *)
				clear
		        echo "Deletion of \"$SAVEGAMENAMEDELETE\" canceled."
		        ;;
		esac
	else
		clear
		echo "There is no savegame with the name \"$SAVEGAMENAMEDELETE\". Please make sure you write the name case sensitiv."
		backtomain
	fi	
fi

if [ $numbers == 5 ]; then
	#this deltes the current account to start a new one
	clear
	echo "Are you sure you want to delete your current account to start a new one?"
	echo "If you have created a savegame of your current account you can load that to restore your account,"
	echo "but its more secure if you created a real Backup with iTunes, iCloud or GameCenter before you proceed!"
	echo "Please wait 10 seconds before you proceed..."
	sleep 10
	
	read -r -p "Are you sure you want to delete your current account? [y/N] " response
	case $response in
	    [yY][eE][sS]|[yY]) 
			clear
			sqlite3 /var/Keychains/keychain-2.db "DELETE FROM genp WHERE agrp LIKE '%supercell.magic%'"
	        echo "Your current account is deleted. If you start CoC now it will create a new village."
	        ;;
	    *)
			clear
	        echo "Deletion of your current account canceled."
	        ;;
	esac
	
	backtomain
fi

if [ $numbers == 6 ]; then
	#this exits this script
	clear
	exit
fi
}
mainmain