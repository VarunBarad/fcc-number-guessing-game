create database number_guess;

create table users(user_id serial primary key, username varchar(25) not null unique);
create table games(game_id serial primary key, user_id integer not null references users(user_id), game_number integer not null, number_of_guesses integer not null);