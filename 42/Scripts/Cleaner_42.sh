#!/bin/bash
#Author Omar BOUYKOURNE
#42login : obouykou

#banner
# echo -e	"\n"

# echo -e	"     ▄████▄   ██▓    ▓█████ ▄▄▄       ███▄    █ ▓█████  ██▀███  "
# echo -e	"    ▒██▀ ▀█  ▓██▒    ▓█   ▀▒████▄     ██ ▀█   █ ▓█   ▀ ▓██ ▒ ██▒"
# echo -e	"    ▒▓█    ▄ ▒██░    ▒███  ▒██  ▀█▄  ▓██  ▀█ ██▒▒███   ▓██ ░▄█ ▒"
# echo -e	"    ▒▓▓▄ ▄██▒▒██░    ▒▓█  ▄░██▄▄▄▄██ ▓██▒  ▐▌██▒▒▓█  ▄ ▒██▀▀█▄  "
# echo -e	"    ▒ ▓███▀ ░░██████▒░▒████▒▓█   ▓██▒▒██░   ▓██░░▒████▒░██▓ ▒██▒"
# echo -e	"    ░ ░▒ ▒  ░░ ▒░▓  ░░░ ▒░ ░▒▒   ▓▒█░░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒▓ ░▒▓░"
# echo -e	"      ░  ▒   ░ ░ ▒  ░ ░ ░  ░ ▒   ▒▒ ░░ ░░   ░ ▒░ ░ ░  ░  ░▒ ░ ▒░"
# echo -e	"    ░          ░ ░      ░    ░   ▒      ░   ░ ░    ░     ░░   ░ "
# echo -e	"    ░ ░          ░  ░   ░  ░     ░  ░         ░    ░  ░   ░     "
# echo -e	"    ░                                                           "
# echo -en "\n    	    	   By: "
# echo -e "\033[33mOMBHD\033[0m [𝒐𝒃𝒐𝒖𝒚𝒌𝒐𝒖]\n"

# sleep 2

#update
if [ "$1" == "update" ];
then
	tmp_dir=".issent_wakha_daguis_t9ddart_ghina_ard_trmit_orra_tskert_zond_ism_yad_ikan_repo_gh_desktop_nk_achko_awldi_4ayad_yogguer_l'encrypting_n_2^10000_ghayad_aras_tinin_t''a.*\l7i?t_agmano_mohmad"
	if ! git clone --quiet https://github.com/ombhd/Cleaner_42.git "$HOME"/"$tmp_dir" &>/dev/null;
	then
		sleep 0.5
		echo -e "\033[31m\n           -- Couldn't update CCLEAN! :( --\033[0m"
		echo -e "\033[33m\n   -- Maybe you need to change your bad habits XD --\n\033[0m"
		exit 1
	fi
	sleep 1
	if [ "" == "$(diff "$HOME"/Cleaner_42.sh "$HOME"/"$tmp_dir"/Cleaner_42.sh)" ];
	then
		echo -e "\033[33m\n -- You already have the latest version of cclean --\n\033[0m"
		/bin/rm -rf "$HOME"/"${tmp_dir:?}"
		exit 0
	fi
	cp -f "$HOME"/"$tmp_dir"/Cleaner_42.sh "$HOME" &>/dev/null
	/bin/rm -rf "$HOME"/"${tmp_dir:?}" &>/dev/null
	echo -e "\033[33m\n -- cclean has been updated successfully --\n\033[0m"
	exit 0
fi
#calculating the current available storage
Storage=$(df -h "$HOME" | grep "$HOME" | awk '{print($4)}' | tr 'i' 'B')
if [ "$Storage" == "0BB" ];
then
	Storage="0B"
fi
echo -ne "\033[0m\n \033[0;30;42m\033[0m $Storage\033[0m"

