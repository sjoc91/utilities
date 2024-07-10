#!/bin/bash

#Script to automate "prep work" section of
#https://3ds.hacks.guide/installing-boot9strap-(super-skaterhax)

# Define a class-like structure for the GitHubRepo
GitHubRepo() {
  local repo="$1"
  
  # Method to get the latest release tag
  get_latest_release_tag() {
    curl --silent "https://api.github.com/repos/$repo/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'
  }

  # Method to get the download URL for the latest release asset
  get_download_url() {
    curl --silent "https://api.github.com/repos/$repo/releases/latest" | grep -Po '"browser_download_url": "\K.*?(?=")'
  }

  # Method to download the latest release asset
  download_latest_release() {
    local download_url=$(get_download_url)
    if [ -z "$download_url" ]; then
      echo "Failed to get the download URL for the latest release of $repo."
      return 1
    fi

    # Create the temp_repos directory if it doesn't exist
    mkdir -p temp_repos

    local output_file="temp_repos/$(basename "$download_url")"
    curl -L -o "$output_file" "$download_url"
    echo "Downloaded the latest release of $repo to $output_file"

    # Unzip if the downloaded file is a zip file
    if [[ "$output_file" == *.zip ]]; then
      local repo_name=$(basename "$repo")
      unzip "$output_file" -d "temp_repos/$repo_name"
      echo "Unzipped $output_file to temp_repos/$repo_name"
    fi
  }

  # Expose methods as functions
  export -f get_latest_release_tag
  export -f get_download_url
  export -f download_latest_release
}

# Array of GitHub repositories
REPOS=("zoogie/super-skaterhax" "LumaTeam/Luma3DS")

# Array of full HTTP download links
LINKS=("https://github.com/d0k3/SafeB9SInstaller/releases/download/v0.0.7/SafeB9SInstaller-20170605-122940.zip"
		"https://github.com/SciresM/boot9strap/releases/download/1.4/boot9strap-1.4.zip"
		"https://github.com/luigoalma/nimdsphax/releases/download/v1.0/nimdsphax_v1.0.zip")

# Function to download and unzip files from LINKS array
download_links() {
  for link in "${LINKS[@]}"; do
    # Create the temp_repos directory if it doesn't exist
    mkdir -p temp_repos

    local output_file="temp_repos/$(basename "$link")"
    curl -L -o "$output_file" "$link"
    echo "Downloaded $link to $output_file"

    # Unzip if the downloaded file is a zip file
    if [[ "$output_file" == *.zip ]]; then
      unzip "$output_file" -d "./${output_file%.zip}"
      echo "Unzipped $output_file to ${output_file%.zip}"
    fi
  done
}

prep_work(){
  local path_to_sd="$1"
  echo "$path_to_sd"
  echo "$PWD"
  mkdir -p "$path_to_sd"/boot9strap
  mkdir -p "$path_to_sd"/3ds
  cp temp_repos/Luma3DS/{boot.firm,boot.3dsx} $path_to_sd
  cp temp_repos/boot9strap-1.4/{boot9strap.firm,boot9strap.firm.sha} "$path_to_sd"/boot9strap
  cp temp_repos/SafeB9SInstaller-20170605-122940/SafeB9SInstaller.bin $path_to_sd
  cp -r temp_repos/nimdsphax_v1.0/nimdsphax "$path_to_sd"/3ds/
  cp temp_repos/super-skaterhax/"USA (11.17.0-50U)"/{arm11code.bin,browserhax_hblauncher_ropbin_payload.bin} $path_to_sd
  
  rm -r temp_repos
  echo "Done!"
}

# Main function to process the array of repositories and links
main() {
  local path_to_sd="$1"  

  for repo in "${REPOS[@]}"; do
    echo "Processing repository: $repo"
    GitHubRepo "$repo"
    download_latest_release
  done

  download_links

  prep_work "$path_to_sd"
}

# Call the main function
main $1

