#!/bin/bash

#VARIABLES
LINE="————————————————————"

#####visual functions#####

#asks the user to enter any key to get back to the main menue
function backtomain {
	read -n 1 -r -p "Please press any key to get back in the main menu..." ANYKEY
	mainmain
}
#asks the user to enter any key to proceed
function anyKeyToProceed {
	read -n 1 -r -p "Please press any key to proceed." ANYKEY
}

#lists the savegames availible
function listSaves {
	echo "$LINE"
	ls -1 ClashSaves/
	echo "$LINE"
}

#shows all the rowids
function showROWIDS {
	echo "rowid for Pass_PROD2: $ROWID4PASS_PROD2"
	echo "rowid for High_PROD2: $ROWID4HIGH_PROD2"
	echo "rowid for Low_PROD2 : $ROWID4LOW_PROD2"
}


#####general functions#####
#collects the ROWIDS from the user
function collectROWIDS {
	if [ "$1" == "clear" ]; then
		clear
	fi
	echo "The specific ROWIDs are needed for this process. To use the default just press [ENTER]."
	#read the rowid for Pass_PRDO2
	echo "$LINE"
	read -p "Please enter the rowid for Pass_PROD2 (default: $DEFAULTPASSPROD2):" ROWID4PASS_PROD2
	ROWID4PASS_PROD2=${ROWID4PASS_PROD2:-$DEFAULTPASSPROD2}

	clear
	echo "For Pass_PROD2 the rowid \"$ROWID4PASS_PROD2\" is saved in temp. memory."
	echo "$LINE"
	#read rowid for High_PROD2
	read -p "Please enter the rowid for High_PROD2 (default: $DEFAULTHIGHPROD2):" ROWID4HIGH_PROD2
	ROWID4HIGH_PROD2=${ROWID4HIGH_PROD2:-$DEFAULTHIGHPROD2}

	clear
	echo "For High_PROD2 the rowid \"$ROWID4HIGH_PROD2\" is saved in temp. memory."
	echo "$LINE"
	#read rowid for Low_PROD2
	read -p "Please enter the rowid for Low_PROD2 (default: $DEFAULTLOWPROD2):" ROWID4LOW_PROD2
	ROWID4LOW_PROD2=${ROWID4LOW_PROD2:-$DEFAULTLOWPROD2}
	
	clear
	echo "You have entered all the rowids needed."
	anyKeyToProceed
}

#checks if everything is ok with the savegame:
#- if the savegamefolder exist
#- if all file within the savegamefolder exist
#echo error messages
function savegamecheck {
	if [ ! -d "ClashSaves/$1/" ]; then
		clear
		echo "The savegame \"$1\" does not exist. Make sure you write case sensitiv."
		backtomain
	else
		if [ ! -f "ClashSaves/$1/Pass_PROD2.alexis" ] && [ ! -f "ClashSaves/$1/High_PROD2.alexis" ] && [ ! -f "ClashSaves/$1/Low_PROD2.alexis" ]; then
			clear
			echo "The savegame \"$1\" is incomplete and cant be loaded."
			backtomain
		fi
	fi
}

#checks if the folder is there and creates the folder if its not there
function foldercheck {
	if [ ! -d $1/ ]; then
		mkdir $1/
	fi
}

#overwrite default rowids...
function writeDef {
	#overwrite default rowids...
	#... for Pass_PROD2
	echo "$ROWID4PASS_PROD2" > defaults/Pass_PROD2
	#...for High_PROD2
	echo "$ROWID4HIGH_PROD2" > defaults/High_PROD2
	#...for Low_PROD2
	echo "$ROWID4LOW_PROD2" > defaults/Low_PROD2
}

