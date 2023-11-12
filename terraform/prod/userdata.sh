grep -rhE ^deb /etc/apt/sources.list* | grep "cloud-sdk"
sudo apt-get update
sudo apt-get install -y kubectl
sudo apt-get install -y google-cloud-sdk-gke-gcloud-auth-plugin
sudo apt-get install -y git