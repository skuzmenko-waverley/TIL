#!/bin/bash

clear
echo "===================================="
echo "=  Test task 2. Scripting.         ="
echo "=  skuzmenko@waverleysoftware.com  ="
echo "===================================="

host='localhost'
port=8000
imagename='image.png'
password='password=secret'
#checking where it running, need to detect jq
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='macos'
fi

echo "Running on $platform."

#checking if the jq is installed
isIsntalledJq=`which jq`
if [[ "$platform" == 'linux' ]]; then
    if [[ "$isIsntalledJq" != '' ]]; then
        echo  "The jq found at $isIsntalledJq. OK!"
    else
        echo  -e "\n\033[1mThe jq is not found... \033[0m \n"
        echo "jq 1.5 is in the official Debian and Ubuntu repositories. Install using sudo apt-get install jq."
        echo "jq 1.5 is in the official Fedora repository. Install using sudo dnf install jq."
        echo "jq 1.4 is in the official openSUSE repository. Install using sudo zypper install jq."
        echo "jq 1.5 is in the official Arch repository. Install using sudo pacman -S jq."
        exit
    fi
elif [[ "$platform" == 'macos' ]]; then
    if [[ "$isIsntalledJq" != '' ]]; then
        echo "The jq found at $isIsntalledJq. OK!"
    else
        echo  -e "\n\033[1mThe jq is not found... You can install it from homebrew: brew install jq.\033[0m \n"
        exit
    fi
fi

#checking if the curl is installed
isIsntalledCurl=`which curl`
if [[ "$platform" == 'linux' ]]; then
    if [[ "$isIsntalledCurl" != '' ]]; then
        echo "The curl found at $isIsntalledCurl. OK!"
    else
        echo  -e "\n\033[1mThe curl is not found... \033[0m \n"
        echo "curl is in the official Debian and Ubuntu repositories. Install using sudo apt-get install curl."
        echo "curl is in the official Fedora repository. Install using sudo dnf install curl."
        echo "curl is in the official openSUSE repository. Install using sudo zypper install curl."
        echo "curl is in the official Arch repository. Install using sudo pacman -S curl."
        exit
    fi
elif [[ "$platform" == 'macos' ]]; then
    if [[ "$isIsntalledCurl" != '' ]]; then
        echo "The curl found at $isIsntalledCurl. OK!"
    else
        echo -e "\n\033[1m The curl is not found... You can install it from homebrew: brew install curl.\033[0m \n"
        exit
    fi
fi


#checking parameters
if [ -n "$1" ]; then
    username="username=$1"
else
    echo -e "\n\033[1m The Username not specified.\033[0m \n\n    Use:        ./sk-get-image.sh <user> <imagename>. \n\n Exiting...\n"
    exit
fi

if [ -n "$2" ]; then
    imagename="$2.png"
else
    echo -e "The image name not specified as 2nd parameter. \nUsing default filename: image"
fi

#getting token
response=`curl -s -X POST -F $username -F $password $host:$port/auth`
token=`echo $response | jq '.access_token'`

#delete previous file
if [ -f "image.png" ]; then
    echo "Old image file was found, deleting it (image.png)"
    rm "image.png"
fi

#downloading new if it's .png, otherwise show error
type=`curl -s -I -X GET -H 'Accept: application/json' -H "Authorization: Bearer ${token:1:${#token}-2}" $host:$port/image | grep "content-type:"`
if [[ $type == *"content-type: image/png"* ]]; then
    echo "Downloading $imagename"
    curl -s -o $imagename -X GET -H 'Accept: application/json' -H "Authorization: Bearer ${token:1:${#token}-2}" $host:$port/image
else
    echo "Oops..."
    curl -s -X GET -H 'Accept: application/json' -H "Authorization: Bearer ${token:1:${#token}-2}" $host:$port/image
    echo ""
fi
