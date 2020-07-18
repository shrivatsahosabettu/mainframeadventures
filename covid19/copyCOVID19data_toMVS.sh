#!/bin/sh

# Get data from Internet
# and then generate JCL to be SUBmitted to MVS 3.8jk TK4-
cat JCLtemplate.txt > uploadToMVS.JCL
python getcovid19data.py >> uploadToMVS.JCL
echo '/*' >> uploadToMVS.JCL
echo '//' >> uploadToMVS.JCL

# SUBmit JCL to MVS
#./hercsub.pl localhost:3505 uploadToMVS.JCL
netcat -w 10 localhost 3505 < uploadToMVS.JCL

# Remove big files
rm -f uploadToMVS.JCL
rm -f covidcsv