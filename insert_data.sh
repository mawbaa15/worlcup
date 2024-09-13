#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# 1. Vider les tables games et teams
echo $($PSQL "TRUNCATE TABLE games, teams")

# 2. Lire le fichier CSV et insérer les données
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Ignorer la première ligne (les en-têtes)
  if [[ $YEAR != "year" ]]
  then
    # 3. Ajouter les équipes dans la table teams

    # Vérifier si l'équipe gagnante existe déjà
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    # Si l'équipe gagnante n'existe pas, l'ajouter
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted team: $WINNER"
      fi
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # Vérifier si l'équipe adverse existe déjà
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    # Si l'équipe adverse n'existe pas, l'ajouter
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo "Inserted team: $OPPONENT"
      fi
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # 4. Ajouter le match dans la table games
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted game: $WINNER vs $OPPONENT, $YEAR - $ROUND"
    fi
  fi
done
