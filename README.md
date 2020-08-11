# Tableau POC

On Ubuntu 18.04.5 LTS, run ```install-tableau-ubuntu.sh```

Obtain a certificate through letsencrypt/openssl/zerossl
Modify ngrok.yml accordingly and copy to /opt/ngrok/

Configure Tableau through TSM to associate the cert/key

RDP access can be installed through xrdp, but it needs some tweaks. (should document these)

The docker-compose file is WIP as Tableau depends on systemd so it's a process of mapping the systemd folder to the container and making the service launch the process.