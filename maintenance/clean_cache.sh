#!/bin/bash


BOLD_YELLOW='\e[1;33m'
WHITE='\033[0m'


function getFileSystemInfo() {
    result=$(df -BM --output=target,size,used,avail,pcent / /home)
    echo -e "$result"
}

function showLine() {
    printf "%"60"s\n" | tr " " "_"
}

function cleanAPT() {
    local path="/var/cache/apt"

    showLine
    echo -e "\n${BOLD_YELLOW}Cleaning APT...${WHITE}"

    if [[ ! -d "$path" ]]; then
        echo -e "\nDirectory not found.\n"
        return
    fi

    local sizeBefore=$(du -sh "$path" 2>/dev/null | cut -f1)
    printf "${BOLD_YELLOW}Size Before: %s${WHITE}\n\n" "$sizeBefore"

    sudo apt clean
    sudo apt autoremove --purge -y
    sudo apt autoclean -y

    local sizeAfter=$(du -sh "$path" 2>/dev/null | cut -f1)
    printf "\n${BOLD_YELLOW}Size After: %s${WHITE}\n" "$sizeAfter"
    echo -e "${BOLD_YELLOW}APT Cleaned.${WHITE}\n"
    sleep 1
    return
}

function cleanSnap() {
    local path="/var/lib/snapd/snaps"

    showLine
    echo -e "\n${BOLD_YELLOW}Cleaning SNAP...${WHITE}"

    if [[ ! -d "$path" ]]; then
        echo -e "\nDirectory not found.\n"
        return
    fi

    local sizeBefore=$(du -sh "$path" 2>/dev/null | cut -f1)
    printf "${BOLD_YELLOW}Size Before: %s${WHITE}\n\n" "$sizeBefore" 

    set -eu
    snap list --all | awk '/disabled/{print $1, $3}' |
        while read snapname revision; do
            sudo snap remove "$snapname" --revision="$revision"
        done

    local sizeAfter=$(du -sh "$path" 2>/dev/null | cut -f1)
    printf "\n${BOLD_YELLOW}Size After: %s${WHITE}\n" "$sizeAfter"
    echo -e "${BOLD_YELLOW}SNAP Cleaned${WHITE}.\n"
    sleep 1
    return
}

function cleanFlatpak() {
    local path="/var/tmp/"
    local folder_prefix="flatpak-cache-*"

    local folders=$(
        ls /var/tmp | grep "$folder_prefix" | 
        while read filename; do
            echo "$filename"
        done
    )

    showLine
    echo -e "\n${BOLD_YELLOW}Cleaning FLATPAK...${WHITE}"

    if [[ -z "$folders" ]]; then
        echo -e "\nDirectory not found.\n"
        return
    fi

    local sizeBefore=$(du -h "$path"/* 2>/dev/null | grep -E "^.*flatpak-cache-.*$" | awk '{sum+=$1} END {print sum}')
    printf "${BOLD_YELLOW}Size Before: %s${WHITE}\n\n" "${sizeBefore}"

    for folder in $folders; do
        rm -rfv "${path}/${folder}"
    done

    local sizeAfter=$(du -h "$path"/* 2>/dev/null | grep -E "^.*flatpak-cache-.*$" | awk '{sum+=$1} END {print sum}')
    printf "\n${BOLD_YELLOW}Size After: %.2f${WHITE}\n" "${sizeAfter}"
    echo -e "${BOLD_YELLOW}FLATPAK Cleaned.${WHITE}\n"
    sleep 1
    return
}

function cleanThumbnails() {
    local path="/home/$USER/.cache/thumbnails/"

    showLine
    echo -e "\n${BOLD_YELLOW}Cleaning THUMBNAILS...${WHITE}"

    if [[ ! -d "$path" ]]; then
        echo -e "\nDirectory not found.\n"
        return
    fi

    local sizeBefore=$(du -sh "$path" 2>/dev/null | cut -f1)
    printf "${BOLD_YELLOW}Size Before: %s${WHITE}\n\n" "$sizeBefore"

    rm -rf "${path}/*"

    local sizeAfter=$(du -sh "$path" 2>/dev/null | cut -f1)
    printf "${BOLD_YELLOW}Size After: %s${WHITE}\n" "$sizeAfter"
    echo -e "${BOLD_YELLOW}THUMBNAILS Cleaned.${WHITE}\n"
    sleep 1
    return
}

function cleanJournalctl() {
    showLine
    echo -e "\n${BOLD_YELLOW}Cleaning JOURNALCTL...${WHITE}"
    local sizeBefore=$(journalctl --disk-usage 2>/dev/null | cut -f1)
    printf "${BOLD_YELLOW}Size Before: %s${WHITE}\n\n" "$sizeBefore"

    sudo journalctl --vacuum-time=7d

    local sizeAfter=$(journalctl --disk-usage 2>/dev/null | cut -f1)
    printf "${BOLD_YELLOW}Size After: %s${WHITE}\n" "$sizeAfter"
    echo -e "${BOLD_YELLOW}JOURNALCTL Cleaned.${WHITE}\n"
    sleep 1
}

oldFileSystemInfo=$(getFileSystemInfo)

cleanAPT
cleanSnap
cleanFlatpak
cleanThumbnails
cleanJournalctl

newFileSystemInfo=$(getFileSystemInfo)

showLine
echo -e "\n${BOLD_YELLOW}Old File System Info${WHITE}"
echo -e "$oldFileSystemInfo"

echo -e "\n${BOLD_YELLOW}New File System Info${WHITE}"
echo -e "$newFileSystemInfo\n"
showLine
