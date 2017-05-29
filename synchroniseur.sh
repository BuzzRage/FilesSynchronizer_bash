#!/bin/bash

#==================== Définition des répertoires de travail =======================
CHEMIN_A=""
CHEMIN_B=""
JA=""
JB=""
JT=""

CHEMIN_SYNCHRO=$(echo $(dirname $(readlink -f $0)))
cd $CHEMIN_SYNCHRO

#======================== Maximum et Minimum de deux nombres ======================
max(){
  A=$1
  B=$2
  
  if [ $A -gt $B ]
  then
    echo $A
  else
    echo $B
  fi
}

min(){
  A=$1
  B=$2
  
  if [ $A -lt $B ]
  then
    echo $A
  else
    echo $B
  fi
}

#======================== Générateur de fichiers journaux =========================
makeJournal(){
  echo "$($CHEMIN_SYNCHRO/mkJournal.sh $1)"
}

#========================= sameContent ============================================
# Renvoie 1 si les fichiers sont identiques en contenu, 0 sinon

sameContent(){
  fich1=$1
  fich2=$2
  nb_ligne1=`cat $fich1|wc -l`
  nb_ligne2=`cat $fich2|wc -l`
  cpt=0
  identique=1
  if [ ! $nb_ligne1 -eq $nb_ligne2 ]
  then
    identique=0
  fi
  
  for i in $(cat $fich1)
  do
    cpt=$((cpt+1))
    ligne=$(cat $fich1|sed -n $((cpt))p)
    if [ ! "$ligne" = "$(cat $fich2|sed -n $((cpt))p)" ]
    then
      identique=0
    fi
  done
  echo $identique
}

#========================= sameType  ============================================
# Renvoie 1 si les variables sont identiques en Type, 0 sinon

sameType(){
  var1=$1
  var2=$2
  identique=0
  
  if [ "$(echo $var1|cut -c1)" = "$(echo $var2|cut -c1)" ]
  then
    identique=1
  fi
  echo $identique
}

#========================= samePerm  ============================================
# Renvoie 1 si les variables sont identiques en Permissions, 0 sinon

samePerm(){
  var1=$1
  var2=$2
  identique=0
  
  if [ "$(echo $var1|cut -d " " -f2)" = "$(echo $var2|cut -d " " -f2)" ]
  then
    identique=1
  fi
  echo $identique
}

#========================= sameNom  ============================================
# Renvoie 1 si les variables sont identiques en Nom, 0 sinon

sameNom(){
  var1=$1
  var2=$2
  identique=0
  
  if [ "$(echo $var1|cut -d " " -f3)" = "$(echo $var2|cut -d " " -f3)" ]
  then
    identique=1
  fi
  echo $identique
}

#========================= sameTaille  ============================================
# Renvoie 1 si les variables sont identiques en Taille, 0 sinon

sameTaille(){
  var1=$1
  var2=$2
  identique=0
  
  if [ "$(echo $var1|cut -d " " -f4)" = "$(echo $var2|cut -d " " -f4)" ]
  then
    identique=1
  fi
  echo $identique
}

#========================= sameDate ============================================
# Renvoie 1 si les variables sont identiques en Date, 0 sinon

sameDate(){
  var1=$1
  var2=$2
  identique=0
  
  if [ "$(awk '{print $5 " " $6 " " $7}' $var1)" = "$(awk '{print $5 " " $6 " " $7}' $var2)" ]
  then
    identique=1
  fi
  echo $identique
}

#========================= sameMeta ============================================
# Renvoie 1 si les variables sont identiques en Metadonnée, 0 sinon

sameMeta(){
  var1=$1
  var2=$2
  identique=0
  
  if [ $(sameType $var1 $var2) -eq 1 ]
  then
    if [ $(samePerm $var1 $var2) -eq 1 ]
    then
      if [ $(sameNom $var1 $var2) -eq 1 ]
      then
	if [ $(sameTaille $var1 $var2) -eq 1 ]
	then
	  #if [ $(sameDate $var1 $var2) -eq 1 ]
	  #then
	    identique=1
	  #fi
	fi
      fi	
    fi
  fi
  echo $identique
}

