## settings start ##
sitesDirectory=${sitesDirectory:-~/Sites/}
bitBucketName=${bitBucketName:-plato}
platoSilverstripeInstallerVersion=${platoSilverstripeInstallerVersion:-@dev}
defaultEditor=${defaultEditor:-'atom'}
defaultProcessor=${defaultProcessor:-'compass'} # 'koala' 'compass' 'prepros'
defaultGitGUI=${defaultGitGUI:-'none'} # 'none'
# this directory will have its contents copied to a site during install
localSetupDirectory=${localSetupDirectory:-~/Sites/Setup/} # 'none'
#  this directory will store your resources for projects and will ready the directory for you
resourcesDirectory=${resourcesDirectory:-'none'}
version=2.10
## settings end ##

echo 'Successfully connected to plato bash v'${version}
echo 'For more information go to: https://github.com/PlatoCreative/plato.sh'

## Aliases ##
alias wget="curl -O"
alias hosts='sudo nano /private/etc/hosts'
alias g='git'
alias ga='git add --all'
alias gpush='git push'
alias gpull='git pull'
alias gpp='git pull && git push'
alias gc='git commit -m'
alias gs='git status'
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"

## Autocomplete options ##
actions="cd open clone new pull remove theme up share halt prep resource copylocalfiles"

## Functions ##

watch(){
    if [ -e 'gulpfile.js' ]; then
        if [ ! -d "node_modules" ]; then
            npm install
        fi
        gulp watch ${1} ${2} ${3} ${4} ${5}
    else
        if [ ! -e 'gemfile.lock' ]; then
            bundle install
        fi
        bundle exec compass watch
    fi
}

site(){
  clear
  # assign variables
  if [ $(compgen -W "${actions}" -- ${1}) ]; then
    if [ -n "$3" ]; then
      project=$3
      server=${sitesDirectory}${2}/
    else
      project=$2
      server=${sitesDirectory}
    fi
  else
    if [ -n "$2" ]; then
      project=$2
      server=${sitesDirectory}${1}/
    else
      project=$1
      server=${sitesDirectory}
    fi
  fi
  fullPath=${server}${project}
  resourcesPath=${resourcesDirectory}${project}

  # call appropriate function
  if [ $(compgen -W "${actions}" -- ${1}) ]; then
    case $1 in
      'cd' )
      cdsite
      ;;
      'open' )
      opensite
      ;;
      'clone' )
      clonesite; opensite; resourcefolder; copylocalfiles; themesite
      ;;
      'new' )
      newsite; opensite; resourcefolder; copylocalfiles; themesite;
      ;;
      'pull' )
      pullsite
      ;;
      'up' )
      configServer 'up'; cdsite
      ;;
      'halt' )
      configServer 'halt'
      ;;
      'prep' )
      configServer 'up'; opensite; resourcefolder; themesite;
      ;;
      'share' )
      configServer 'up'; configServer 'share'
      ;;
      'remove' )
      removesite
      ;;
      'theme' )
      themesite
      ;;
      'resource' )
      resourcefolder
      ;;
      'copylocalfiles' )
      copylocalfiles
      ;;
    esac
  else
    cdsite
  fi
}

# site functions directory autocomplete
_siteAutoComplete(){
  local cur prev opts

  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}
  case $COMP_CWORD in
    1 )
    opts="${actions} $(ls ${sitesDirectory})";;
    2 )
    if [ $(compgen -W "${actions}" -- ${prev}) ]; then
      opts="$(ls ${sitesDirectory})"
    else
      opts="$(ls ${sitesDirectory}$prev)"
    fi
    ;;
    3 )
    opts="$(ls ${sitesDirectory}$prev)";;
  esac

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  return 0
}

complete -F _siteAutoComplete site

# checks vagrant files exists, if so vagrant up
_vagrantup(){
  if [ -d .vagrant ]; then
    vagrant up
  fi
}

yn(){
  while true; do
    read -p "${1} [Y/n]:" answer
    case $answer in
      [Yy]* )
      return 0
      break;;
      [Nn]* )
      return 1
      break;;
      * )
      echo "Please answer Yes or No.";;
    esac
  done
}

configServer(){
  # change to server first to run vagrant
  cd ${fullPath}

  if [ -d .vagrant ]; then
    vagrant ${1}
  else
    cd ${server}
    vagrant ${1}
  fi
}

cdsite(){
  if [ ! -d ${fullPath}/ ]; then
    echo "Project ${project} not found.";
  else
    cd ${fullPath}/
    echo ${fullPath}
    ls
  fi
}

opensite(){
  # open in finder
  open ${fullPath}
  # open in default editor
  open -a "${defaultEditor}" ${fullPath}
  if [[ ${defaultGitGUI} != 'none' ]] && [[ -d ${fullPath}/.git/ ]]; then
    open -a "${defaultGitGUI}" ${fullPath}
  fi
}

