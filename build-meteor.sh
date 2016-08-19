set -e

if [ $# -lt 1 ]
	then
  echo "USAGE"
  echo "./build-meteor.sh server-url"
  echo ""
  exit 1
fi


# Run only when server parameter is passed
meteor build ./.deploy --architecture os.linux.x86_64 --server $1

git add ./.deploy/stitch-rocket.tar.gz
git commit -m 'AUTOMATED: Commting bundle for deployment'
git push

# Build and deploy a docker
git push aptible master