#============================== same =============================================
# Renvoie 1 si les fichiers sont identiques en Métadonnées et en Contenu, 0 sinon

same(){
  fich1=$1
  fich2=$2
  identique=0
  
  if [ $(sameMeta $fich1 $fich2) -eq 1 -a $(sameContent $fich1 $fich2) -eq 1 ]
  then
    identique=1
  fi
  echo $identique
}

#================= Génération des fichiers journaux ===============================
# Renvoie 1 si les fichiers journaux ne sont pas à jour ou ne sont pas identiques
# Renvoie 0 si les deux arborescences correspondent au journal témoin.

synchronize(){
  hasChanged=0
  
  if test ! -e $JT # Si le fichier .journalT n'existe pas, on le crée
  then
    makeJournal $CHEMIN_B > $JT
    synchronize # Si le fichier témoin n'était pas créé, on relance la synchro.
  fi
  if test ! -e $JA # Si le fichier .journalA n'existe pas, on le crée
  then
    makeJournal $CHEMIN_A > $JA
  fi
  
  if test ! -e $JB # Si le fichier .journalB n'existe pas, on le crée
  then
    makeJournal $CHEMIN_B > $JB
  fi
  
  cat $JB|sed 's?'$CHEMIN_B'?'$CHEMIN_A'?g' > $CHEMIN_SYNCHRO/JB_fake

  if test -e $JA -a ! `sameContent $JT $JA` -eq 1 #Si JA existe mais ne correspond pas à JT
  then 
    hasChanged=1
  fi
  if test -e $JB -a ! `sameContent $JT $JB` -eq 1 #Si JB existe mais ne correspond pas à JT
  then 
    hasChanged=1
  fi

  echo $hasChanged
}

#============== Indique si deux fichiers sont différents et en quoi ===============
#On se retrouve ici si le fichier existe dans les deux racines.
#Paramètre 1: nom du fichier (chemin inclu) de la racine A
#Paramètre 2: nom du fichier (chemin inclu) de la racine B
#Paramètre 3: ième ligne du journalT
#Paramètre 4: nom du fichier

