#!/bin/bash

base_dir=$(pwd)
CHEMIN=$1
cd $CHEMIN
ls -1p > $base_dir/nom0


#######################################################
# NOM 

listernom(){
  cd $1 
  ls -1p > $CHEMIN/nom1
  #ap |sed -e '1d' -e '2d' > yo
  while read list 
  do
    if [[ "$list" =~ /$ ]]
    then
      nbfich1=$(ls -1 $list | sed '/\.$/d'|wc -l)
      if [ $nbfich1 -gt 0 ]
      then
	echo $list
	listernom $list
	cd ..
	else 
	echo $list
      fi
    else
      echo $list
    fi 
  done < $CHEMIN/nom1  >> $CHEMIN/nom
}

while read line
do

	if [[ "$line" =~ /$ ]]
	then
	nbfich=$(ls -1 $line | sed '/\.$/d'|wc -l)
		if [ $nbfich -gt 0 ]
		then
		echo $line
		#cd $line
		listernom $line
		cd ..
		else 
		echo $line
		fi
	else
	echo $line
	fi

done < $base_dir/nom0 >> $CHEMIN/nom
#cat $CHEMIN/nom
#wc -l < $CHEMIN/nom
rm $CHEMIN/nom1

###############################################################
# TAILLE 

listertaille(){

cd $1 
ls -1p > $CHEMIN/nom1

#ap |sed -e '1d' -e '2d' > yo
while read list 
do
if [[ "$list" =~ /$ ]]
	then
	nbfich1=$(ls -1 $list | sed '/\.$/d'|wc -l)
		if [ $nbfich1 -gt 0 ]
		then
		ls -lph | grep -w "$list" | awk '{print $5}'
		listertaille $list
		cd ..
		else 
		ls -lph | grep -w "$list" | awk '{print $5}'
		fi
else

ls -lh $list | grep -w "$list" | awk '{print $5}'
fi 
done < $CHEMIN/nom1  >> $CHEMIN/taille
}

while read line
do


	if [[ "$line" =~ /$ ]]
	then
	nbfich=$(ls -1 $line | sed '/\.$/d'|wc -l)
		if [ $nbfich -gt 0 ]
		then

		ls -lph | grep -w "$line" | awk '{print $5}'
		listertaille $line
		cd ..
		else 
		ls -lph | grep -w "$line" | awk '{print $5}'
		fi
	else
	ls -lh $line | grep -w "$line" | awk '{print $5}'
	fi

done < $base_dir/nom0 >> $CHEMIN/taille
#cat $CHEMIN/taille
#wc -l < $CHEMIN/taille

rm $CHEMIN/nom1
########################################################
# Permission

listerpermission(){

cd $1 

ls -1p > $CHEMIN/nom1

#ap |sed -e '1d' -e '2d' > yo
while read list 
do
if [[ "$list" =~ /$ ]]
	then
	nbfich1=$(ls -1 $list | sed '/\.$/d'|wc -l)
		if [ $nbfich1 -gt 0 ]
		then
		ls -lp | grep -w "$list" | cut -c 2-10 
		listerpermission $list
		cd ..
		else 
		ls -lp | grep -w "$list" | cut -c 2-10

		fi
else

ls -l $list | grep -w "$list" |cut -c 2-10
fi 
done < $CHEMIN/nom1  >> $CHEMIN/permission
}

while read line
do


	if [[ "$line" =~ /$ ]]
	then
	nbfich=$(ls -1 $line | sed '/\.$/d'|wc -l)
		if [ $nbfich -gt 0 ]
		then
		ls -lp | grep -w "$line" | cut -c 2-10
		listerpermission $line
		cd ..
		else 
		ls -lp | grep -w "$line" | cut -c 2-10
	
		fi
	else
ls -lp $line | grep -w "$line" |cut -c 2-10
	fi

done < $base_dir/nom0 >> $CHEMIN/permission

#cat $CHEMIN/permission
#wc -l < $CHEMIN/permission
rm $CHEMIN/nom1

###################################################################
# type