#main function
function mainmain {
clear 
echo "Welcome to the CoC savegame manager BETA 2.0!"
echo "Developed by Alexis aka superusername."
echo "For questions, help or problems please contact me here: http://goo.gl/lUBK6X"
echo "Be warned: I dont take any responsibility if this will brick, burn or harm your device in any other way!"
echo ""
echo "What would you like to do?"
echo "1) Show all savagames"
echo "2) Create a new savegame"
echo "3) Load a new savegame"
echo "4) Delete a savegame"
echo "5) Delete current account to start a new one"
echo "6) Create a quick-sqitch script"
echo "7) exit"
echo ""
#init
foldercheck ClashSaves
foldercheck defaults
if [ ! -f defaults/Pass_PROD2 ] && [ ! -f defaults/High_PROD2 ] && [ ! -f defaults/Low_PROD2 ]; then
	echo "no default set yet" > defaults/Pass_PROD2
	echo "no default set yet" > defaults/High_PROD2
	echo "no default set yet" > defaults/Low_PROD2
fi
#VARIABLES for defaults
DEFAULTPASSPROD2=$(cat defaults/Pass_PROD2)
DEFAULTHIGHPROD2=$(cat defaults/High_PROD2)
DEFAULTLOWPROD2=$(cat defaults/Low_PROD2)

#check user imput
read -n 1 -r -p "Please enter your choice here:" NUMBERS



#shows a list of all savegames availible 
if [ $NUMBERS == 1 ]; then
	clear
	echo "Below is a list of all the savegames available:"
	listSaves
	backtomain
fi

#creates a new savegame
if [ "$NUMBERS" == "2" ]; then
	clear
	#General Info
	echo "To create a savegame you have to enter the name of the savegame and your specific rowids."
	echo "Rowids only change if you change your account via gamecenter or you created a new account."
	echo "So you can simply use the defaults if they didnt change."
	#read name of the savegame to create
	echo "$LINE"
	read -p "Please enter the name of your new savegame:" SAVEGAMENAME
	#error if this name already exist
	if [ -d ClashSaves/$SAVEGAMENAME ]; then
		clear
		echo "There is already a savegame with the name \"$SAVEGAMENAME\"."
		echo "Plese choose another name or delete the current one first."
		backtomain
	fi

	clear
	echo "You choose \"$SAVEGAMENAME\" as the name for your savegame."
	echo "$LINE"
	anyKeyToProceed
	
	#collects the rowids
	collectROWIDS clear
	
	#show all the information entered
	clear
	echo "You have entered all the information needed."
	echo "Here you can see the information you entered:"
	echo "$LINE"
	echo "name of your savegame: $SAVEGAMENAME"
	showROWIDS
	echo "$LINE"
	
	#ask for confirmation
	read -r -p "Are you sure you want to create this savegame? [y/N] " response
	clear
	case $response in
	    [yY][eE][sS]|[yY])
			#create folder for the savegame
			mkdir ClashSaves/$SAVEGAMENAME
			#copy Pass_PROD2
			sqlite3 /var/Keychains/keychain-2.db "SELECT quote(data) FROM genp WHERE rowid = '$ROWID4PASS_PROD2'" > ClashSaves/$SAVEGAMENAME/Pass_PROD2.alexis
			#copy High_PROD2
			sqlite3 /var/Keychains/keychain-2.db "SELECT quote(data) FROM genp WHERE rowid = '$ROWID4HIGH_PROD2'" > ClashSaves/$SAVEGAMENAME/High_PROD2.alexis
			#copy Low_PROD2
			sqlite3 /var/Keychains/keychain-2.db "SELECT quote(data) FROM genp WHERE rowid = '$ROWID4LOW_PROD2'" > ClashSaves/$SAVEGAMENAME/Low_PROD2.alexis

			writeDef
			echo "$ROWID4PASS_PROD2" > defaults/Pass_PROD2
			#report succes
			echo "Savegame created. See above if any erors happened."
			backtomain
	        ;;
	    *)
			#show that process canceled
			echo "Creation of savegame canceled."
			backtomain
	        ;;
	esac
fi

#loads a savegame
if [ "$NUMBERS" == "3" ]; then
	clear
	echo "Please type one of the savegames listed below to load it:"
	listSaves
	read -p "Please enter the name of the savegame here (case sensitive):" savegamename
	savegamecheck $savegamename
	collectROWIDS clear
	
	#show all the information entered
	clear
	echo "You have entered all the information needed."
	echo "Below you can see the information you entered:"
	echo "$LINE"
	echo "name of your savegame: $savegamename"
	showROWIDS
	echo "$LINE"
	#ask for verification
	echo "Loading a savegame will overwrite your current account."
	echo "Make sure your current village is somehow backuped."
	read -r -p "Are you sure you want to load the savegame \"$savegamename\"? [y/N] " response
	case $response in
		   [yY][eE][sS]|[yY]) 
			clear
			#verificated -> writing it
			#writes Pass_PROD2 in the keychain
			sqlite3 /var/Keychains/keychain-2.db "UPDATE genp SET data= $(cat ClashSaves/$savegamename/Pass_PROD2.alexis ) WHERE rowid= '$ROWID4PASS_PROD2'"
			#writes High_PROD2 in the keychain
			sqlite3 /var/Keychains/keychain-2.db "UPDATE genp SET data= $(cat ClashSaves/$savegamename/High_PROD2.alexis ) WHERE rowid= '$ROWID4HIGH_PROD2'"
			#writes Low_PROD2 in the Keychain
			sqlite3 /var/Keychains/keychain-2.db "UPDATE genp SET data= $(cat ClashSaves/$savegamename/Low_PROD2.alexis ) WHERE rowid= '$ROWID4LOW_PROD2'"
			
			#overwrite default rowids...
			writeDef

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
fi

#deletes a savegame
if [ "$NUMBERS" == "4" ]; then 
	clear
	echo "Here you can delete a savegame. A list of your savegames is below:"
	listSaves
	read -p "Please type the name of the savegame you want to delete (case sensitive):" SAVEGAMENAMEDELETE
	if [ ! -d ClashSaves/$SAVEGAMENAMEDELETE/ ]; then
		clear
		echo "There is no savegame with the name \"$SAVEGAMENAMEDELETE\". Please make sure you write the name case sensitiv."
		backtomain
	fi
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
		    ;;
		*)
			clear
		    echo "Deletion of \"$SAVEGAMENAMEDELETE\" canceled."
	    ;;
	esac
	backtomain