isDifferent(){

  A=$1
  B=$2
  T=$(sed -n $3p $JT) 
  fichier=$4

  ligne_A=$(grep -w "$fichier" $JA|head -1)
  ligne_B=$(grep -w "$fichier" $JB|head -1)

  #echo -e "$A\n$B" > .diff
  
  if [ $(sameType $ligne_A "-") -eq 1 -a $(sameType $ligne_B "d") -eq 1  ] #Si $A est un fichier et $B un rep
  then
    echo "Le fichier $fichier de la racine A est un fichier, alors que celui de la racine B est un répertoire."
    echo "Le fichier $fichier de la racine A est un fichier, alors que celui de la racine B est un répertoire." >> $CHEMIN_SYNCHRO/synchro.log
    action=`askuser "Garder le répertoire" "Garder le fichier"`
    if [ $action -eq 1 ]
    then
      rm $A
      cp -r $B $A
    elif [ $action -eq 2 ]
    then
      rm -r $B
      cp $A $B
    fi
  elif [ $(sameType $ligne_A "d") -eq 1 -a $(sameType $ligne_B "-") -eq 1  ] #Si $A est un rep et $B un fichier
  then
    echo "Le fichier $fichier de la racine A est un répertoire, alors que celui de la racine B est un fichier."
    echo "Le fichier $fichier de la racine A est un répertoire, alors que celui de la racine B est un fichier." >> $CHEMIN_SYNCHRO/synchro.log
    action=`askuser "Garder le répertoire" "Garder le fichier"`
    if [ $action -eq 1 ]
    then
      rm $B
      cp -r $A $B
    elif [ $action -eq 2 ]
    then
      rm -r $A
      cp $B $A
    fi  
  fi
  
  #Variable contenant le chemin du fichier "d'origine" chemin/nom
  path_T="$(echo $T|cut -d " " -f8)/$(echo $T|cut -d " " -f3)"

  if [ $A -nt $B ] #Si p/A est plus récent que p/B
  then
    if [ $(sameType $ligne_A "d") -eq 1 ]
    then
      if [ $(sameType $ligne_B "d") -eq 1 ]
      then
	rm -r $B
      elif [ $(sameType $ligne_B "-") -eq 1 ]
      then
	rm $B
      fi
    cp -r $A $B
    elif [ $(sameType $ligne_A "-") -eq 1 ]
    then
      if [ $(sameType $ligne_B "d") -eq 1 ]
      then
	rm -r $B
      elif [ $(sameType $ligne_B "-") -eq 1 ]
      then
	rm $B
      fi
    cp $A $B
    fi	
  elif [ $B -nt $A ] 
  then
    if [ $(sameType $ligne_B "d") -eq 1 ]
    then
      if [ $(sameType $ligne_A "d") -eq 1 ]
      then
	rm -r $A
      elif [ $(sameType $ligne_A "-") -eq 1 ]
      then
	rm $A
      fi
    cp -r $B $A
    elif [ $(sameType $ligne_B "-") -eq 1 ]
    then
      if [ $(sameType $ligne_A "d") -eq 1 ]
      then
	rm -r $A
      elif [ $(sameType $ligne_A "-") -eq 1 ]
      then
	rm $A
      fi
    cp $B $A
    fi	
  else
    action=`askuser "Copier A" "Supprimer A"`
    if [ $action -eq 1 ]
    then
      if [ $(sameType $ligne_B "d") -eq 1 ]
      then
	rm -r $B
      elif [ $(sameType $ligne_B "f") -eq 1 ]
      then
	rm $B
      fi
      cp $A $B
    elif [ $action -eq 2 ]
    then
      if [ $(sameType $ligne_A "d") -eq 1 ]
      then
	rm -r $B
      elif [ $(sameType $ligne_A "-") -eq 1 ]
      then
	rm $A
      fi
    fi
  fi  
  
  #Si p/A est conforme mais pas p/B, on change A en B
  if [ $(sameMeta $(echo $ligne_A|cut -d " " -f1-4) $(echo $T|cut -d " " -f1-4)) -eq 1 -a $(sameMeta $(echo $ligne_B|cut -d " " -f1-4) $(echo $T|cut -d " " -f1-4)) -ne 1 ]
  then
    echo "- $fichier de la racine A est conforme, mais pas $fichier de la racine B"
    echo "- $fichier de la racine A est conforme, mais pas $fichier de la racine B" >> $CHEMIN_SYNCHRO/synchro.log
    if [ $(sameType $ligne_A "-") -eq 1 ]
    then
      if [ $(sameType $ligne_B "-") -eq 1 ]
      then
	rm $A
	cp $B $A
      elif [ $(sameType $ligne_B "d") -eq 1 ]
      then
	rm $A
	cp -r $B $A
      fi
    elif [ $(sameType $ligne_A "d") -eq 1 ]
    then
      if [ $(sameType $ligne_B "-") -eq 1 ]
      then
	rm -r $A
	cp $B $A
      elif [ $(sameType $ligne_B "d") -eq 1 ]
      then
	rm -r $A
	cp -r $B $A
      fi
    fi

  #Si p/B est conforme mais pas p/A, on change B en A
  elif [ $(sameMeta $(echo $ligne_B|cut -d " " -f1-4) $(echo $T|cut -d " " -f1-4)) -eq 1 -a $(sameMeta $(echo $ligne_A|cut -d " " -f1-4) $(echo $T|cut -d " " -f1-4)) -ne 1 ]
  then
    echo "- $fichier de la racine A est conforme, mais pas $fichier de la racine B"
    echo "- $fichier de la racine A est conforme, mais pas $fichier de la racine B" >> $CHEMIN_SYNCHRO/synchro.log
    if [ $(sameType $ligne_B "-") -eq 1 ]
    then
      if [ $(sameType $ligne_A "-") -eq 1 ]
      then
	rm $B
	cp $A $B
      elif [ $(sameType $ligne_A "d") -eq 1 ]
      then
	rm $B
	cp -r $A $B
      fi
    elif [ $(sameType $ligne_B "d") -eq 1 ]
    then
      if [ $(sameType $ligne_A "-") -eq 1 ]
      then
	rm -r $B
	cp $A $B
      elif [ $(sameType $ligne_A "d") -eq 1 ]
      then
	rm -r $B
	cp -r $A $B
      fi
    fi
  #Si aucun des deux n'est conforme, demander à l'utilisateur
  elif [ $(sameMeta $(echo $ligne_A|cut -d " " -f1-4) $(echo $T|cut -d " " -f1-4)) -ne 1 -a $(sameMeta $(echo $ligne_B|cut -d " " -f1-4) $(echo $T|cut -d " " -f1-4)) -ne 1 ]
  then
    echo "Le fichier $fichier de la racine A et celui de la racine B sont non conformes."
    echo -e "Infos de A: $ligne_A\nInfos de B: $ligne_B\nInfos du journal: $T\n"
    action=`askuser "Garder celui de A" "Garder celui de B"`
    if [ "$action" = "1" ]
    then
      if [ $(sameType $ligne_B "-") -eq 1 ]
      then
	if [ $(sameType $ligne_A "-") -eq 1 ]
	then
	  rm $B
	  cp $A $B
	elif [ $(sameType $ligne_A "d") -eq 1 ]
	then
	  rm $B
	  cp -r $A $B
	fi
      elif [ $(sameType $ligne_B "d") -eq 1 ]
      then
      	if [ $(sameType $ligne_A "f") -eq 1 ]
	then
	  rm -r $B
	  cp $A $B
	elif [ $(sameType $ligne_A "d") -eq 1 ]
	then
	  rm -r $B
	  cp -r $A $B
	fi
      fi
    elif [ "$action" = "2" ]
    then
      if [ $(sameType $ligne_A "-") -eq 1]
      then
	if [ $(sameType $ligne_B "-") -eq 1 ]
	then
	  rm $A
	  cp $B $A
	elif [ $(sameType $ligne_B "d") -eq 1 ]
	then
	  rm $A
	  cp -r $B $A
	fi
      elif [$(sameType $ligne_A "d") -eq 1 ]
      then
      	if [ $(sameType $ligne_B "-") -eq 1 ]
	then
	  rm -r $A
	  cp $B $A
	elif [ $(sameType $ligne_B "d") -eq 1 ]
	then
	  rm -r $A
	  cp -r $B $A
	fi
      fi
    fi  
  fi

}

