#!/bin/bash


BOLD_YELLOW='\e[1;33m'
WHITE='\033[0m'


getFileSystemInfo() {
    result=$(df -BM --output=target,size,used,avail,pcent / /home)
    echo -e "$result"
}

showLine() {
    printf "%"60"s\n" | tr " " "_"
}

cleanAPT() {
    showLine
    echo -e "\n${BOLD_YELLOW}Cleaning APT...${WHITE}"
    sizeBefore=$(sudo du -sh /var/cache/apt 2>/dev/null | cut -f1)
    printf "${BOLD_YELLOW}Size Before: %s${WHITE}\n\n" "$sizeBefore"

    sudo apt clean
    sudo apt autoremove --purge -y
    sudo apt autoclean -y

    sizeAfter=$(sudo du -sh /var/cache/apt 2>/dev/null | cut -f1)
    printf "\n${BOLD_YELLOW}Size After: %s${WHITE}\n" "$sizeAfter"
    echo -e "${BOLD_YELLOW}APT Cleaned.${WHITE}\n"
    sleep 1
}

cleanSnap() {
    showLine
    echo -e "\n${BOLD_YELLOW}Cleaning SNAP...${WHITE}"
    sizeBefore=$(sudo du -h /var/lib/snapd/snaps 2>/dev/null | cut -f1)
    printf "${BOLD_YELLOW}Size Before: %s${WHITE}\n\n" "$sizeBefore" 

    set -eu
    snap list --all | awk '/disabled/{print $1, $3}' |
        while read snapname revision; do
            sudo snap remove "$snapname" --revision="$revision"
        done

    sizeAfter=$(sudo du -sh /var/lib/snapd/snaps 2>/dev/null | cut -f1)
    printf "\n${BOLD_YELLOW}Size After: %s${WHITE}\n" "$sizeAfter"
    echo -e "${BOLD_YELLOW}SNAP Cleaned${WHITE}.\n"
    sleep 1
}

cleanFlatpak() {
    showLine
    echo -e "\n${BOLD_YELLOW}Cleaning FLATPAK...${WHITE}"
    sizeBefore=$(du -h /var/tmp/flatpak-cache* 2>/dev/null | awk '{sum+=$1} END {print sum}')
    printf "${BOLD_YELLOW}Size Before: %s${WHITE}\n\n" "$sizeBefore"

    sudo rm -rfv /var/tmp/flatpak-cache-*

    sizeAfter=$(du -h /var/tmp/flatpak-cache* 2>/dev/null | awk '{sum+=$1} END {print sum}')
    printf "\n${BOLD_YELLOW}Size After: %.2f${WHITE}\n" "$sizeAfter"
    echo -e "${BOLD_YELLOW}FLATPAK Cleaned.${WHITE}\n"
    sleep 1
}

cleanThumbnails() {
    showLine
    echo -e "\n${BOLD_YELLOW}Cleaning THUMBNAILS...${WHITE}"
    sizeBefore=$(sudo du -sh ~/.cache/thumbnails 2>/dev/null | cut -f1)
    printf "${BOLD_YELLOW}Size Before: %s${WHITE}\n\n" "$sizeBefore"

    sudo rm -rf ~/.cache/thumbnails/*

    sizeAfter=$(sudo du -sh ~/.cache/thumbnails 2>/dev/null | cut -f1)
    printf "${BOLD_YELLOW}Size After: %s${WHITE}\n" "$sizeAfter"
    echo -e "${BOLD_YELLOW}THUMBNAILS Cleaned.${WHITE}\n"
    sleep 1
}

cleanJournalctl() {
    showLine
    echo -e "\n${BOLD_YELLOW}Cleaning JOURNALCTL...${WHITE}"
    sizeBefore=$(sudo journalctl --disk-usage 2>/dev/null | cut -f1)
    printf "${BOLD_YELLOW}Size Before: %s${WHITE}\n\n" "$sizeBefore"

    sudo journalctl --vacuum-time=7d

    sizeAfter=$(sudo journalctl --disk-usage 2>/dev/null | cut -f1)
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