# sudo apt install snapd
# sudo snap install docker circleci

rm -rf install.sh
curl -fLSs https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh >install.sh
DESTDIR=$HOME sudo bash install.sh
rm -rf install.sh