#============================== isMoreRecent ======================================
# Renvoi 1 si le fichier du premier paramètre est plus récent, 2 c'est le deuxieme
# Et 0 si c'est égal
isMoreRecent(){
  fich1=$1
  fich2=$2

  # %T = %H:%M:%S
  date1=$(date -r $fich1 '+%Y%m%d%H%M%S')
  date2=$(date -r $fich2 '+%Y%m%d%H%M%S')

  if [ $date1 -gt $date2 ]
  then
    echo 1
  elif [ $date1 -lt $date2 ]
  then
    echo 2
  else
    echo 0
  fi
}

#================================ AskUser =========================================
askuser(){
  opt1="$1"
  opt2="$2"
  read -p "Que voulez-vous faire ? 1.$opt1 2.$opt2 " action
  while [ ! "$action" = "1" -a ! "$action" = "2" ] 
  do
    echo "Veuillez taper 1 ou 2"
    read -p "Que voulez-vous faire ? 1.$opt1 2.$opt2 " action
  done
  echo ${action: -1}
}

#============================== Analyse ===========================================
analyze(){ 
  max=$(wc -l < $JT)
  for i in `seq 1 $max` #|head -$(($i+1))|tail -1`
  do
    fichier=`cat $JT|cut -d " " -f 3|head -$i|tail -1`
    
    # Pour l'utiliser sous forme $RacineA/$chemin/
    chemin="`cat $JT|head -$i|tail -1|cut -d " " -f 8|cut -d "/" -f7- `" 
    isDifferent $CHEMIN_A/$chemin$fichier $CHEMIN_B/$chemin$fichier $i $fichier
#     if [ -f $CHEMIN_A/$chemin$fichier ]
#     then
#       echo  "Le fichier $fichier existe dans A et dans B."
#       echo  "Le fichier $fichier existe dans A et dans B." >> $CHEMIN_SYNCHRO/synchro.log
#       isDifferent $CHEMIN_A/$chemin$fichier $CHEMIN_B/$chemin$fichier $i $fichier # On regarde s'il est différent et en quoi
#     elif [ -d $CHEMIN_A/$chemin$fichier ]  
#     then
#       echo  "Le dossier $fichier existe dans A et dans B."
#       echo  "Le dossier $fichier existe dans A et dans B." >> $CHEMIN_SYNCHRO/synchro.log
#       isDifferent $CHEMIN_A/$chemin$fichier $CHEMIN_B/$chemin$fichier $i $fichier
#       #cd $CHEMIN_A/$chemin$fichier
# # 	  echo "i: $i"
# # 	  analyze $i      # C'est à partir de ce moment que le programme ne fonctionne plus.
# # 	  cd ..
#     fi
# 	echo "Le fichier $fichier existe dans A mais pas dans B."
# 	echo "Le fichier $fichier existe dans A mais pas dans B." >> $CHEMIN_SYNCHRO/synchro.log
# 	if [ $fichier -nt $JT -a $JA -nt $fichier -a $JA -nt $JB ] #Si le fichier est plus récent que .journalTemoin (cad le fichier est nouveau)
# 	then
# 	  if [ -d $CHEMIN_A/$chemin$fichier ]
# 	  then
# 	    cp -r $CHEMIN_A/$chemin$fichier $CHEMIN_B/$chemin$fichier
# 	  elif [ -f $CHEMIN_A/$chemin$fichier ]
# 	  then
# 	    cp -r $CHEMIN_A/$chemin$fichier $CHEMIN_B/$chemin$fichier
# 	  fi	
# 	elif [ $fichier -nt $JT -a $JB -nt $fichier -a $JB -nt $JA ] 
# 	then
# 	  if [ -d $CHEMIN_A/$chemin$fichier ]
# 	  then
# 	    rm -r $CHEMIN_A/$chemin$fichier
# 	  elif [ -f $CHEMIN_A/$chemin$fichier ]
# 	  then
# 	    rm $CHEMIN_A/$chemin$fichier
# 	  fi
# 	else
# 	  action=`askuser "Copier" "Supprimer"`
# 	  if [ $action -eq 1 ]
# 	  then
# 	    cp $CHEMIN_A/$chemin$fichier $CHEMIN_B/$chemin$fichier
# 	  elif [ $action -eq 2 ]
# 	  then
# 	    rm $CHEMIN_A/$chemin$fichier
# 	  fi
# 	fi  
#       if [ -e $CHEMIN_B/$chemin$fichier ]
#       then
# 	echo "Le fichier $fichier existe dans B mais pas dans A."
# 	echo "Le fichier $fichier existe dans B mais pas dans A." >> $CHEMIN_SYNCHRO/synchro.log
# 	if [ $fichier -nt $JT -a $JB -nt $fichier -a $JB -nt $JA ] #Si le fichier est plus récent que .journalTemoin (cad le fichier est nouveau)
# 	then
# 	  if [ -d $CHEMIN_B/$chemin$fichier ]
# 	  then
# 	    cp -r $CHEMIN_B/$chemin$fichier $CHEMIN_A/$chemin$fichier
# 	  elif [ -f $CHEMIN_B/$chemin$fichier ]
# 	  then
# 	    cp -r $CHEMIN_B/$chemin$fichier $CHEMIN_A/$chemin$fichier
# 	  fi	
# 	elif [ $fichier -nt $JT -a $JA -nt $fichier -a $JA -nt $JB ] 
# 	then
# 	  if [ -d $CHEMIN_B/$chemin$fichier ]
# 	  then
# 	    rm -r $CHEMIN_A/$chemin$fichier
# 	  elif [ -f $CHEMIN_B/$chemin$fichier ]
# 	  then
# 	    rm $CHEMIN_B/$chemin$fichier
# 	  fi
# 	else
# 	  echo "Le fichier $fichier existe dans B mais pas dans A."
# 	  action=`askuser "Copier" "Supprimer"`
# 	  if [ $action -eq 1 ]
# 	  then
# 	    cp $CHEMIN_A/$chemin$fichier $CHEMIN_B/$chemin$fichier
# 	  elif [ $action -eq 2 ]
# 	  then
# 	    rm $CHEMIN_A/$chemin$fichier
# 	  fi
# 	fi  	
#       elif [ ! -e $CHEMIN_B/$chemin$fichier ] # S'il existe ni dans B ni dans A
#       then
# 	echo "Le fichier $fichier n'existe pas"
# 	echo "Le fichier $fichier n'existe pas" >> $CHEMIN_SYNCHRO/synchro.log
#       fi
  done
  makeJournal $CHEMIN_A > $JT #Màj, à ce stade p/A et p/B sont identiques
  rm $JA $JB $CHEMIN_SYNCHRO/JB_fake
}
#============================= Main ===============================================

