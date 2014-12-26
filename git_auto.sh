#!/bin/bash

printf "\e[8;30;100;t" && clear

## Variables
CABEZERA1="####################################################################"
CABEZERA2="##                                                                ##"
CABEZERA3="##  Vamos a crear un nuevo repositorio en el servidor de Github.  ##"
CABEZERA4="##     En nuestro equipo local no se modificará ni creará nada    ##"
CABEZERA5="##   Vamos a subir las modificaciones hechas en tu equipo local   ##"
CABEZERA6="##                    a tu servidor de Github                     ##"
CABEZERA7="##   Vamos a obtener un repositorio de tu servidor Github que     ##"
CABEZERA8="##                  no tienes en tu equipo local                  ##"
CABEZERA9="## Vamos a crear la ssh key para luego ingresarla en el servidor  ##"
CABEZERA10="##       Github y poder trabajar con nuestros repositorios        ##"
CABEZERA11="##        Vamos a modificar tu usuario y  tu correo de Git        ##"
CABEZERA12="##                      de tu equipo local                        ##"
CABEZERA13="##   Vamos a comparar con el comando diff los cambios que hemos   ##"
CABEZERA14="##       hecho en local y todavía no se han subido a Github       ##"
AZUL='\e[0;34m'
NARANJA='\e[0;33m'
NC='\e[0m'

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

