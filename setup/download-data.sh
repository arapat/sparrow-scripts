export S3_BUCKET="tmsn-data"

if [ "$#" -ne 1 ]; then
    echo "Wrong paramters. Usage: ./download-data.sh <dataset-name>"
    exit
fi

mkdir -p /mnt/data
cd /mnt/data

if [ "$1" = "bal-bath" ]; then
DIR_NAME="bathymetry-JAMSTEC-balanced"
else if [ "$1" = "bath" ]; then
DIR_NAME="bathymetry-JAMSTEC"
else if [ "$1" = "higgs" ]; then
DIR_NAME="higgs"
else if [ "$1" = "splice" ]; then
DIR_NAME="splice"
else if [ "$1" = "small" ]; then
DIR_NAME="small"
else
    echo "Wrong experiment parameter. Exit."
    exit 1
fi
fi
fi
fi
fi


aws s3 cp s3://$S3_BUCKET/$DIR_NAME/ . --recursive

