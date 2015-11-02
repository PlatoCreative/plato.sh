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


# Functions list #

These terminal functions will be available after installation.

## cd to site ##

```
#!sh

site {nameOfSiteDirectory}
```
eg site platocreative.co.nz

or

```
#!sh

site cd {nameOfSiteDirectory}
```
eg site cd platocreative.co.nz

## clone site from bitbucket ##

```
#!sh

site clone {nameOfBitBucketRepo}
```
eg site clone platocreative.co.nz

## create new site/project and commit it to bitbucket ##
Make sure a new repo has been created on bitbucket before running this script
```
#!sh

site new {nameOfBitBucketRepo}
```
eg site new platocreative.co.nz

## open the site your default editor ##

```
#!sh

site open {nameOfSiteDirectory}
```

## run compass on your sites theme directory ##

```
#!sh

site theme {nameOfSiteDirectory}
```
 // note you dont need to cd to the theme


## For Vagrant users ##
To run the server.  This will check the specified directory for a vagrant server and run it if available.  If its not then it will move up a directory to run that server if available. 
site up {nameOfSiteDirectory}

## Share your site ##

```
#!sh

site share {nameOfSiteDirectory}
```


## Remove your site and safely destroy your vagrant server. ##

```
#!sh

site remove {nameOfSiteDirectory}
```

## Prepare your local environment, compass watch the theme directory and open the site in your default editor ##

```
#!sh

site prep {nameOfSiteDirectory}
```