listertype(){

cd $1 

ls -1p > $CHEMIN/nom1

#ap |sed -e '1d' -e '2d' > yo
while read list 
do
if [[ "$list" =~ /$ ]]
	then
	nbfich1=$(ls -1 $list | sed '/\.$/d'|wc -l)
		if [ $nbfich1 -gt 0 ]
		then
		ls -lp | grep -w "$list" | cut -c 1-1
		listertype $list
		cd ..
		else 
		ls -lp | grep -w "$list" | cut -c 1-1

		fi
else

ls -l $list | grep -w "$list" |cut -c 1-1
fi 
done < $CHEMIN/nom1  >> $CHEMIN/type
}

while read line
do


	if [[ "$line" =~ /$ ]]
	then
	nbfich=$(ls -1 $line | sed '/\.$/d'|wc -l)
		if [ $nbfich -gt 0 ]
		then
		ls -lp | grep -w "$line" | cut -c 1-1
		listertype $line
		cd ..
		else 
		ls -lp | grep -w "$line" | cut -c 1-1
	
		fi
	else
ls -lp $line | grep -w "$line" |cut -c 1-1
	fi

done < $base_dir/nom0 >> $CHEMIN/type

#cat $CHEMIN/type
#wc -l < $CHEMIN/type

rm $CHEMIN/nom1
############################################################
# Date 

listerDate(){

cd $1 
ls -1p > $CHEMIN/nom1

while read list 
do
if [[ "$list" =~ /$ ]]
	then
	nbfich1=$(ls -1 $list | sed '/\.$/d'|wc -l)
		if [ $nbfich1 -gt 0 ]
		then
		ls -lph | grep -w "$list" | awk '{print $7 " " $6 " " $8}'
		listerDate $list
		cd ..
		else 
		ls -lph | grep -w "$list" | awk '{print $7 " " $6 " " $8}'
		fi
else

ls -lh $list | grep -w "$list" | awk '{print $7 " " $6 " " $8}'
fi 
done < $CHEMIN/nom1  >> $CHEMIN/Date
}

while read line
do


	if [[ "$line" =~ /$ ]]
	then
	nbfich=$(ls -1 $line | sed '/\.$/d'|wc -l)
		if [ $nbfich -gt 0 ]
		then

		ls -lph | grep -w "$line" | awk '{print $7 " " $6 " " $8}'
		listerDate $line
		cd ..
		else 
		ls -lph | grep -w "$line" | awk '{print $7 " " $6 " " $8}'
		fi
	else
	ls -lh $line | grep -w "$line" | awk '{print $7 " " $6 " " $8}'
	fi

done < $base_dir/nom0 >> $CHEMIN/Date
#cat $CHEMIN/Date
#wc -l < $CHEMIN/Date

rm $CHEMIN/nom1

##########################################################
# chemin 

listerchemin(){

cd $1 
ls -1p > $CHEMIN/nom1
#ap |sed -e '1d' -e '2d' > yo
while read list 
do
if [[ "$list" =~ /$ ]]
	then
	nbfich1=$(ls -1 $list | sed '/\.$/d'|wc -l)
		if [ $nbfich1 -gt 0 ]
		then
		pwd 
		listerchemin $list
		cd ..
		else 
		pwd 
		fi
else

pwd 
fi 
done < $CHEMIN/nom1  >> $CHEMIN/chemin
}

while read line
do


	if [[ "$line" =~ /$ ]]
	then
	nbfich=$(ls -1 $line | sed '/\.$/d'|wc -l)
		if [ $nbfich -gt 0 ]
		then
		pwd 
		#cd $line
		listerchemin $line
		cd ..
		else 
		pwd 
		fi
	else
	pwd $line
	fi

done < $base_dir/nom0 >> $CHEMIN/chemin

#wc -l < $CHEMIN/chemin

rm $CHEMIN/nom1
rm $base_dir/nom0

###############################################################

paste -d " " $CHEMIN/type $CHEMIN/permission $CHEMIN/nom $CHEMIN/taille $CHEMIN/Date $CHEMIN/chemin
rm $CHEMIN/nom $CHEMIN/taille $CHEMIN/type $CHEMIN/Date $CHEMIN/permission $CHEMIN/chemin




















