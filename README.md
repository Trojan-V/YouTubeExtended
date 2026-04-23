
## Automatic GitHub Releases

Whenever a Pull Request is merged to the `main` branch, the GitHub workflow `release.yml` is triggered.
This workflow will create a new tag and release in the GitHub repository using the version from the file `control` in the root directory of this project.

## Building the application

This repository provides a GitHub Action which will handle building the final IPA file.
To use the GitHub Action, create a fork of this repository, select the "Actions" tab and run the action "(USER) Create YouTubeExtended App".
The built IPA file will be available as Draft release under the "Releases" tab on GitHub.
