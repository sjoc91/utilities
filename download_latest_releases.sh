#!/bin/bash

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

		local output_file=$(basename "$download_url")
		curl -L -o "$output_file" "$download_url"
		echo "Downloaded the latest release of $repo to $output_file"
	}

	# Expose methods as functions
	export -f get_latest_release_tag
	export -f get_download_url
	export -f download_latest_release
}

# Main function to process the list of repositories
main() {
		local repos_file="$1"

		if [ ! -f "$repos_file" ]; then
				echo "The file $repos_file does not exist."
				exit 1
		fi

		while IFS= read -r repo; do
				if [ -n "$repo" ]; then
						echo "Processing repository: $repo"
						GitHubRepo "$repo"
						download_latest_release
				fi
		done < "$repos_file"
}

# Check for input file argument
if [ "$#" -ne 1 ]; then
		echo "Usage: $0 <path_to_repos_file>"
		exit 1
fi

# Call the main function with the input file
main "$1"