fi

#deletes current account to start a new one
if [ "$NUMBERS" == "5" ]; then
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

#creates a quick-switch script
if [ "$NUMBERS" == "6" ]; then
	clear
	echo "Here you can create a quick-switch script."
	echo "For this you will have to enter following information"
	echo "- name of the one savegame"
	echo "- name of the other savegame"
	echo "- the specific rowids"
	echo "$LINE"
	read -n 1 -r -p "Please press any key to continue" ANYKEY
	
	clear
	echo "Here is a list of all the savegames availible:"
	listSaves
	read -p "Please enter name of the one savegame:" SAVEGAMENAMEA
	savegamecheck $SAVEGAMENAMEA
	echo "You choose \"$SAVEGAMENAMEA\" as the one savegame."
	echo "$LINE"
	read -p "Please enter name of the other savegame:" SAVEGAMENAMEB
	savegamecheck $SAVEGAMENAMEB

	clear
	echo "You are going to create a quick switch script between foloowing savgemaes:"
	echo "- $SAVEGAMENAMEA"
	echo "- $SAVEGAMENAMEB"
	echo ""
	collectROWIDS

	clear
	echo "You have all information entered that is needed to create the quick-sqitch script."
	echo "$LINE"
	echo "Savegames:"
	echo "- $SAVEGAMENAMEA"
	echo "- $SAVEGAMENAMEB"
					
	echo "rowids:"
	echo "$LINE"
	showROWIDS
	echo "$LINE"
	read -n1 -r -p "Please press any key to continue" ANYKEY
					
	clear
	echo "Now you have to enter the path where the sript should be saved. Just type the filename to save it ib the current dir."
	read -p "Please enter the path (including filename) to save the script:" SCRIPTPATH
					
	#creates the quick-switch script
	echo "writing quick-switch script to $SCRIPTPATH..."
	sleep 3
	cat > $SCRIPTPATH <<EOS
function main {
#check if savegame a is loaded; if so load savegame b
if [ "$(cat ClashSaves/$SAVEGAMENAMEA/Pass_PROD2.alexis)" == "\$(sqlite3 /var/Keychains/keychain-2.db "SELECT quote(data) FROM genp WHERE rowid = $ROWID4PASS_PROD2")" ]; then
	loadB
else
	#check if savegame b is loaded; if so load savegame a
	if [ "$(cat ClashSaves/$SAVEGAMENAMEB/Pass_PROD2.alexis)" == "\$(sqlite3 /var/Keychains/keychain-2.db "SELECT quote(data) FROM genp WHERE rowid = $ROWID4PASS_PROD2")" ]; then
		loadA
	else
		echo "ERROR! Neither $SAVEGAMENAMEA nor $SAVEGAMENAMEB can be detected."
		echo "This error might be caused becasue the rowids are wrong, have changed or another account is currently loaded."
	fi
fi
}
#loads savegame A
function loadA {
	sqlite3 /var/Keychains/keychain-2.db "UPDATE genp SET data= $(cat ClashSaves/$SAVEGAMENAMEA/Pass_PROD2.alexis ) WHERE rowid= '$ROWID4PASS_PROD2'"
	sqlite3 /var/Keychains/keychain-2.db "UPDATE genp SET data= $(cat ClashSaves/$SAVEGAMENAMEA/High_PROD2.alexis ) WHERE rowid= '$ROWID4HIGH_PROD2'"
	sqlite3 /var/Keychains/keychain-2.db "UPDATE genp SET data= $(cat ClashSaves/$SAVEGAMENAMEA/Low_PROD2.alexis ) WHERE rowid= '$ROWID4LOW_PROD2'"
	echo "$SAVEGAMENAMEA is loaded now"
}
#loads savegame B
function loadB {
sqlite3 /var/Keychains/keychain-2.db "UPDATE genp SET data= $(cat ClashSaves/$SAVEGAMENAMEB/Pass_PROD2.alexis ) WHERE rowid= '$ROWID4PASS_PROD2'"
	sqlite3 /var/Keychains/keychain-2.db "UPDATE genp SET data= $(cat ClashSaves/$SAVEGAMENAMEB/High_PROD2.alexis ) WHERE rowid= '$ROWID4HIGH_PROD2'"
	sqlite3 /var/Keychains/keychain-2.db "UPDATE genp SET data= $(cat ClashSaves/$SAVEGAMENAMEB/Low_PROD2.alexis ) WHERE rowid= '$ROWID4LOW_PROD2'"
	echo "$SAVEGAMENAMEB is loaded now"
}
main
EOS
	clear
	#makes it executeable
	chmod +x $SCRIPTPATH
	#writes defaults
	writeDef
	echo "quick-switch script saved to \"$SCRIPTPATH\""
	backtomain
fi

#exits this script
if [ "$NUMBERS" == "7" ]; then
	clear
	exit
else 
	mainmain
fi
}
mainmain