main(){
  if [ -e $CHEMIN_SYNCHRO/synchro.log ]
  then
    rm $CHEMIN_SYNCHRO/synchro.log
    touch $CHEMIN_SYNCHRO/synchro.log
    echo "Synchronisation du $(date)" >> $CHEMIN_SYNCHRO/synchro.log
  fi
    
  echo -e "\nSynchronisation des racines...\n"
  if test "$(synchronize)" = "0"
  then
      sameContent $CHEMIN_SYNCHRO/JB_fake $JT
    echo "Les deux racines sont à jour."
  elif test "$(synchronize)" = "1"
  then
    #cat $CHEMIN_SYNCHRO/JB_fake;cat $JT
    echo -e "Les racines ne sont pas à jour.\nAnalyse..."
    echo -e "Nombre de fichiers:"
    NB_FICHIERSA=`cat $JA|cut -d " " -f 3|wc -l`
    NB_FICHIERSB=`cat $JB|cut -d " " -f 3|wc -l`
    NB_FICHIERST=`cat $JT|cut -d " " -f 3|wc -l`
    echo -e "racineA: $NB_FICHIERSA\nracineB: $NB_FICHIERSB\nracineT: $NB_FICHIERST\n"

    if [ $NB_FICHIERSA -ne $NB_FICHIERST ]
    then
      echo -e "Il y a $(( $(max $NB_FICHIERSA $NB_FICHIERST) - $(min $NB_FICHIERSA $NB_FICHIERST) )) fichiers d'écarts avec le journalTemoin dans la racine A.\n"
    elif [ $NB_FICHIERSB -ne $NB_FICHIERST ]
    then
      echo -e "Il y a $(( $(max $NB_FICHIERSB $NB_FICHIERST) - $(min $NB_FICHIERSB $NB_FICHIERST) )) fichiers d'écarts avec le journalTemoin dans la racine B.\n"
    fi
    
    echo "Fichiers à analyser: "
    echo `cat $JT|cut -d " " -f 3`    
    analyze
  fi
}

