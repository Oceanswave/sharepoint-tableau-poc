# Tableau POC

Steps:

1. On Ubuntu 18.04.5 LTS, clone this repo and then run ```install-tableau-ubuntu.sh```

2. Obtain an Ngrok acocunt

3. Modify ngrok.yml accordingly and copy to /opt/ngrok/, restarting the ngrok service using systemctl 

4. Obtain a TLS certificate through letsencrypt/openssl/zerossl

5. Configure Tableau through TSM to associate the cert/key

6. RDP access is installed through xrdp, but it might need some tweaks. (should document these)

7. At the bottom of install-tableau-ubuntu, there are some additional steps that are not required but might need to be run to disable clickjacking on embedded iframes and to add various CSP policies. These need to be run as the tsmadmin user. (we can script this out too, just need to do a non-interactive login as the tsmadmin user)

8. Configure SAML based SSO in TSM with the AAD ClientId/Secret. See: https://docs.microsoft.com/en-us/azure/active-directory/saas-apps/tableauserver-tutorial

The docker-compose file in the /tableau folder is WIP as Tableau depends on systemd so it's a process of mapping the systemd folder to the container and making the service launch the process.