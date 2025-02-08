#!/bin/env bash

# Dependencies check
dependencies=("git")
missing_deps=()

echo

for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
        missing_deps+=("$dep")
    fi
done

if [ ${#missing_deps[@]} -ne 0 ]; then
    echo "Missing dependencies: ${missing_deps[*]}"
    echo
    exit 1
fi

# Define variables
DOTS_DIR="$HOME/.dots"
GITHUB_USER="mithcs"
declare -A REPOS=(
    ["nvim-config"]="nvim"
    ["awesomewm-config"]="awesome"
    ["rofi-config"]="rofi"
    ["st"]="st"
    ["scripts"]="scripts"
)
declare -A SYMLINKS=(
    ["$DOTS_DIR/nvim"]="$HOME/.config/nvim"
    ["$DOTS_DIR/awesome"]="$HOME/.config/awesome"
    ["$DOTS_DIR/rofi"]="$HOME/.config/rofi"
    ["$DOTS_DIR/st"]="$HOME/.config/st"
    ["$DOTS_DIR/scripts"]="$HOME/scripts"
)

# Create $DOTS_DIR
mkdir -p "$DOTS_DIR"
cd "$DOTS_DIR" || exit 1

echo "Cloning repositories..."
echo

for repo in "${!REPOS[@]}"; do
    folder="${REPOS[$repo]}"
    if [ ! -d "$folder" ]; then
        echo "Cloning git@github.com:$GITHUB_USER/$repo.git into $folder..."
        echo
        git clone "git@github.com:$GITHUB_USER/$repo.git" "$folder"
    else
        echo "$folder already exists, skipping..."
        echo
    fi
done

echo "Creating symbolic links..."
echo

for src in "${!SYMLINKS[@]}"; do
    dest="${SYMLINKS[$src]}"
    
    if [[ -e "$dest"  || -L "$dest" ]]; then
        echo "Existing file found: $dest"
        echo "Choose action: (o)verwrite, (s)kip, (b)ackup"
        read -r choice
        case "$choice" in
            o) rm -rf "$dest" ;;
            b) mv "$dest" "$dest.bak" ;;
            s) echo "Skipping $dest"; continue ;;
            *) echo "Invalid option, skipping..."; continue ;;
        esac
        echo
    fi
    echo
    echo "Linking $src -> $dest"
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
done

echo
echo "Setup complete!"
echo
