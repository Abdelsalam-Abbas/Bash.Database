# Bash Database Script 



by
Abdelsalam Abbas 

Welcome to my guide for DATABASO’s script
this is a bash shell script to create simple database
enjoy:-


1) How to create table

	* Tables is created with only PK , you need to use alter to insert more columns
	Enter Table Name
	Enter Primary Key
	choose Primary Key Type (alpha , numeric , alphanumeric)

2) How to alter table

	1.Insert Column
        Enter Table Name
        Enter Record Name
        Choose if it can accept null by pressing (y) or press anything else to not accept null values
        Choose Primary Key Type (alpha , numeric , alphanumeric)
    2. Delete Column
        Enter Table Name
        Enter Record Name ( you can’t delete Primary key )
    3. Rename Column
        Enter old record name you want to change
        Enter new name 
    4. Back

3) How to Insert Data

    Enter Table Name
    Followed by every value for every column you are asked to enter 
	fields which accept null will accept no input from you
	field that require specific data type will only accept this type and prompt you to keep trying
	
	Whole record willnot be inserted till you finish all required fields 

4) how to Delete a record

	Enter Record’s Primary Key Value to Delete it 
		example : 1
		>>> this will delete the record which has the key “1” as primary key 

5) How to search ?????

	Enter table name	
  	insert column name followed by column value 
  		example: name ahmed
        >>> this will show every person whose name is ahmed
  	OR followed by condition column and condition value
  		example: name ahmed  salary 5000 
        >>> this will show every person whose name is ahmed and his salary equal 5000

6) How to display tables

	Enter table name
    Ta TATATaaa .. Table data shown…

7) How to update records

	Enter Table Name
	Enter Column Name Followed by New value
		example: name haneen
	Enter Where condition by “Column Name” and the condition value “ Column value”
		example: salary 500
        >>>> this will change every name to haneen when salary is equal 500
	NOTE: if you tried to update PK , it will only update first occurance to prevent repetition
	NOTE: if you tried to update PK with existing value for another PK , it will refuse
	CAUSTION: update doesn’t check for type of your ipnut ( alpha, numeric , alphanumeric)

8) How to truncate a table

	Enter table name
		“ Table Truncated Successfuly”

9) Exit

	quit Application 

10) Database
	you can change the current working DATABASE
	also create new one

			

									Thank you for reading my guide 
										Abd El-Salam Abbas
