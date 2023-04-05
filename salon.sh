#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo "Welcome to My Salon, how may I help you?\n" 
  fi

  DISPLAY_SERVICE
  read SERVICE_ID_SELECTED

  VALID_SELECTION=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $VALID_SELECTION ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_MENU $VALID_SELECTION
  fi

}


SERVICE_MENU() {
  # Get Phone Number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # If customer record doesn't exists
  if [[ -z $CUSTOMER_ID ]]
  then
    # Get Customer Name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # Enter customer record in table
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # get new customer Id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # get service id
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name='$1'")

  # set the appointment time
  echo -e "\nWhat time would you like your $1, $CUSTOMER_NAME?"
  read SERVICE_TIME
  
  # Create new appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")

  if [[ $INSERT_APPOINTMENT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $1 at $SERVICE_TIME, $CUSTOMER_NAME.\n"
  fi

}


DISPLAY_SERVICE() {
 
  # display available services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM SERVICES ORDER BY service_id")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

}

MAIN_MENU