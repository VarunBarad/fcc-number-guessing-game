#!/bin/bash
set -e

echo -e "Enter your username:"
read entered_username

user_id=$(psql --username=freecodecamp --dbname=number_guess --quiet --no-align --tuples-only --field-separator ',' --command "select user_id from users where username = '$entered_username'")
if [[ -z "$user_id" ]]; then
	echo -e "Welcome, $entered_username! It looks like this is your first time here."
	psql --username=freecodecamp --dbname=number_guess --quiet --no-align --tuples-only --field-separator ',' --command "insert into users(username) values ('$entered_username')"
	user_id=$(psql --username=freecodecamp --dbname=number_guess --quiet --no-align --tuples-only --field-separator ',' --command "select user_id from users where username = '$entered_username'")
else
	number_of_games_played=$(psql --username=freecodecamp --dbname=number_guess --quiet --no-align --tuples-only --field-separator ',' --command "select coalesce(count(*), 0) from games where user_id = $user_id")
	best_game_guess_count=$(psql --username=freecodecamp --dbname=number_guess --quiet --no-align --tuples-only --field-separator ',' --command "select coalesce(min(number_of_guesses), 0) from games where user_id = $user_id")
	echo -e "Welcome back, $entered_username! You have played $number_of_games_played games, and your best game took $best_game_guess_count guesses."
fi

number_to_guess=$(($RANDOM%(1000)+1))
echo -e "Guess the secret number between 1 and 1000:"
read entered_guess
number_of_guesses_taken=1

while true; do
	if ! [ "$entered_guess" -eq "$entered_guess" ] 2>/dev/null; then
		echo -e "That is not an integer, guess again:"
	elif [[ "$entered_guess" -gt "$number_to_guess" ]]; then
		echo -e "It's lower than that, guess again:"
	elif [[ "$entered_guess" -lt "$number_to_guess" ]]; then
		echo -e "It's higher than that, guess again:"
	elif [[ "$entered_guess" -eq "$entered_guess" ]]; then
		break;
	fi
	read entered_guess
	number_of_guesses_taken=$((number_of_guesses_taken+1))
done

psql --username=freecodecamp --dbname=number_guess --quiet --no-align --tuples-only --field-separator ',' --command "INSERT INTO games (user_id, game_number, number_of_guesses) VALUES ($user_id, $number_to_guess, $number_of_guesses_taken)"
echo -e "You guessed it in $number_of_guesses_taken tries. The secret number was $number_to_guess. Nice job!"