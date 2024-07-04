#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "Welcome to My Salon, how can I help you?\n"

  # Display available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID _ NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Get user input
  read SERVICE_ID_SELECTED

  # If input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # Send to main menu
    MAIN_MENU "That is not a valid service number."
  else
    # Check if the service exists
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    # If service doesn't exist
    if [[ -z $SERVICE_NAME ]]
    then
      # Send to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      # Get customer phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # Check if customer exists
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # If customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # Get new customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # Insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      # Get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # Get service time
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # Insert appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      # Confirm appointment
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU
