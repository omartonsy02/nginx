#!/bin/bash
# Function to stop the gcloud compute ssh command
gcloud config set project seif-ayman
gcloud compute firewall-rules create allow-http-web-server --allow tcp:80,icmp --direction INGRESS --network=default --source-ranges 0.0.0.0/0 --target-tags web-server
gcloud compute instances create shipping-srv --machine-type=e2-standard-2 --zone=us-central1-c --network=default --tags web-server
gcloud compute instances create sales-srv --machine-type=e2-standard-2 --zone=us-central1-c --network=default 
gcloud compute instances create support-srv --machine-type=e2-standard-2 --zone=us-central1-c --network=default
gcloud compute ssh shipping-srv --zone us-central1-c --command "sudo apt-get install nginx-light -y"
gcloud compute ssh shipping-srv --zone us-central1-c --command "sudo sed -i 's/Welcome to nginx!/Welcome to shipping department!/g' /var/www/html/index.nginx-debian.html"
gcloud compute ssh shipping-srv --zone us-central1-c --command "cat /var/www/html/index.nginx-debian.html"
gcloud compute ssh shipping-srv --zone us-central1-c --command "exit"

gcloud compute ssh support-srv --zone us-central1-c --command "sudo apt-get install nginx-light -y"
gcloud compute ssh support-srv --zone us-central1-c --command "sudo sed -i 's/Welcome to nginx!/Welcome to support department!/g' /var/www/html/index.nginx-debian.html"
gcloud compute ssh support-srv --zone us-central1-c --command "cat /var/www/html/index.nginx-debian.html"
gcloud compute ssh support-srv --zone us-central1-c --command "exit"

INTERNALSH_IP=$(gcloud compute instances describe shipping-srv --project seif-ayman --zone us-central1-c --format='get(networkInterfaces[0].networkIP)')
echo $INTERNALSH_IP
INTERNALSU_IP=$(gcloud compute instances describe support-srv --project seif-ayman --zone us-central1-c --format='get(networkInterfaces[0].networkIP)')
echo $INTERNALSU_IP

EXTERNALSH_IP=$(gcloud compute instances describe shipping-srv --project seif-ayman --zone us-central1-c --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
echo $EXTERNALSH_IP

EXTERNALSU_IP=$(gcloud compute instances describe support-srv --project seif-ayman --zone us-central1-c --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
echo $EXTERNALSU_IP

gcloud compute ssh sales-srv --zone us-central1-c --command "curl $INTERNALSH_IP "
gcloud compute ssh sales-srv --zone us-central1-c --command "curl $INTERNALSU_IP "
gcloud compute ssh sales-srv --zone us-central1-c --command "curl $EXTERNALSH_IP "
#gcloud compute ssh sales-srv --zone us-central1-c --command "curl $EXTERNALSU_IP "
gcloud compute ssh sales-srv --zone us-central1-c --command "exit"