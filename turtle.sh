#!/bin/bash

GR="\033[0;32m"
NC="\033[0m"
RED="\033[0;31m"
botz=( $(find . -maxdepth 1 !  -path . -type d  -exec basename {} \; |  xargs -0) )
passwd=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w8 | head -n1)

if [[ $EUID -eq 0 ]]; then
  echo "Tento script nebude fungovat pokud jsi root!" 1>&2
  exit 1
fi

function start {
    optz=("Zapnout vsechny boty" "Zapnout jednoho bota")
        printf "${RED}Vyber si:${NC}\n"
            select optz in "${optz[@]}"; do
                case $REPLY in
                        1) allstart; break ;;
                        2) onestart; break ;;
                        *) echo "Coze?" ;;
                esac
            done
}

function stop {
    opts=("Vypnout vsechny boty" "Vypnout jednoho bota")
        printf "${RED}Vyber si:${NC}\n"
            select opts in "${opts[@]}"; do
                case $REPLY in
                    1) shutall; break ;;
                    2) shutone; break ;;
                    *) echo "Coze?" ;;
                esac
            done
}

function allstart {
        printf "        \n"
        printf "${GR}Startuji boty...${NC}\n"
        for d in ./*/ ; do (cd "$d" && n=${PWD##*/}; screen -AmdS $n ./sinusbot); done
        printf "${GR}Hotovo${NC}\n"
        printf "        \n"
}

function onestart {
        printf "${RED}Vyber bota:${NC}\n"
        select bot in "${botz[@]}" "Ukoncit" ; do
        	if (( REPLY == 1 + ${#botz[@]} )) ; then
        		exit
        	elif (( REPLY > 0 && REPLY <= ${#botz[@]} )) ; then
        		printf "${GR}Vybral jsi $bot pod cislem $REPLY${NC}\n"
        		break

        	else
        		echo "${RED}Nespravna volba, zkus to znovu${NC}\n"
        	fi
        done
    printf "	\n"
    printf "${GR}Startuji bota...${NC}\n"
    cd "/opt/$bot" && n=${PWD##*/}; screen -AmdS $n ./sinusbot
      if ! screen -list | grep -q "$n"; then
        printf "${RED}Bota se nepodarilo nastartovat${NC}\n"
        printf "    \n"
        break

    else
        printf "${GR}Hotovo${NC}\n"
        printf "    \n"
    fi
}

function shutall {
    printf "    \n"
    printf "${GR}Vypinam boty...${NC}\n"
    for d in ./*/ ; do (cd "$d" && n=${PWD##*/}; screen -X -S $n quit); done
    printf "${GR}Hotovo${NC}\n"
    printf "    \n"
}

function shutone {
        printf "${RED}Vyber bota:${NC}\n"
        select bot in "${botz[@]}" "Ukoncit" ; do
            if (( REPLY == 1 + ${#botz[@]} )) ; then
                exit
            elif (( REPLY > 0 && REPLY <= ${#botz[@]} )) ; then
                printf "${GR}Vybral jsi $bot pod cislem $REPLY${NC}\n"
                break

            else
                echo "${RED}Nespravna volba, zkus to znovu${NC}\n"
            fi
        done
    printf "    \n"
    printf "${GR}Vypinam bota...${NC}\n"
    cd "/opt/$bot" && n=${PWD##*/}; screen -X -S $n quit
    if ! screen -list | grep -q "$n"; then
        printf "${GR}Hotovo${NC}\n"
        printf "    \n"
    else
        printf "${RED}Bota se nepodarilo nastartovat${NC}\n"
        printf "    \n"
    fi
}

function delete {
        printf "${RED}Vyber bota:${NC}\n"
        select bot in "${botz[@]}" "Ukoncit" ; do
            if (( REPLY == 1 + ${#botz[@]} )) ; then
                exit
            elif (( REPLY > 0 && REPLY <= ${#botz[@]} )) ; then
                printf "${GR}Vybral jsi $bot pod cislem $REPLY${NC}\n"
                break

            else
                echo "${RED}Nespravna volba, zkus to znovu${NC}\n"
            fi
        done
    printf "    \n"
    printf "${GR}Mazu bota...${NC}\n"
    rm -rf $bot
    printf "${GR}Hotovo${NC}\n"
    printf "    \n"
}

function change {
        printf "${RED}Vyber bota:${NC}\n"
        select bot in "${botz[@]}" "Ukoncit" ; do
            if (( REPLY == 1 + ${#botz[@]} )) ; then
                exit
            elif (( REPLY > 0 && REPLY <= ${#botz[@]} )) ; then
                printf "${GR}Vybral jsi $bot pod cislem $REPLY${NC}\n"
                break

            else
                echo "${RED}Nespravna volba, zkus to znovu${NC}\n"
            fi
        done
    printf "    \n"
    printf "${GR}Menim heslo...${NC}\n"
    cd "/opt/$bot" && n=${PWD##*/}; screen -X -S $n quit; screen -AmdS $n ./sinusbot -override-password $passwd
    printf "${GR}Nove heslo je ${RED}$passwd${NC}\n"
    printf "    \n"

}

all_done=0
while (( !all_done )); do
        options=("Start" "Stop" "Vymazat bota" "Zmenit heslo")

        printf "${RED}Vyber si:${NC}\n"
        select opt in "${options[@]}"; do
                case $REPLY in
                        1) start; break ;;
                        2) stop; break ;;
                        3) delete; break ;;
                        4) change; break ;;
                        *) echo "Coze?" ;;
                esac
        done

        printf "${RED}Mas vse hotovo?${NC}\n"
        select opt in "Ano" "Ne"; do
                case $REPLY in
                        1) all_done=1; break ;;
                        2) break ;;
                        *) echo "Hele, je to jednoducha otazka..." ;;
                esac
        done
done
