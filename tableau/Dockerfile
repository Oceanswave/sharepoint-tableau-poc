#!/usr/bin/env -S docker build --compress -t sharepoint-tableau-poc/tableau-server -f

# Docker-based automated installation of Tableau Server
# Follows https://help.tableau.com/current/server-linux/en-us/automated_install_linux.htm - well, mostly.
FROM centos/systemd

# disable interactive functions
ENV DEBIAN_FRONTEND noninteractive

# make systemd dbus visible 
VOLUME /sys/fs/cgroup /run /tmp

# Install dependencies
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum update -y && \
    yum install -y \
        ca-certificates \
        iputils \
        iproute \
        curl \
        git \
        sudo
   
# Clone the Linux Automated Installer https://github.com/tableau/server-install-script-samples/tree/master/linux/automated-installer
WORKDIR /tableau
RUN git clone https://github.com/tableau/server-install-script-samples server-install --depth 3

ARG TABLEAU_LICENSE_KEY=""
ENV TABLEAU_VERSION="2020.2.3" \
    LANG=en_US.UTF-8

# Download the tableau server binaries (https://www.tableau.com/support/releases/server)
RUN curl "https://downloads.tableau.com/esdalt/\${TABLEAU_VERSION}/tableau-server-\${TABLEAU_VERSION//./-}.x86_64.rpm" --output "tableau-server-\${TABLEAU_VERSION//./-}.x86_64.rpm"

# Download tableau drivers (https://www.tableau.com/support/drivers)
RUN curl "https://downloads.tableau.com/drivers/linux/yum/tableau-driver/tableau-postgresql-odbc-09.06.0500-1.x86_64.rpm" --output "tableau-postgresql-odbc-09.06.0500-1.x86_64.rpm"
RUN curl "https://downloads.tableau.com/drivers/linux/yum/tableau-driver/tableau-freetds-1.00.40-1.x86_64.rpm" --output "tableau-freetds-1.00.40-1.x86_64.rpm"
RUN curl "https://downloads.tableau.com/drivers/microsoft/sharepoint/Linux/SharePoint_Tableau_6883.x86_64.rpm" --output "SharePoint_Tableau_6883.x86_64.rpm"

# Add the tsmadmin user
ARG TSM_USER=tsmadmin
RUN ( \
		echo "${TSM_USER} ALL=(ALL) NOPASSWD:ALL" ; \
		echo "Defaults:${TSM_USER} !requiretty"   ; \
		echo "Defaults secure_path = $PATH"   ; \
	) | tee -a /etc/sudoers.d/sudo

RUN useradd -g users -m "${TSM_USER}" && \
    (echo tsmadmin:tsmadmin | chpasswd) 

# Bake in the settings
COPY config /tableau/config

# hack
RUN mkdir -p /run/systemd/system

RUN touch /usr/local/bin/sysctl \
	&& chmod +x /usr/local/bin/sysctl

RUN echo 'seq 0 9 | xargs -I% -- echo %,%' \
	| tee /usr/local/bin/lscpu \
	&& chmod +x /usr/local/bin/lscpu
RUN echo cpu: $(lscpu -p | grep -E -v '^#' | sort -u -t, -k 2,4 | wc -l)

RUN echo 'echo; echo mem: 32768' \
	| tee /usr/local/bin/free \
	&& chmod +x /usr/local/bin/free
RUN echo mem: $(free -m | awk 'NR == 2 { print $2; }')

# Run the installer, expecting that /settings contains the config.json, registration.json, and secrets file.
RUN /tableau/server-install/linux/automated-installer/automated-installer \
    -s /tableau/settings/secrets \
    -f /tableau/settings/config.json \
    -r /tableau/settings/registration.json \
    --accepteula \
    -d /tableau/data \
    -a tsmadmin \
    "/tableau/tableau-server-\${TABLEAU_VERSION//./-}.x86_64.rpm"

# Run the driver installers
RUN yum install -y \
    tableau-postgresql-odbc-09.06.0500-1.x86_64.rpm \
    tableau-freetds-1.00.40-1.x86_64.rpm \
    SharePoint_Tableau_6883.x86_64.rpm

# Expose Gateway and TSM ports
EXPOSE 80 443 8316 8381 8731 8749 8780 8850

# Start tableau as a systemd service
# RUN mkdir -p /etc/systemd/system/ && \
#     cp /tableau/config/tableau_server_install.service /etc/systemd/system/ && \
#     systemctl enable tableau_server_install 

# example: docker run --rm --privileged -itd -p8850:8850 -v/sys/fs/cgroup:/sys/fs/cgroup:ro sharepoint-tableau-poc/tableau-server