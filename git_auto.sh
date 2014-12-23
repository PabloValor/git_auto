#!/bin/bash

printf "\e[8;30;100;t" && clear

function pause(){
   read -p "Presione una tecla para continuar..."
}

clear
## Comprobamos si tenemos el software necesario, de lo contrario lo instalamos
if [ ! -x /usr/bin/git ]; then
    echo "No tienes instalado el paquete \"git\", vamos a instalarlo"
    sudo pacman -Sy --noconfirm git
	clear
	echo ""
	echo "Paquete \"git\" instalado correctamente"
    sleep 4 && clear
fi

if [ ! -x /usr/bin/curl ]; then
    echo "No tienes instalado el paquete \"curl\", vamos a instalarlo"
    sudo pacman -Sy --noconfirm curl
	clear
	echo ""
	echo "Paquete \"curl\" instalado correctamente"
    sleep 4 && clear
fi

if [ ! -x /usr/bin/xclip ]; then
    echo "No tienes instalado el paquete \"xclip\", vamos a instalarlo"
    sudo pacman -Sy --noconfirm xclip
	clear
	echo ""
	echo "Paquete \"xclip\" instalado correctamente"
    sleep 4 && clear
fi
clear

## Comprobamos si tenemos el usuario y correo configurados
username=`git config user.name`
if [ "$username" = "" ]; then
	echo "No se ha encontrado un usuario, vamos a crearlo"
	echo""
	echo "Introduce un nombre de usuario:"
	read username
	git config --global user.name $username
fi
clear

useremail=`git config user.email`
if [ "$useremail" = "" ]; then
	echo "No se ha encontrado un correo del usuario, vamos a introducirlo"
	echo""
	echo "Introduce un correo de usuario:"
	read useremail
	git config --global user.email $useremail
fi
clear

## Crear nuevo repositorio en Github
function nuevoGithub
{
	echo "Vamos a escoger un nombre para el nuevo repositorio: "
	read repo
	clear
	echo "El nuevo repositorio se llamará: \"$repo\""
	pause
	echo ""
	curl -u "$username" https://api.github.com/user/repos -d '{"name":"'$repo'"}' 
	sleep 3 && clear
}

## Crear nuevo trabajo de repositorio en local y subir a servidor Github
function nuevoLocal
{
	clear
	echo ""
	echo "##############################################################################################"
	echo "##   Se va a crear una carpeta donde se guardarán todos nuestos proyectos de repositorios   ##"
	echo "##                  Esta carpeta se llamará Repos y estará en nuestra home                  ##"
	echo "##            En caso de existir dicha carpeta se ignorará el paso y no se creará           ##"
	echo "##############################################################################################"
	echo ""
	pause
	## Comprobamos si tenemos el directorio de Repos, de lo contrario lo crea
	if [ ! -x $HOME/Repos ];then
		mkdir -p $HOME/Repos
	fi
	clear
	echo "Escribe el nombre que debe tener el nuevo repositorio: "
	read nombreRepo
	clear
	echo "Escribe una breve descripción del nuevo repositorio: "
	read descRepo
	mkdir $HOME/Repos/$nombreRepo && cd $HOME/Repos/$nombreRepo
	touch README.md
	git init
	git remote add origin git@github.com:$username/$nombreRepo.git
	git add *
	git commit -am "'$descRepo'"
	git push origin master
	clear
}

## Subir archivos o modificaciones de local a servidor Github
function subirPush
{
	echo "Este es un listado de tus repositorios en local:"
	cd $HOME/Repos && ls -d */ | sed 's/.$//'
	echo ""
	echo "Escribe el nombre del repositorio al que quieres añadir trabajos realizados: "
	read repoPush
	if [ ! -x $HOME/Repos/$repoPush ];then
		echo "Este nombre de repositorio no existe en tu carpeta local"
		sleep 3 && clear
	else
		cd $HOME/Repos/$repoPush
		echo "Escribe una breve descripción de los cambios: "
		read cambiosPush
		git add *
		git commit -am "'$cambiosPush'"
		git push origin master
		sleep 3 && clear
	fi
}

## Obtener una copia de un repositorio existente en Github y no en tu equipo
function obtenerClone
{
	echo "Este es un listado de tus repositorios en el servidor:"
	curl https://api.github.com/users/$username/repos -s | grep git_url | cut -d"/" -f5 | sed 's/......$//'
	echo ""
	echo "Escribe el nombre del repositorio que quieres clonar de tu cuenta: "
	read repoClone
	if [ ! -x $HOME/Repos/$repoClone ];then
		mkdir -p $HOME/Repos/$repoClone
		cd $HOME/Repos/$repoClone
		git init
		git remote add origin git@github.com:$username/$repoClone.git
		git pull origin master
		sleep 3 && clear
	else
		echo "Este repositorio ya existe en tu carpeta local"
		sleep 3 && clear
	fi
}

## Obtener key ssh e insertarla en el servidor Github
function obtenerkey
{
	echo "En esta opción vamos a crear la ssh key para luego ingresarla en el servidor Github"
	echo "y de esta forma poder trabajar sin problemas con nuestros repositorios"
	echo ""
	echo ""
	unset sshpass
	prompt="Escribe la contraseña de tu Github:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
		if [[ $char == $'\0' ]]
		then
			break
		fi
	prompt='*'
	sshpass+="$char"
	done
	ssh-keygen -t rsa -N "$sshpass" -f ~/.ssh/id_rsa -C "$useremail"
	expect << EOF
		spawn ssh-add $HOME/.ssh/id_rsa
		expect "Enter passphrase for $HOME/.ssh/id_rsa:"
		send "$sshpass\r"
		expect eof
EOF
	pause
	clear
	echo "Ahora escribe un título o descripción corta para identificar la key en tu servidor"
	read titulo
	keyssh=$(cat ~/.ssh/id_rsa.pub)
	curl -u "$username:$sshpass" --data '{"title":"'"$titulo"'","key":"'"$keyssh"'"}' https://api.github.com/user/keys
	clear

}

## Menú de opciones
opt=""
while [ "$opt" != "0" ]
do
	echo 1- Crear nuevo repositorio en Github
	echo 2- Crear nuevo trabajo de repositorio en local y subir a servidor Github
	echo 3- Subir archivos o modificaciones de local a servidor Github
	echo 4- Obtener una copia de un repositorio existente en Github y no en tu equipo
	echo 5- Obtener key \ssh e insertarla en el servidor Github
	echo 0- Salir
	echo
	read -p "Selecciona una opción: " opt
	clear
	if [ "$opt" = "1" ]; then
		nuevoGithub
	elif [ "$opt" = "2" ]; then
		nuevoLocal
	elif [ "$opt" = "3" ]; then
		subirPush
	elif [ "$opt" = "4" ]; then
		obtenerClone
	elif [ "$opt" = "5" ]; then
		obtenerkey
	elif [ "$opt" = "0" ]; then
		break
	else
		echo "Escoge una opción correcta"
		sleep 3 && clear
	fi
done