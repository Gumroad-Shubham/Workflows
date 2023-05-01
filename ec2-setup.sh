add_config_for_github() {
    echo "Host github.com" >> ~/.ssh/config
    echo "  Hostname      github.com" >> ~/.ssh/config
    echo "  User          git" >> ~/.ssh/config
    echo "  IdentityFile  ~/.ssh/for_aws_to_github" >> ~/.ssh/config
}

ssh -o StrictHostKeyChecking=no ${{ env.SSH_USER }}@${{ env.SSH_HOST }} '
          mkdir -p ~/Desktop/${{ env.PROJECT_NAME }} &&
          cd ~/Desktop/${{ env.PROJECT_NAME }} && 
          # If github.com is not in known hosts, add it
          if ! ssh-keygen -F "github.com" >/dev/null; then
            # Add the host to known_hosts
            ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
          fi
          git init &&
          # Store private key on ec2 so that it can pull from github
          if [ ! -f  ~/.ssh/for_aws_to_github ]; then
            echo {{ env.FOR_AWS_TO_GITHUB }} >> ~/.ssh/for_aws_to_github 
          fi &&
          # Tell ec2 that it needs to use the above pvt key to access github.com
          if [ ! -f ~/.ssh/config ]; then
            # Create the config file and add the configuration for GitHub
            touch ~/.ssh/config
            add_config_for_github()
            echo "Created ~/.ssh/config and added configuration for github.com"
          else
            # Check if the configuration for GitHub already exists
            if grep -q "^Host github.com" ~/.ssh/config; then
              echo "Configuration for github.com already exists in ~/.ssh/config"
            else
              # Add the configuration for GitHub to the existing config file
              add_config_for_github()
              echo "Added configuration for github.com to ~/.ssh/config"
            fi
          fi &&
          git pull git@github.com:bhamshu/${{ env.PROJECT_NAME }}.git'