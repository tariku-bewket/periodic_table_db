#!/bin/bash

# It is expected this script to be called with an argument.  That argument 
# should be the atomic number, symbol or name of an element.  We will validate against
# the database elements table.

# Set up the variable to access the database;
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# First check that we got an argument, if not print the specified message and exit.
if [[ -z $1 ]]
then
# This is the error condition and we exit...
  echo -e "Please provide an element as an argument."
else
  # This is where any additional processing takes place.
  # An argument was passed but what was it?
  ELEMENT_INFO=$($PSQL "SELECT * FROM elements WHERE CAST(atomic_number AS VARCHAR) = '$1' OR symbol = '$1' OR name = '$1'")

  # If the result is empty then the argument passed was NOT an atomic number OR 
  # an element's symbol or an element's name.  Print the appropriate message and end.
  if [[ -z $ELEMENT_INFO ]]
  then
    echo -e "I could not find that element in the database."
  else 
    # Otherwise we DID find the element using one of the columns in the elements table.
    # Split the ELEMENT_INFO into the matching column values.
    # echo $ELEMENT_INFO
    # echo -e $ELEMENT_INFO | read NUMBER BAR SYMBOL BAR NAME
    NUMBER=$(echo $ELEMENT_INFO | sed -E 's/ \|.+//') 
    SYMBOL=$(echo $ELEMENT_INFO | sed -E 's/^[0-9]+ \| //' | sed -E 's/ \| [A-Za-z]+$//')
    NAME=$(echo $ELEMENT_INFO | sed -E 's/^.+\| //')
   
     # echo $NUMBER 
     # echo $SYMBOL
     # echo $NAME
        
    # Go get the property element for the element that was submitted. 
    # Don't retrieve atomic_number as we already have it.
    PROPERTY_INFO=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number = CAST('$NUMBER' AS INT)")
    # echo $PROPERTY_INFO

    # Split the line apart using sed.
    ATOMIC_MASS=$(echo $PROPERTY_INFO | sed -E 's/ \| [0-9.\-]+ \| [0-9.\-]+ \| [0-9]+$//')
    MELTING_POINT_C=$(echo $PROPERTY_INFO |  sed -E 's/^[0-9.]+ \| //' | sed -E 's/ \| [-0-9.]+ \| [0-9]+$//')
    BOILING_POINT_C=$(echo $PROPERTY_INFO | sed -E 's/^[0-9.]+ \| [0-9.\-]+ \| //' | sed -E 's/ \| [0-9]+$//')
    TYPE_ID=$(echo $PROPERTY_INFO | sed -E 's/^[0-9.]+ \| [0-9.\-]+ \| [0-9.\-]+ \| //')

    # echo $ATOMIC_MASS
    # echo $MELTING_POINT_C
    # echo $BOILING_POINT_C
    # echo $TYPE_ID

    # Finally get the type based on the value of type_id. 
    # Trim the leading sapce off of the type.
    TYPE=$($PSQL "SELECT type FROM types WHERE type_id = '$TYPE_ID'" | sed 's/^ //')
    # echo $TYPE

    # Finally we can report the results to the user...
    echo -e "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_C celsius and a boiling point of $BOILING_POINT_C celsius."
  fi
fi