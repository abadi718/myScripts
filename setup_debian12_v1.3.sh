#!/bin/bash

install_vscode() {
    echo "Installing Visual Studio Code..."
    if ! grep -q "packages.microsoft.com/repos/code" /etc/apt/sources.list.d/vscode.list; then
        sudo apt-get install wget gpg
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg
        sudo apt update
    else
        echo "Visual Studio Code repository already added."
    fi

    sudo apt install code

    echo "Visual Studio Code installed successfully."
}

install_chrome() {
    echo "Installing Google Chrome..."
    
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    rm -f google-chrome-stable_current_amd64.deb
    
    echo "Google Chrome installed successfully."
}

install_vlc() {
    echo "Installing VLC..."
    
    sudo apt install vlc
    
    echo "VLC installed successfully."
}

install_edge() {
    echo "Installing Microsoft Edge..."
    
    # Check if the repository already exists in /etc/apt/sources.list.d/microsoft-edge.list
    if ! grep -q "packages.microsoft.com/repos/edge" /etc/apt/sources.list.d/microsoft-edge.list; then
        sudo apt install software-properties-common apt-transport-https wget
        wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main"
        sudo apt update -y
    else
        echo "Microsoft Edge repository already added."
    fi

    sudo apt install microsoft-edge-stable -y
    
    echo "Microsoft Edge installed successfully."
}