themesite(){
  themepath=${fullPath}/themes/*/
  # if [ ! -d ${themepath} ]; then
  #   themepath=${fullPath}/mysite/
  # fi
  if [[ ${defaultProcessor} == 'compass' ]]; then
    # change directory
    cd ${themepath}; ls; watch
  else
    open -a "${defaultProcessor}" ${themepath}
    cd ${fullPath}
  fi
}

newsite(){
  # change to server first to run vagrant
  cd ${server}

  _vagrantup

  if [ -d ${fullPath}/ ]; then
    if yn "Project already exists locally.  Do you want to pull the latest from github?"; then
        pullsite
    fi
  else
    echo 'Github password:'
    read -s password  # -s flag hides password text
    curl -u "${githubName}:${password}" https://api.github.com/orgs/PlatoCreative/repos -d '{"name":"'$project'","private": "true"}';
    composer create-project plato-creative/plato-silverstripe-installer ${fullPath} ${platoSilverstripeInstallerVersion} --keep-vcs
    cd ${fullPath}/
    #Removes installer origin
    git remote rm origin
    git remote rm composer
    #Remove install folder before it gets committed
    git rm -rf --cached install/
    #Adds new origin pointing to github
    git remote add origin https://github.com/PlatoCreative/${project}.git
    git branch --set-upstream-to=origin/master master
    # commit everything back to github
    git add --all && git commit -m "Initial commit" && git push -u origin --all
  fi
}

clonesite(){
  # change to server first to run vagrant
  cd ${server}

  _vagrantup

  if [ -d ${fullPath}/ ]; then
    if yn "Project already exists.  Do you want to pull the latest?"; then
      pullsite
    fi
  else
    mkdir ${project}
    git clone https://github.com/PlatoCreative/${project}.git ${fullPath}

    # change directory
    cd ${fullPath}/

    composer install
  fi
}

removesite(){
  if yn "Are you sure you want to delete ${fullPath}?"; then
    if [ -d ${fullPath}/ ]; then
      if [ -d ${fullPath}/.vagrant ]; then
        vagrant destroy
        echo "Removed Vagrant VM"
      fi
      rm -rf ${fullPath}
      echo "Removed ${fullPath}"
    fi
  fi
}

pullsite(){
  cd ${fullPath}/
  git pull
  composer install
  php framework/cli-script.php dev/build
}

copylocalfiles(){
  if [[ ${localSetupDirectory} != 'none' ]] && [[ -d ${localSetupDirectory}/ ]]; then
    cp -Ri ${localSetupDirectory}* ${fullPath}/
    echo 'copied' ${localSetupDirectory} 'to' ${fullPath}
  fi
}

resourcefolder(){
  if [[ ${resourcesDirectory} != 'none' ]]; then
    if [[ ! -d ${resourcesPath}/ ]]; then
      if yn "Would like to resource directory for ${project}?"; then
        mkdir ${resourcesPath}
        open ${resourcesPath}
      fi
    else
      open ${resourcesPath}
    fi
  fi
}

## git Add, Commit and then Push ##
gacp(){
  if [ -n "$1" ]; then
    git add --all && git commit -m "$1" && git push
  else
    echo 'Could not run command, please add a commit message! e.g. gacp "commit message"';
  fi
}

getServerIP(){
    for index in "${server_list[@]}" ; do
        server_name="${index%%::*}"
        server_ip="${index##*::}"
        if [ "${server_name}" = "${1}" ] ; then
            echo ${server_ip}
        fi
    done
}

serverConnect(){
    if [ -z "${server_list}" ]; then
        echo "No servers declared."
        return
    fi

    if [ -z "${3}" ]; then
        echo "Missing ssh user."
        return
    fi
    ssh_user=${3}
    server_ip=$( getServerIP ${2} )
    if [ -z ${server_ip} ]; then
        echo "Server not found."
        return
    fi
    case ${1} in
        'ssh') ssh ${ssh_user}@${server_ip} ;;
        'sshpass') sshpass -p ${4} ssh ${ssh_user}@${server_ip} ;;
        'clone') git clone ssh://${ssh_user}@${server_ip}/${4} . ;;
    esac
}

# create aliases for serverConnect
for index in "${server_list[@]}" ; do
    server_name="${index%%::*}"
    server_ip="${index##*::}"
    alias ${server_name}="serverConnect ssh ${server_name}"
    alias pass_${server_name}="serverConnect sshpass ${server_name}"
    alias clone_${server_name}="serverConnect clone ${server_name}"
done

export PATH="~/.composer/vendor/bin:/Applications/MAMP/bin/php/php5.6.2/bin:$PATH"