echo -n " "
echo -ne "󰄽󱑊󰶻  ...  \033[0;30;42m\033[0m"
while true; do
	sleep 0.1
	echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b󰄽󱐿󰶻  ...  \033[0;30;42m\033[0m"
	sleep 0.1
	echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b󰄽󱑀󰶻  ...  \033[0;30;42m\033[0m"
	sleep 0.1
	echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b󰄽󱑁󰶻  ...  \033[0;30;42m\033[0m"
	sleep 0.1
	echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b󰄽󱑂󰶻  ...  \033[0;30;42m\033[0m"
	sleep 0.1
	echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b󰄽󱑃󰶻  ...  \033[0;30;42m\033[0m"
	sleep 0.1
	echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b󰄽󱑄󰶻  ...  \033[0;30;42m\033[0m"
	sleep 0.1
	echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b󰄽󱑅󰶻  ...  \033[0;30;42m\033[0m"
	sleep 0.1
	echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b󰄽󱑅󰶻  ...  \033[0;30;42m\033[0m"
	sleep 0.1
	echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b󰄽󱑆󰶻  ...  \033[0;30;42m\033[0m"
	sleep 0.1
	echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b󰄽󱑇󰶻  ...  \033[0;30;42m\033[0m"
	sleep 0.1
	echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b󰄽󱑈󰶻  ...  \033[0;30;42m\033[0m"
	sleep 0.1
	echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b󰄽󱑉󰶻  ...  \033[0;30;42m\033[0m"
	if df -h "$HOME" &>/dev/null; then
		break
	fi
done


	# echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b󰅁󰔟󰅂  ...  \033[0;30;42m\033[0m"
	# sleep 0.5
	# echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b󰄽󱦠󰶻  ...  \033[0;30;42m\033[0m"

#42 Caches
/bin/rm -rf "$HOME"/Library/*.42* &>/dev/null
/bin/rm -rf "$HOME"/*.42* &>/dev/null
/bin/rm -rf "$HOME"/.zcompdump* &>/dev/null
/bin/rm -rf "$HOME"/.cocoapods.42_cache_bak* &>/dev/null

#Trash
/bin/rm -rf "$HOME"/.Trash/* &>/dev/null

#General Caches files
#giving access rights on Homebrew caches, so the script can delete them
/bin/chmod -R 777 "$HOME"/Library/Caches/Homebrew &>/dev/null
/bin/rm -rf "$HOME"/Library/Caches/* &>/dev/null
/bin/rm -rf "$HOME"/Library/Application\ Support/Caches/* &>/dev/null

#Slack, VSCode, Discord and Chrome Caches
/bin/rm -rf "$HOME"/Library/Application\ Support/Slack/Service\ Worker/CacheStorage/* &>/dev/null
/bin/rm -rf "$HOME"/Library/Application\ Support/Code/User/workspaceStorage/* &>/dev/null
/bin/rm -rf "$HOME"/Library/Application\ Support/discord/Cache/* &>/dev/null
/bin/rm -rf "$HOME"/Library/Application\ Support/discord/Code\ Cache/js* &>/dev/null
/bin/rm -rf "$HOME"/Library/Application\ Support/Google/Chrome/Profile\ [0-9]/Service\ Worker/CacheStorage/* &>/dev/null
/bin/rm -rf "$HOME"/Library/Application\ Support/Google/Chrome/Default/Service\ Worker/CacheStorage/* &>/dev/null
/bin/rm -rf "$HOME"/Library/Application\ Support/Google/Chrome/Profile\ [0-9]/Application\ Cache/* &>/dev/null
/bin/rm -rf "$HOME"/Library/Application\ Support/Google/Chrome/Default/Application\ Cache/* &>/dev/null

#.DS_Store files
find "$HOME"/Desktop -name .DS_Store -depth -exec /bin/rm {} \; &>/dev/null

#tmp downloaded files with browsers
/bin/rm -rf "$HOME"/Library/Application\ Support/Chromium/Default/File\ System &>/dev/null
/bin/rm -rf "$HOME"/Library/Application\ Support/Chromium/Profile\ [0-9]/File\ System &>/dev/null
/bin/rm -rf "$HOME"/Library/Application\ Support/Google/Chrome/Default/File\ System &>/dev/null
/bin/rm -rf "$HOME"/Library/Application\ Support/Google/Chrome/Profile\ [0-9]/File\ System &>/dev/null

#things related to pool (piscine)
/bin/rm -rf "$HOME"/Desktop/Piscine\ Rules\ *.mp4
/bin/rm -rf "$HOME"/Desktop/PLAY_ME.webloc

#calculating the new available storage after cleaning
Storage=$(df -h "$HOME" | grep "$HOME" | awk '{print($4)}' | tr 'i' 'B')
if [ "$Storage" == "0BB" ];
then
	Storage="0B"
fi
sleep 1
echo -e "\b\b\b\b\b\b\b\b\b\b\b\b󰄽󰗠󰶻 $Storage \033[0;30;42m\033[0m\n\033[0m"
#
# echo -e	"\n	       report any issues to me in:"
# echo -e	"		   GitHub   ~> \033[4;1;34mombhd\033[0m"
# echo -e	"	   	   42 Slack ~> \033[4;1;34mobouykou\033[0m\n"

#installer
