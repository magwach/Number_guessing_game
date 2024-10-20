#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

if [ ${#USERNAME} -gt 22 ]
then
  echo "The username should be less than 22 characters."
else
  USERNAME_RESULT=$($PSQL "SELECT name FROM users WHERE name = '$USERNAME';")

  if [[ -z $USERNAME_RESULT ]]
  then
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME');")
    echo "Welcome, $USERNAME! It looks like this is your first time here."

    echo "Guess the secret number between 1 and 1000:"
  else
    GAMES_PLAYED=$($PSQL "SELECT times_played FROM users WHERE name = '$USERNAME';")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name = '$USERNAME';")

    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    echo "Guess the secret number between 1 and 1000:"
  fi

  CURRENT_GUESSES=0

  while true
  do
    read USER_GUESS
    if ! [[ $USER_GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    else
      (( CURRENT_GUESSES++ ))

      if [[ $USER_GUESS -lt $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      elif [[ $USER_GUESS -gt $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      else
        echo "You guessed it in $CURRENT_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

        UPDATE_TIMES_PLAYED_RESULT=$($PSQL "UPDATE users SET times_played = times_played + 1 WHERE name = '$USERNAME';")
        
        BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name = '$USERNAME';")
        if [[ $CURRENT_GUESSES -lt $BEST_GAME || $BEST_GAME -eq 0 ]]
        then
          UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $CURRENT_GUESSES WHERE name = '$USERNAME';")
        fi
        break
      fi
    fi
  done
fi