#============================= conf ==============================================
conf(){
  touch $CHEMIN_SYNCHRO/synchro.conf
  read -p "Chemin de l'arborescence A: " CHEMIN_A 
  read -p "Chemin de l'arborescence B: " CHEMIN_B
  read -p "Nom du fichier journal de A: " JA
  read -p "Nom du fichier journal de B: " JB
  read -p "Nom du fichier journal témoin: " JT
  echo $CHEMIN_A >> $CHEMIN_SYNCHRO/synchro.conf
  echo $CHEMIN_B >> $CHEMIN_SYNCHRO/synchro.conf
  echo $JA >> $CHEMIN_SYNCHRO/synchro.conf
  echo $JB >> $CHEMIN_SYNCHRO/synchro.conf
  echo $JT >> $CHEMIN_SYNCHRO/synchro.conf
}

#=============================== load ============================================
load(){

  CHEMIN_A="$(cat $CHEMIN_SYNCHRO/synchro.conf|head -1)"
  CHEMIN_B="$(cat $CHEMIN_SYNCHRO/synchro.conf|head -2|tail -1)"
  JA="$CHEMIN_SYNCHRO/$(cat $CHEMIN_SYNCHRO/synchro.conf|head -3|tail -1)"
  JB="$CHEMIN_SYNCHRO/$(cat $CHEMIN_SYNCHRO/synchro.conf|head -4|tail -1)"
  JT="$CHEMIN_SYNCHRO/$(cat $CHEMIN_SYNCHRO/synchro.conf|head -5|tail -1)"
}

