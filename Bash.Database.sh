#! /bin/bash

############ DATABASE FOLDER ########################
echo "####################################################################"
echo "###################################################################"
echo "####### working on default database db, change it from 10 ########"
echo "#################################################################"
echo "################################################################"

if [[ ! -d ${HOME}/bash/db/ ]]
then
    mkdir -p ${HOME}/bash/db/ && folder=${HOME}/bash/db/
else
   folder=${HOME}/bash/db/ 
fi
##############################################################################
######################    Functions   ######################################
##########################################################################

create () {
    PS3="Main Menu>>>" 
    touch $folder$1
    touch $folder${1}_data
    echo "Enter your primary key"
    read key
    if [[ -n $key ]] 
    then
        key=${key}:n
        echo "Please choose data type"
        select i in alphapetical numeric alphanumeric
        do
            case $i in 
                alphapetical) key=${key}:alpha ; break ;;
                numeric) key=${key}:digit ; break ;;
                alphanumeric) key=${key}:alnum ; break ;;
            esac
        done
        echo $key > $folder$1
    else
        echo "Primary Key can't be NULL"
    fi
}

alter () {
    PS3="Alter Menu>>" 
    select i in "Insert Column" "Delete Column" "Rename Column" "Back"
    do
        case $i in
            "Insert Column") 
                echo "Enter table name" ; read name ;
                if [ ! -f $folder$name ] 
                then 
                    echo "Table NOT FOUND"
                else 
                    insert_column $name 
                fi ;; 
            "Delete Column") 
                echo "Enter table name" ; read name ;
                if [ ! -f $folder$name ] 
                then 
                    echo "Table NOT FOUND"
                else 
                    delete_column $name 
                fi ;; 
            "Rename Column") 
                echo "Enter table name" ; read name ;
                if [ ! -f $folder$name ] 
                then 
                    echo "Table NOT FOUND"
                else 
                    rename_column $name 
                fi ;; 
            Back) 
                PS3="Main Menu>>>" ; break ;;
        esac
    done
}

rename_column () { 
    PS3="Rename Column>"
    echo "Enter Old Record Name"
    read old
    echo "Enter New Record Name"
    read new
    ### check if old or new exit ###
    if [[ $(grep -w $old $folder$1) && ! $(grep -w $new $folder$1) ]]
    then
        sed  -i "s/^${old}:/${new}:/" "$folder$1"
        echo "Record Rename to $new"
        PS3="Alter Menu>>" 
    else
        echo "Invalid Name, Make sure this column exist and new name doesn't conflict with other columns"
        PS3="Alter Menu>>"
        ############## recall the function again ######
        ##  rename_column "$1"
    fi
}

delete_column () {
    
    PS3="Delete Menu>"
    echo "Enter Record Name"
    read record 
    ######### check if record exit and not PK #########
    
    if [[ $(grep -w $record $folder$1) ]] 
    then
        ######## delete record data file ########
        record_number=$(grep -now ^$record "$folder$1" | cut -c1)
        if [ $record_number != 1 ]
        then
            cut -d: -f-$(($record_number-1)),$(($record_number+1))- "$folder${1}_data" > tmp
            cp tmp "$folder${1}_data"
            ######## delete record rule file ######
            sed -i "/^$record/d" $folder$1
            PS3="Alter Menu>>" 
            echo "Record Deleted" 
        else 
           echo "You can't delete Primary Key,Otherwise Truncate the Table "  
        fi

    else
        echo "No Record Found" 
        PS3="Alter Menu>>"
    fi
}


