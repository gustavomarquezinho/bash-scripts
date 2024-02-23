#!/bin/bash


BOLD_YELLOW='\e[1;33m'
WHITE='\033[0m'


function get_file_system_info() {
    result=$(df -BM --output=target,size,used,avail,pcent / /home)
    echo -e "$result"
}

function print_line() {
    printf "%"60"s\n" | tr " " "_"
}

function clean_apt() {
    local path="/var/cache/apt"

    print_line
    echo -e "\n${BOLD_YELLOW}Cleaning APT...${WHITE}"

    if [[ ! -d "$path" ]]; then
        echo -e "\nDirectory not found.\n"
        return
    fi

    local size_before=$(du -sh "$path" 2>/dev/null | cut -f1)
    echo -e "${BOLD_YELLOW}Size Before: ${size_before}${WHITE}\n"

    sudo apt clean
    sudo apt autoremove --purge -y
    sudo apt autoclean -y

    local size_after=$(du -sh "$path" 2>/dev/null | cut -f1)
    echo -e "\n${BOLD_YELLOW}Size After: ${size_after}${WHITE}"
    echo -e "${BOLD_YELLOW}APT Cleaned.${WHITE}\n"
    return
}

function clean_snap() {
    local path="/var/lib/snapd/snaps"

    print_line
    echo -e "\n${BOLD_YELLOW}Cleaning SNAP...${WHITE}"

    if [[ ! -d "$path" ]]; then
        echo -e "\nDirectory not found.\n"
        return
    fi

    local size_before=$(du -sh "$path" 2>/dev/null | cut -f1)
    echo -e "${BOLD_YELLOW}Size Before: ${size_before}${WHITE}\n" 

    set -eu
    snap list --all | awk '/disabled/{print $1, $3}' |
        while read snapname revision; do
            sudo snap remove "$snapname" --revision="$revision"
        done

    local size_after=$(du -sh "$path" 2>/dev/null | cut -f1)
    echo -e "\n${BOLD_YELLOW}Size After: ${size_after}${WHITE}"
    echo -e "${BOLD_YELLOW}SNAP Cleaned${WHITE}.\n"
    return
}

function clean_flatpak() {
    local path="/var/tmp/"
    local folder_prefix="flatpak-cache-*"

    local folders=$(
        ls /var/tmp | grep "$folder_prefix" | 
        while read filename; do
            echo "$filename"
        done
    )

    print_line
    echo -e "\n${BOLD_YELLOW}Cleaning FLATPAK...${WHITE}"

    if [[ -z "$folders" ]]; then
        echo -e "\nDirectory not found.\n"
        return
    fi

    local size_before=$(du -h "$path"/* 2>/dev/null | grep -E "^.*flatpak-cache-.*$" | awk '{sum+=$1} END {print sum}')
    echo -e "${BOLD_YELLOW}Size Before: ${size_before}${WHITE}\n"

    for folder in $folders; do
        rm -rf -v "${path}/${folder}"
    done

    local size_after=$(du -h "$path"/* 2>/dev/null | grep -E "^.*flatpak-cache-.*$" | awk '{sum+=$1} END {print sum}')
    echo -e "\n${BOLD_YELLOW}Size After: %.2f${WHITE}\n" "${size_after}"
    echo -e "${BOLD_YELLOW}FLATPAK Cleaned.${WHITE}\n"
    return
}

function clean_thumbnails() {
    local path="/home/$USER/.cache/thumbnails/"

    print_line
    echo -e "\n${BOLD_YELLOW}Cleaning THUMBNAILS...${WHITE}"

    if [[ ! -d "$path" ]]; then
        echo -e "\nDirectory not found.\n"
        return
    fi

    local size_before=$(du -sh "$path" 2>/dev/null | cut -f1)
    echo -e "${BOLD_YELLOW}Size Before: ${size_before}${WHITE}\n"

    rm -rf -v "$path"/*

    local size_after=$(du -sh "$path" 2>/dev/null | cut -f1)
    echo -e "\n${BOLD_YELLOW}Size After: ${size_after}${WHITE}"
    echo -e "${BOLD_YELLOW}THUMBNAILS Cleaned.${WHITE}\n"
    return
}

function clean_journalctl() {
    print_line
    echo -e "\n${BOLD_YELLOW}Cleaning JOURNALCTL...${WHITE}"
    local size_before=$(journalctl --disk-usage 2>/dev/null | cut -f1)
    echo -e "${BOLD_YELLOW}Size Before: ${size_before}${WHITE}\n"

    sudo journalctl --vacuum-time=7d

    local size_after=$(journalctl --disk-usage 2>/dev/null | cut -f1)
    echo -e "\n${BOLD_YELLOW}Size After: ${size_after}${WHITE}"
    echo -e "${BOLD_YELLOW}JOURNALCTL Cleaned.${WHITE}\n"
}

function clean_spotify() {
    local path="/home/$USER/.cache/spotify"

    print_line
    echo -e "\n${BOLD_YELLOW}Cleaning Spotify...${WHITE}"

    if [[ ! -d "$path" ]]; then
        echo -e "\nDirectory not found.\n"
        return
    fi

    local size_before=$(du -sh "$path" 2>/dev/null | cut -f1)
    echo -e "${BOLD_YELLOW}Size Before: ${size_before}${WHITE}\n"

    rm -rf -v "$path"/*

    local size_after=$(du -sh "$path" 2>/dev/null | cut -f1)
    echo -e "\n${BOLD_YELLOW}Size After: ${size_after}${WHITE}"
    echo -e "${BOLD_YELLOW}Spotify Cleaned.${WHITE}\n"
    return
}


old_file_system_info=$(get_file_system_info)

clean_apt
sleep 1

clean_snap
sleep 1

clean_flatpak
sleep 1

clean_thumbnails
sleep 1

clean_journalctl
sleep 1

clean_spotify
sleep 1

new_file_system_info=$(get_file_system_info)

print_line
echo -e "\n${BOLD_YELLOW}Old File System Info${WHITE}"
echo -e "$old_file_system_info"

echo -e "\n${BOLD_YELLOW}New File System Info${WHITE}"
echo -e "$new_file_system_info\n"
print_line