load_terminal_key() {
    # Define the content to be written to the file
    content="[org/gnome/settings-daemon/plugins/media-keys]
    custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']

    [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
    binding='<Control><Alt>t'
    command='gnome-terminal'
    name='Terminal'"

    # Write the content to the file (create or overwrite if it already exists)
    echo "$content" > terminalKey

    # Load the content into dconf
    dconf load / < terminalKey

    # Remove the terminalKey file
    rm terminalKey
}

configure_clipboard_indicator() {
    echo "[org/gnome/shell/extensions/clipboard-indicator]" > clipboard
    echo "toggle-menu=['<Super>v']" >> clipboard
    dconf load / < clipboard
    rm clipboard
    dconf write /org/gnome/shell/keybindings/toggle-message-tray "['<Shift><Control><Alt>space']"
    
    echo "Clipboard Indicator and Toggle Message Tray configured."
}
install_flutter_and_android_studio() {
    echo "Installing Flutter and Android Studio..."
    
    # Ask the user to enter the Flutter version number
    read -p "Enter the Flutter version number (e.g., 3.13.8): " flutter_version

    # Construct the download URL for Flutter with the provided version number
    sudo apt install git curl wget
    flutter_download_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${flutter_version}-stable.tar.xz"

    # Construct the download URL for Android Studio
    android_studio_download_url="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.3.1.20/android-studio-2022.3.1.20-linux.tar.gz"

    # Define the target directory (in this case, the home directory)
    target_dir=~

    # Define the paths to the downloaded files
    flutter_archive=~/Downloads/flutter_linux_"$flutter_version"-stable.tar.xz
    android_studio_archive=~/Downloads/android-studio-2022.3.1.20-linux.tar.gz

    # Check if the Flutter archive already exists, and download only if it doesn't
    if [ ! -f "$flutter_archive" ]; then
        if wget "$flutter_download_url" -O "$flutter_archive"; then
            echo "Flutter download complete."
        else
            echo "Flutter download failed. Please check the version number and try again."
        fi
    else
        echo "Flutter archive already exists. Skipping download."
    fi

    # Check if the Flutter directory already exists, and extract only if it doesn't
    if [ ! -d "$target_dir/flutter" ]; then
        # Extract the downloaded Flutter archive with progress bar using tar -xvf
        tar -xvf "$flutter_archive" -C "$target_dir"
        echo "Flutter extraction complete."


    else
        echo "Flutter directory already exists. Skipping extraction and path configuration."
    fi

    # Check if the Android Studio archive already exists, and download only if it doesn't
    if [ ! -f "$android_studio_archive" ]; then
        if wget "$android_studio_download_url" -O "$android_studio_archive"; then
            echo "Android Studio download complete."
        else
            echo "Android Studio download failed. Please check the URL and try again."
        fi
    else
        echo "Android Studio archive already exists. Skipping download."
    fi

    # Check if the Android Studio directory already exists, and extract only if it doesn't
    if [ ! -d "$target_dir/android-studio" ]; then
        # Extract Android Studio using tar
        tar -xvf "$android_studio_archive" -C "$target_dir"
        echo "Android Studio extraction complete."
    else
        echo "Android Studio directory already exists. Skipping extraction."
    fi
	

	FLUTTER_DIR="$HOME/flutter"
	BASHRC_PATH="$HOME/.bashrc"

	if [ -d "$FLUTTER_DIR" ]; then
	    cd "$FLUTTER_DIR" || exit
	else
	    echo "Flutter directory not found at $FLUTTER_DIR. Please make sure it's in your home directory or set the correct path."
	    exit 1
	fi

	if [ -f "$BASHRC_PATH" ]; then
	    if ! grep -q "export PATH=\"\$PATH:\$HOME/flutter/bin\"" "$BASHRC_PATH"; then
		echo 'export PATH="$PATH:$HOME/flutter/bin"' >> "$BASHRC_PATH"
		echo "Updated PATH in .bashrc"
	    else
		echo "PATH entry already exists in .bashrc. No changes made."
	    fi
	else
	    echo ".bashrc not found at $BASHRC_PATH. Please create the file if it doesn't exist."
	    exit 1
	fi
	
	if sudo apt update && sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev; then
        echo "clang, cmake, ninja-build, and pkg-config installed successfully."
    else
        echo "Failed to install one or more packages. Please install them manually."
    fi

    # Run studio.sh from the android-studio/bin/ directory
    if [ -d "$target_dir/android-studio" ]; then
        cd "$target_dir/android-studio/bin" || exit
        if [ -f "studio.sh" ]; then
            ./studio.sh
            echo "Android Studio started."
        else
            echo "studio.sh not found in the bin directory. Please make sure Android Studio is correctly installed."
        fi
    else
        echo "Android Studio directory not found. Skipping the startup of Android Studio."
    fi
	# Command to run in another gnome-terminal
	fdoc="flutter doctor"
	flic="flutter doctor --android-licenses"

	# Launch a new gnome-terminal and execute the command, then wait for input
	gnome-terminal -- bash -c "$fdoc; read -p 'Press Enter to exit...'"
	gnome-terminal -- bash -c "$flic; read -p 'Press Enter to exit...'"
    
    echo "Flutter and Android Studio installation completed."
}

while true; do
    clear
    echo "Choose a number:"
    echo "0. Exit"
    echo "1. Keyboard Shortcuts"
    echo "2. Install Apps"
    echo "3. Back to main menu"
    read input

    case $input in
        0)
            exit 0
            ;;
        1)
            while true; do
                clear
                echo "Keyboard Shortcuts:"
                echo "1. Enable Show Desktop Shortcut"
                echo "2. Enable Language Shortcut"
                echo "3. Enable Switch Window Shortcut"
                echo "4. Create Terminal Shortcut"
                echo "5. Configure Clipboard Indicator"
                echo "6. Back to main menu"
                read keyboard_input

                case $keyboard_input in
                    1)
                        dconf write /org/gnome/desktop/wm/keybindings/show-desktop "['<Super>d']"
                        echo "Show desktop shortcut enabled."
                        read -n 1 -s -r -p "Press any key to continue..."
                        ;;
                    2)
                        dconf write /org/gnome/desktop/wm/keybindings/switch-input-source "['<Alt>Shift_L', '<Alt>Shift_R']"
                        echo "Language shortcut changed."
                        read -n 1 -s -r -p "Press any key to continue..."
                        ;;
                    3)
                        dconf write /org/gnome/desktop/wm/keybindings/switch-windows "['<Alt>Tab']"
                        echo "Switch window shortcut enabled."
                        read -n 1 -s -r -p "Press any key to continue..."
                        ;;
                    4)
                        load_terminal_key
                        echo "Terminal shortcut created."
                        read -n 1 -s -r -p "Press any key to continue..."
                        ;;
                    5)
                        configure_clipboard_indicator
                        read -n 1 -s -r -p "Press any key to continue..."
                        ;;
                    6)
                        break
                        ;;
                    *)
                        echo "Invalid input."
                        read -n 1 -s -r -p "Press any key to continue..."
                        ;;
                esac
            done
            ;;
        2)
            while true; do
                clear
                echo "Install Apps:"
                echo "1. Install Visual Studio Code"
                echo "2. Install Google Chrome"
                echo "3. Install VLC"
                echo "4. Install Microsoft Edge"
                echo "5. Install Flutter & Android Studio"
                echo "6. Back to main menu"
                read install_input

                case $install_input in
                    1)
                        install_vscode
                        read -n 1 -s -r -p "Press any key to continue..."
                        ;;
                    2)
                        install_chrome
                        read -n 1 -s -r -p "Press any key to continue..."
                        ;;
                    3)
                        install_vlc
                        read -n 1 -s -r -p "Press any key to continue..."
                        ;;
                    4)
                        install_edge
                        read -n 1 -s -r -p "Press any key to continue..."
                        ;;
                    5)
                        install_flutter_and_android_studio
                        read -n 1 -s -r -p "Press any key to continue..."
                        ;;
                    6)
                        break
                        ;;
                    *)
                        echo "Invalid input."
                        read -n 1 -s -r -p "Press any key to continue..."
                        ;;
                esac
            done
            ;;
        3)
            break
            ;;
        *)
            echo "Invalid input."
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
    esac
done