insert_column () { ########## NEEDS TO MODIFY DATA AND INSERT Empty Values at least
    
    PS3="Insert Column's Menu>"   
    echo "Enter Record Name"
    read record
    if [[ $(grep -w $record $folder$1) ]]
    then
        echo "Name Exists, Please choose another one"
        PS3="Alter Menu>>"
    else
        echo "$record accept null?  y(yes), anything else to (no) "
        read naccept
        if [ $naccept == "y" ]
        then
            record=${record}:y
        else
            record=${record}:n
        fi

        echo "Please choose data type"
        select i in alphapetical numeric alphanumeric
        do
            case $i in 
                alphapetical) record=${record}:alpha ; break ;;
                numeric) record=${record}:digit ; break ;;
                alphanumeric) record=${record}:alnum ; break ;;
            esac
        done
        echo $record >> $folder$1

        if [[ $(wc -l $folder${1}_data | cut -c1) -ge 0 ]] 
        then
            sed -i 's/$/:@/' $folder${1}_data
        fi
        
        echo "Record Inserted Successfuly" 
        PS3="Alter Menu>>"
    fi
}


insert () {
    
    record=""
    count=0
    if [ -f $folder$1 ]
    then 
        touch $folder${1}_data
        while read line 
        do
            ############# read table columns & insert its value into an array to use it to check user input ###########
            IFS=':' read -r -a array <<< "$line"
            count=$((count+1)) ###### count to avoid repeated value for PK only ######
            ########### this check user input if it is unique or not for PK  #############
            ########### if it matche the type , and if it accept null or not #############
            echo " insert "${array[0]} 
            value="$" 

            while [[ ( -z "$value" && ${array[1]} == "n" ) || ( -n "$value" && ! $value =~ ^[[:${array[2]}:]]*$ ) || ( "$count" -eq 1 &&  $(cut -d: -f1 $folder${1}_data | grep -c -w "$value" ) -ge 1 ) ]]
            do 
                echo " Please Enter correct Data"
                read value </dev/tty
            done  
            
            if [ -z "$value" ]
            then
                record=${record}:@ ###########   insert "@" incase of null value 
            else
                record=${record}:${value}
            fi
        done < $folder$1
        ########### insert record inside data table ##########
        record=$(echo $record | cut -c2-)
        echo "$record" >> "$folder${1}_data"
    else
        echo "Table NOT FOUND"
    fi
}

display () {
    echo "********************************"
    echo "********** Columns *************"
    echo "********************************"
    cat "$folder$1" | sed 's/:n:/:NO NULL:/g' | sed 's/:y:/:NULL:/g' | column -s: -t 
    echo "********************************"
    echo "********** Records *************"
    echo "********************************"
    cat "$folder${1}_data" | sed 's/@/NULL/g' | column -ts:
}

