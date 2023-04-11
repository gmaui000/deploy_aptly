### aptly server

# 1. server

#startup
## docker-compose up -d

#update the version
## scp voyance_0.2.x_amd64.deb server:~/deploy_aptly/repo/

#roolback the version
## rm server:~/deploy_aptly/repo/voyance_0.2.x_amd64.deb


# 2. client

#config  // please make sure the ppa_ip correct.
## cd ppa && sudo bash ppa_config.sh

