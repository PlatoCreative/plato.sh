## settings start ##
sitesDirectory=${sitesDirectory:-~/Sites/}
bitBucketName=${bitBucketName:-plato}
platoSilverstripeInstallerVersion=${platoSilverstripeInstallerVersion:-@dev}
defaultEditor=${defaultEditor:-'atom'}
defaultProcessor=${defaultProcessor:-'compass'} # 'koala' 'compass' 'prepros'
defaultGitGUI=${defaultGitGUI:-'none'} # 'none'
# this directory will have its contents copied to a site during install
localSetupDirectory=${localSetupDirectory:-~/Sites/Setup} # 'none'
#  this directory will store your resources for projects and will ready the directory for you
resourcesDirectory=${resourcesDirectory:-'none'}
version=1.1
## settings end ##

echo 'Successfully connected to plato bash v'${version}

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
alias watch='bundle exec compass watch'

## Autocomplete options ##
actions="cd open clone new remove theme up share halt prep resource copylocalfiles"

## Functions ##

site(){
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
        project=$1
        server=${sitesDirectory}
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

question(){
    while true; do
        read -p "${1} [Y/n]:" yn
        case $yn in
            [Y]* )
            return 0
            break;;
            [Nn]* )
            return 1
            break;;
            * )
            echo "Please answer Yes or no.";;
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
        echo "Project already exists.";
    else
        composer create-project plato-creative/plato-silverstripe-installer ${fullPath} ${platoSilverstripeInstallerVersion} --keep-vcs
        cd ${fullPath}/
        #Removes installer origin
        git remote rm origin
        git remote rm composer
        #Adds new origin pointing to BitBucket
        git remote add origin https://${bitBucketName}@bitbucket.org/platocreative/${project}.git
        git branch --set-upstream-to=origin/master master
        #Pushes commits to new repo
        git push -u origin
        # commit everything back to bitbucket
        git add --all && git commit -m "Initial commit" && git push
    fi
}

clonesite(){
    # change to server first to run vagrant
    cd ${server}

    _vagrantup

    if [ -d ${fullPath}/ ]; then
        echo "Project already exists.";
    else
        mkdir ${project}
        git clone https://${bitBucketName}@bitbucket.org/platocreative/${project}.git ${fullPath}

        # change directory
        cd ${fullPath}/

        composer install
    fi
}

removesite(){
    if question "Are you sure you want to delete ${fullPath}?"; then
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

copylocalfiles(){
    if [[ ${localSetupDirectory} != 'none' ]] && [[ -d ${localSetupDirectory}/ ]]; then
        cp -Ri ${localSetupDirectory}/* ${fullPath}/
        echo 'copied' ${localSetupDirectory} 'to' ${fullPath}
    fi
}

resourcefolder(){
    if [[ ${resourcesDirectory} != 'none' ]]; then
        if [[ ! -d ${resourcesPath}/ ]]; then
            if [[ ! -d ${resourcesPath}/ ]]; then
                if question "Would like to resource directory for ${project}?"; then
                    mkdir ${resourcesPath}
                    open ${resourcesPath}
                fi
            else
                open ${resourcesPath}
            fi
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

## run sonnen username 'password' ##
sonnen(){
    echo ssh ${1}@112.109.69.27
    if [ -n "$2" ]; then
        sshpass -p ${2} ssh ${1}@112.109.69.27 # Only works when you install sshpass
    else
        ssh ${1}@112.109.69.27
    fi
}

## run bruce username 'password' ##
bruce(){
    echo ssh ${1}@223.165.64.88
    if [ -n "$2" ]; then
        sshpass -p ${2} ssh ${1}@223.165.64.88 # Only works when you install sshpass
    else
        ssh ${1}@223.165.64.88
    fi
}

## run vs2 username 'password' ##
vs2(){
    echo ssh ${1}@112.109.69.25
    if [ -n "$2" ]; then
        sshpass -p ${2} ssh ${1}@112.109.69.25 # Only works when you install sshpass
    else
        ssh ${1}@112.109.69.25
    fi
}

addloginmodule(){
    if [ -f "composer.json" ]; then
        composer config repositories.PlatoCreative vcs git@github.com:PlatoCreative/plato-genericlogin.git;
        composer require guzzlehttp/guzzle:dev-master plato-creative/plato-genericlogin:3.1.*;
        git add composer.json composer.lock;
    else
        cp -av ${sitesDirectory}plato-genericlogin/ .
        git add plato-genericlogin;
    fi
    git commit -m "Added generic login module";
    git push
}

movetobitbucket(){
    echo "SSH user: "
    read ssh_user
    echo "Server IP: "
    read server_ip
    # ssh ${ssh_user}@${server_ip} "ls"
    echo "Public site path(e.g. ~/public/ or ~/repo.co.nz/public/): "
    read public_path
    echo "Old repo(e.g. ~/private/repo.git): "
    read old_repo
    echo "Bitbucket repo name(e.g. repo.co.nz): "
    read new_repo
    if [ $server_ip == 'sonnen' ]; then
        server_ip=112.109.69.27
    fi
    if [ $server_ip == 'bruce' ]; then
        server_ip=223.165.64.88
    fi
    if [ $server_ip == 'vs2' ]; then
        server_ip=112.109.69.25
    fi
    #Prep local temp folder
    mkdir ${sitesDirectory}${new_repo}temp
    cd ${sitesDirectory}${new_repo}temp/

    git clone ssh://${ssh_user}@${server_ip}/${old_repo} .
    git fetch origin
    # create new origin
    git remote add new-origin https://${bitBucketName}@bitbucket.org/platocreative/${new_repo}.git
    # copy everything to the new origin
    git push --all new-origin
    git push --tags new-origin
    git remote rm origin
    git remote rename new-origin origin

    # Add generic login module
    addloginmodule
    # Remove local temp folder
    rm -rf ${sitesDirectory}${new_repo}temp

    # set new origin on live site
    ssh ${ssh_user}@${server_ip} "cd ${public_path}; git remote set-url origin git@bitbucket.org:platocreative/${new_repo}.git; git remote -v; git pull; composer install"
}

export PATH="~/.composer/vendor/bin:/Applications/MAMP/bin/php/php5.6.2/bin:$PATH"
