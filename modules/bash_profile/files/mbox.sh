# Add /MapRSetup to the path for sh compatible users

if ! echo $PATH | grep -q /MapRSetup ; then
  export PATH=$PATH:/MapRSetup
fi