search () {
    echo " ******************************************************"
    echo " ******************************************************"
    echo "  insert column name followed by column value "
    echo "  name ahmed"
    echo "  OR followed by condtion column and condition value"
    echo "  name ahmed  salary 5000 "
    echo "  this will show every person whose name is ahmed and his salary equal 5000" 
    echo " ******************************************************"
    echo " Enter data separated by space"    
    read key key_pattern column column_pattern  
    
    ################# SHORT SEARCH ####################
    # if user didn't enter enough values for 
    if [[ -z $column || -z $column_pattern ]]
    then
        key=$(grep -now ^$key "$folder$1" | cut -c1)
        echo -e "       Result      \n"        
        awk -F: '{if($'$key' == "'$key_pattern'")print}' $folder${1}_data | column -ts:
    # check if user entered 4 patterns    
    elif [[ -n $key && -n $key_pattern && -n $column && -n $column_pattern ]]
    then
    ################# LONG SEARCH  ####################
        key=$(grep -now ^$key "$folder$1" | cut -c1)
        column=$(grep -now ^$column "$folder$1" | cut -c1)
        echo -e "       Result      \n"        
        awk -F: '{if($'$key' =="'$key_pattern'" && $'$column' =="'$column_pattern'")print}' $folder${1}_data  | column -ts:
    else 
        echo " Not Enough parameters!"
    fi
    
}
delete_record () {
    PS3="Delete_record's Menu>>"   
    echo "Enter record primary key value to delete it"
    read record
    if [[ $(grep -w ^$record $folder${1}_data) ]]
    then
        sed -i "/^$record/d" $folder${1}_data
        echo "Record Deleted"
        PS3="Main Menu>>>"
    else
        echo "Record Not Found"
        PS3="Main Menu>>>" 
    fi 
}
update () {
    echo "Enter COLUMN NAME followed by NEW VALUE"
    read column new_value 
    echo "Enter the WHERE condition where COLUMN NAME followed by VALUE"
    read key key_value
    key=$(grep -now ^$key "$folder$1" | cut -c1)
    column=$(grep -now ^$column "$folder$1" | cut -c1)
    if [[ "$column" -eq 1 &&  "$(cut -d: -f1 $folder${1}_data | grep -c -w "$new_value" )" -ge 1 ]] 
    then
        echo "Invalid Input, Primary key must be unique" 
    elif [[ -z $column || -z $new_value || -z $key || -z $key_value ]]
    then
        echo "You didn't Enter the full requested data to complete the update"
    else
        if [[ "$column" -eq 1 ]]
        then
            limit=1
            echo "Only First Match will be updated to maintain Uniqueness"
        else
            limit=99999
        fi

        ######### this code allow the user to update only the first matched value for PK and not all of them to maintain the uniquness ######
        ######### and it allows to update every value for any other column while crtieria is matched #######################################
        ###################################################################################################################################
        ##################################################################################################################################
        awk -F: -v i=0 -v limit=$limit '{if($'$key' == "'$key_value'" && i < limit){sub($'$column',"'$new_value'");i++};print}' $folder${1}_data  > tmp 
        ######################## replace tmp file with original file to execute the changes #########
      cp tmp $folder${1}_data

    fi
    
}
################################## APPLICATION ################################
###############################################################################
###############################################################################
PS3="Main Menu>>>" 
select i in "Create Table" "Alter Table" Insert "Delete Record" Search "Display Table" Update "Truncate Table" Exit "Change Current DATABASE"
do 
    case $i in 
        "Create Table") 
            echo "Enter table name" ; read name  
            if [[ -f $folder$name ]]
            then 
                echo "Table Already Exist" 
            else
                create $name  #### to insert tables in a loop 
            fi ;; 
        "Alter Table") alter ;;
        Insert) 
            echo "Enter table name" ; read name
            if [[ ! -f $folder$name ]]
            then 
                echo "Table NOT FOUND"
            else 
                insert $name  
            fi ;; 
        "Delete Record") 
            echo "Enter table name" ; read name
            if [[ ! -f $folder$name ]]
            then 
                echo "Table NOT FOUND"
            else 
                delete_record $name  
            fi ;; 
        Search)  
            echo "Enter table name" ; read name
            if [[ ! -f $folder$name ]]
            then 
                echo "Table NOT FOUND"
            else 
                search $name  
            fi ;; 
        "Display Table")
            echo "Enter table name" ; read name 
            if [[ ! -f $folder$name ]]
            then 
                echo "Table NOT FOUND" 
            else
                display $name   
            fi ;; 
        Update) 
            echo "Enter table name" ; read name 
            if [[ ! -f $folder$name ]]
            then 
                echo "Table NOT FOUND" 
            else
                update $name   
            fi ;; 
        "Truncate Table") 
            echo "Enter table name" ; read name 
            if [[ ! -f $folder$name ]]
            then 
                echo "Table NOT FOUND" 
            else
                cat /dev/null > $folder${name}_data
                echo "Table Truncated"
            fi ;; 
        "Change Current DATABASE")
            echo "Enter Databse name" ; read db
            if [[ -d $db ]]
            then
                echo "Databse Changed, Currently working on $db"
            else
                echo "Database NOT FOUND, CREATE NEW ONE? y(YES),Any Key(NO)"
                read answer
                if [[ $answer == "y" ]]
                then
                    echo "Enter NAME for your database"
                    read folder
                    mkdir $folder && echo "Databse Created Successfuly"
               fi 
            fi ;;
        Exit) break ;;
    esac
done
