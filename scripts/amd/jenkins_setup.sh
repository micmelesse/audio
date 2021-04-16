# Note: includes a workaround for the occasional hung docker daemon
systemctl status docker | grep 'Active:'
sudo /usr/bin/pkill -f docker
sudo /bin/systemctl restart docker
docker system prune -a -f
systemctl status docker | grep 'Active:'