#============================= Lancement du script ===============================
#Liste des options:
# -an    analyse
# -sync	 synchronisation
# -R     isMoreRecent
# -mkJ   makeJournal
# -sC    sameContent
# -sTy   sameType
# -sP    samePerm
# -sN	 sameNom
# -sTa	 sameTaille
# -sD	 sameDate
# -sM	 sameMeta
# -s	 same
# -set	 conf

clear;clear
echo -e "================================= Synchroniseur =================================\n\n"
if [ ! -e $CHEMIN_SYNCHRO/synchro.conf ]
then
  echo "Pour cette première utilisation, veuillez paramètrer le synchroniseur:"
  conf
elif [ -e $CHEMIN_SYNCHRO/synchro.conf ]
then
  load
fi

if [ $# -eq 0 ]
then
  main
else
  if [ "$1" = "-an" ] # Analyse
  then
    analyze
  elif [ "$1" = "-sync" ] # synchronize
  then
    echo -e "\nSynchronisation des racines...\n"
    if [ "$(synchronize)" = "1" ]
    then
      echo -e "Les racines ne sont pas à jour."
    elif [ "$(synchronize)" = "0" ]
    then
      echo "Les deux racines sont à jour."
    fi
  elif [ "$1" = "-R" ] # isMoreRecent
  then
    if [ -z "$2" -o -z "$3" ]
    then
      echo "Veuillez indiquer deux fichiers à comparer."  
    elif [ -f $2 ] 
    then
      if [ -f $3 ]
      then
	  if [ "`isMoreRecent $2 $3`" = "0" ]
	  then
	    echo "Les fichiers ont la même date de dernière modification."
	  elif [ "`isMoreRecent $2 $3`" = "1" ]
	  then
	    echo "Le fichier $2 est plus récent."
	  elif [ "`isMoreRecent $2 $3`" = "2" ]
	  then
	    echo "Le fichier $3 est plus récent."
	  fi
      else
	echo "$3 n'est pas un fichier"
      fi
    else
      echo "$2 n'est pas un fichier"
    fi
  elif [ "$1" = "-mkJ" ] # makeJournal
  then
    if [ -z "$2" ]
    then
      echo "Le chemin n'a pas été indiqué."
    elif [ $(echo "$2"|cut -c1-2) = "./" ]
    then
      makeJournal $(pwd)$(echo "$2"|cut -c2-)
    elif [ $(echo "$2"|cut -c1) = "/" ]
    then      
      makeJournal $2
    else
      echo "L'argument $2 n'est pas un chemin valide."
    fi
  elif [ "$1" = "-sC" ] # sameContent
  then
    if [ -z "$2" -o -z "$3" ]
    then
      echo "Veuillez indiquer deux fichiers à comparer."  
    elif [ -f $2 ]
    then
      if [ -f $3 ]
      then
	  if [ "`sameContent $2 $3`" = "0" ]
	  then
	    echo "Les fichiers $2 et $3 diffèrent en contenu."
	  elif [ "`sameContent $2 $3`" = "1" ]
	  then
	    echo "Les fichiers $2 et $3 sont identiques en contenu."
	  fi
      else
	echo "$3 n'est pas un fichier"
      fi
    else
      echo "$2 n'est pas un fichier"
    fi      
  elif [ "$1" = "-sTy" ] # sameType
  then
    if [ -z "$2" -o -z "$3" ]
    then
      echo "Veuillez indiquer deux fichiers ou répertoires à comparer."
    elif [ $(sameType $2 $3) -eq 1 ]
    then
      echo "Les fichiers $2 et $3 ont le même Type"
    elif [ $(sameType $2 $3) -ne 1 ]
    then
      echo "Les fichiers $2 et $3 n'ont pas le même Type"
    fi
  elif [ "$1" = "-sP" ] # samePerm
  then
    if [ -z "$2" -o -z "$3" ]
    then
      echo "Veuillez indiquer deux fichiers ou répertoires à comparer."
    elif [ $(samePerm $2 $3) -eq 1 ]
    then
      echo "Les fichiers $2 et $3 ont les mêmes Permissions"
    elif [ $(samePerm $2 $3) -ne 1 ]
    then
      echo "Les fichiers $2 et $3 n'ont pas les mêmes Permissions"
    fi
  elif [ "$1" = "-sN" ] # sameNom
  then
    if [ -z "$2" -o -z "$3" ]
    then
      echo "Veuillez indiquer deux fichiers ou répertoires à comparer."
    elif [ $(sameNom $2 $3) -eq 1 ]
    then
      echo "Les fichiers $2 et $3 ont le même Nom"
    elif [ $(sameNom $2 $3) -ne 1 ]
    then
      echo "Les fichiers $2 et $3 n'ont pas le même Nom"
    fi
  elif [ "$1" = "-sTa" ] # sameTaille
  then
    if [ -z "$2" -o -z "$3" ]
    then
      echo "Veuillez indiquer deux fichiers ou répertoires à comparer."
    elif [ $(sameTaille $2 $3) -eq 1 ]
    then
      echo "Les fichiers $2 et $3 ont la même Taille"
    elif [ $(sameTaille $2 $3) -ne 1 ]
    then
      echo "Les fichiers $2 et $3 n'ont pas la même Taille"
    fi
  elif [ "$1" = "-sD" ] # sameDate
  then
    if [ -z "$2" -o -z "$3" ]
    then
      echo "Veuillez indiquer deux fichiers ou répertoires à comparer."
    elif [ $(sameDate $2 $3) -eq 1 ]
    then
      echo "Les fichiers $2 et $3 ont le même Date"
    elif [ $(sameDate $2 $3) -ne 1 ]
    then
      echo "Les fichiers $2 et $3 n'ont pas le même Date"
    fi
  elif [ "$1" = "-sM" ] # sameMeta
  then
    if [ -z "$2" -o -z "$3" ]
    then
      echo "Veuillez indiquer deux fichiers ou répertoires à comparer."
    elif [ $(sameMeta $2 $3) -eq 1 ]
    then
      echo "Les fichiers $2 et $3 ont les mêmes Metadonnées"
    elif [ $(sameMeta $2 $3) -ne 1 ]
    then
      echo "Les fichiers $2 et $3 n'ont pas les mêmes Métadonnées"
    fi  
  elif [ "$1" = "-s" ] # same
  then
    if [ -z "$2" -o -z "$3" ]
    then
      echo "Veuillez indiquer deux fichiers ou répertoires à comparer."
    elif [ $(same $2 $3) -eq 1 ]
    then
      echo "Les fichiers $2 et $3 sont identiques."
    elif [ $(same $2 $3) -ne 1 ]
    then
      echo "Les fichiers $2 et $3 sont différents."
    fi      
  elif [ "$1" = "-set" ] # conf
  then
    echo "Configuration:"
    choix=$(askuser "Lire synchro.conf" "Modifier synchro.conf")
    if [ $choix -eq 1 ]
    then
      cat $CHEMIN_SYNCHRO/synchro.conf
    elif [ $choix -eq 2 ]
    then
      conf
    fi
  fi
fi












