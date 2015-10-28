# plato.sh

Change the values in settings and save the file to ~/ (Home directory) with the name .bash_login or .bash_profile.  If successful you should see "Connected to plato bash v#.#" the next time you open terminal.

```
#!sh
## settings start ##
sitesDirectory=~/Sites/
bitBucketName=YOUR_NAME
platoSilverstripeInstallerVersion=@dev
defaultEditor='atom' # 'atom' 'Sublime Text'
defaultProcessor='codekit' # 'koala' 'compass' 'prepros'
defaultGitGUI='tower' # 'none'
# this directory will have its contents copied to a site during install
localSetupDirectory=~/Sites/Setup/ # 'none'
#  this directory will store your resources for projects and will ready the directory for you
resourcesDirectory=~/Resources/
## settings end ##

curl -s -L https://raw.githubusercontent.com/PlatoCreative/plato.sh/master/plato.sh -o ~/platotemp.sh
source ~/platotemp.sh
```