if [ ! -x /usr/bin/ssh ]; then
    echo "No tienes instalado el paquete \"openssh\", vamos a instalarlo"
    sudo pacman -Sy --noconfirm openssh
	clear
	echo ""
	echo "Paquete \"openssh\" instalado correctamente"
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
	echo ""
	echo ""
	printf "${NARANJA} %*s\n" $(((${#CABEZERA1}+100)/2)) "$CABEZERA1"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA2}+100)/2)) "$CABEZERA2"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA3}+100)/2)) "$CABEZERA3"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA4}+104)/2)) "$CABEZERA4"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA2}+100)/2)) "$CABEZERA2"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA1}+100)/2)) "$CABEZERA1"
	echo -e "${NC}"
	echo "Vamos a escoger un nombre para el nuevo repositorio: "
	read repo
	clear
	echo "El nuevo repositorio se llamará: \"$repo\""
	pause
	echo ""
	unset newpass
	prompt="Escribe la contraseña de tu Github:"
	while IFS= read -p "$prompt" -r -s -n 1 char
	do
		if [[ $char == $'\0' ]]
		then
			break
		fi
	prompt='*'
	newpass+="$char"
	done
	curl -u "$username:$newpass" https://api.github.com/user/repos -d '{"name":"'$repo'"}' 
	sleep 3 && clear
}

## Crear nuevo trabajo de repositorio en local y subir a servidor Github
function nuevoLocal
{
	clear
	echo ""
	echo -e "${NARANJA}##############################################################################################"
	echo "##   Se va a crear una carpeta donde se guardarán todos nuestos proyectos de repositorios   ##"
	echo "##                  Esta carpeta se llamará Repos y estará en nuestra home                  ##"
	echo "##            En caso de existir dicha carpeta se ignorará el paso y no se creará           ##"
	echo "##############################################################################################"
	echo -e "${NC}"
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
	mkdir $HOME/Repos/$nombreRepo
	cd $HOME/Repos/$nombreRepo
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
	echo ""
	echo ""
	printf "${NARANJA} %*s\n" $(((${#CABEZERA1}+100)/2)) "$CABEZERA1"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA2}+100)/2)) "$CABEZERA2"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA5}+100)/2)) "$CABEZERA5"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA6}+100)/2)) "$CABEZERA6"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA2}+100)/2)) "$CABEZERA2"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA1}+100)/2)) "$CABEZERA1"
	echo -e "${NC}"
	echo ""
	sleep 3
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
	echo ""
	echo ""
	printf "${NARANJA} %*s\n" $(((${#CABEZERA1}+100)/2)) "$CABEZERA1"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA2}+100)/2)) "$CABEZERA2"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA7}+100)/2)) "$CABEZERA7"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA8}+100)/2)) "$CABEZERA8"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA2}+100)/2)) "$CABEZERA2"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA1}+100)/2)) "$CABEZERA1"
	echo -e "${NC}"
	echo ""
	sleep 3
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

## Comparar el repositorio local con el alojado en servidor y ver las diferencias
function verdiff
{
	echo ""
	echo ""
	printf "${NARANJA} %*s\n" $(((${#CABEZERA1}+100)/2)) "$CABEZERA1"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA2}+100)/2)) "$CABEZERA2"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA13}+100)/2)) "$CABEZERA13"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA14}+102)/2)) "$CABEZERA14"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA2}+100)/2)) "$CABEZERA2"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA1}+100)/2)) "$CABEZERA1"
	echo -e "${NC}"
	echo ""
	sleep 3
	echo "Estos son tus repositorios locales:"
	cd $HOME/Repos && ls -d */ | sed 's/.$//'
	echo ""
	echo "Escribe el nombre del repositorio que quieres comparar: "
	read diffrepo
	if [ ! -x $HOME/Repos/$diffrepo ];then
		echo "Este nombre de repositorio no existe en tu carpeta local"
		sleep 3 && clear
	else
		cd $HOME/Repos/$diffrepo
		git diff
		clear
	fi
}

## Obtener key ssh e insertarla en el servidor Github
function obtenerkey
{
	echo ""
	echo ""
	printf "${NARANJA} %*s\n" $(((${#CABEZERA1}+100)/2)) "$CABEZERA1"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA2}+100)/2)) "$CABEZERA2"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA9}+100)/2)) "$CABEZERA9"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA10}+100)/2)) "$CABEZERA10"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA2}+100)/2)) "$CABEZERA2"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA1}+100)/2)) "$CABEZERA1"
	echo -e "${NC}"
	echo ""
	sleep 3
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

## Modificar usuario y correo de Git (equipo local)
function modmailusuario
{
	echo""
	echo "Introduce un nuevo correo del usuario:"
	read noumailname
	git config --global user.email $noumailname
	echo -e "Tu nuevo correo electrónico es: $noumailname\n"
}

function modnomusuario
{
	echo""
	echo "Introduce un nuevo nombre de usuario:"
	read nouusername
	git config --global user.name $nouusername
	echo -e "Tu nuevo nombre de usuario es: $nouusername\n"
	pause
}

function modusuariosi
{
	clear
	while true; do
		read -p "Quieres modificar el nombre de usuario $username? [s/N]: " sn
		case $sn in
		[Ss]* ) modnomusuario; break;;
		[Nn]* ) echo -e "El nombre de usuario no se modificará.\n"; break ;;
		* ) echo "Por favor, responde si o no.";;
		esac
	done
	while true; do
		echo -e "\nCorreo actual: $useremail"
		read -p "¿Quieres modificar el correo del usuario $username? [s/N]: " sn
		case $sn in
		[Ss]* ) modmailusuario; break;;
		[Nn]* ) echo -e "El correo del usuario no se modificará.\n"; break ;;
		* ) echo "Por favor, responde si o no.";;
		esac
	done
	echo "Para que funcione el script con la nueva configuración de usuario debe cerrarlo y abrir de nuevo"
	echo -e "Se cerrará automáticamente después de pulsar una tecla.\n"
	pause
	exit
}

function modusuario
{
	echo ""
	echo ""
	printf "${NARANJA} %*s\n" $(((${#CABEZERA1}+100)/2)) "$CABEZERA1"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA2}+100)/2)) "$CABEZERA2"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA11}+100)/2)) "$CABEZERA11"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA12}+100)/2)) "$CABEZERA12"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA2}+100)/2)) "$CABEZERA2"
	printf "${NARANJA} %*s\n" $(((${#CABEZERA1}+100)/2)) "$CABEZERA1"
	echo -e "${NC}"
	echo ""
	sleep 3
	echo "Esta es la configuración de tu usario y Git de tu equipo local:"
	git config --list
	echo ""
	while true; do
		read -p "¿Quieres modificar tu usuario y o correo? [s/N]: " sn
		case $sn in
		[Ss]* ) modusuariosi; break;;
		[Nn]* ) echo -e "\n No se modificará nada."; break ;;
		* ) echo "Por favor, responde si o no.";;
		esac
	done
	pause && clear
}

## Menú de opciones
opt=""
while [ "$opt" != "0" ]
do
	echo 1- Crear nuevo repositorio en servidor Github
	echo 2- Crear nuevo trabajo de repositorio en local y subir a servidor Github
	echo 3- Subir archivos o modificaciones de local a servidor Github
	echo 4- Obtener una copia de un repositorio existente en Github y no en tu equipo
	echo 5- Comparar el repositorio local con el alojado en servidor y ver las diferencias
	echo 6- Obtener key \ssh e insertarla en el servidor Github
	echo 7- Modificar usuario y correo de Git \(equipo local\)
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
		verdiff
	elif [ "$opt" = "6" ]; then
		obtenerkey
	elif [ "$opt" = "7" ]; then
		modusuario
	elif [ "$opt" = "0" ]; then
		break
	else
		echo "Escoge una opción correcta"
		sleep 3 && clear
	fi
done