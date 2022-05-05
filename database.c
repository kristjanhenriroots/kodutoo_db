#include <stdio.h>
//#include <pgsql/libpq-fe.h>
#include <libpq-fe.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

#define ENTER(S) printf("Please enter %s:\n", S)
#define MAX 50
#define TEXTLEN 500			// for storing SQL queries

typedef struct info{		// database info
	PGconn *conn;			// connection to database
	char tables[7][15];		// storing all table names
} db_status_t;

int traffic_officer(db_status_t *DB, int mode, int type, char *return_value);

// function parameters for creating or updating an existing value, see create_movie for use of the enum
enum add_or_update		{add_new_value, update_existing_value, write_new_movie = 8};			
enum linked_data_mode	{data_not_linked = -1, manual, ask_user};								// used in linked_data (and true_id), manual won't ask user as it gets the ID itself
enum db_data_type		{movie, person, reviewer, review, genre, characters, movie_genres}; 	// same order as the char versions in struct db_status_t **tables
enum modify_mode		{add_data, remove_data, update_data};									// parameter for functions that determines mode 

// functions from  prod41.c, week 10, until line 108
char *readText(char *name){		// read text
	ENTER(name);
	char buf[TEXTLEN];
	fgets(buf, TEXTLEN, stdin);
	
	while(strlen(buf)>0 && (buf[strlen(buf) - 1] == '\n' || buf[strlen(buf) - 1] == '\r' || buf[strlen(buf) - 1] == ' '))
		buf[strlen(buf) - 1] = '\0';
	
	char *val = malloc(strlen(buf) + 1);
	strcpy(val, buf);
	return val;
}

char *readNum(char *name){		// read a decimal number
	ENTER(name);
	char buf[MAX];
	fgets(buf, MAX, stdin);

	double x = atof(buf);
	memset(buf, 0, MAX);
	sprintf(buf, "%g", x);

	char *val = malloc(strlen(buf) + 1);
	strcpy(val, buf);
	return val;
}

char *readInt(char *name){		// read an integer number
	ENTER(name);
	char buf[MAX];
	fgets(buf, MAX, stdin);

	int x = atoi(buf);
	memset(buf, 0, MAX);
	sprintf(buf, "%d", x);

	char *val = malloc(strlen(buf) + 1);
	strcpy(val, buf);
	return val;
}

PGconn *openConnection(const char *connstr){	// open connection to database
	PGconn *conn;
	conn = PQconnectdb(connstr);
	if (PQstatus(conn) == CONNECTION_BAD) {
		printf("No connection\n");
		return NULL;
	}
	return conn;
}

void update(PGconn *c, char *query, int parcount, const char **params){	// send query to database
	PGresult *res;
	res = PQexecParams(c, query, parcount, NULL, params, NULL, NULL, 0);	
	if(PQresultStatus(res) == PGRES_FATAL_ERROR) {
		printf("Failure (%s).\n", PQresultErrorMessage(res));
		return;
	}
	PQclear(res);
}

void display(PGconn *c, char *query){						// display query, only used in publisher printing, see publisher_average()
	PGresult *res;
	res = PQexec(c, query);
	if (PQresultStatus(res) != PGRES_TUPLES_OK) {
		printf("No result\n");
		return;
	}
	int row_count = PQntuples(res);
	int col_count = PQnfields(res);
	int row, col;
	for(col = 0; col < col_count; col++)					// modified to show cell headers
		printf("%-15s | ", PQfname(res, col));
	printf("\n");
	for(row = 0; row < row_count; row++){
		for(col = 0; col < col_count; col++)
			printf("%-15s | ", PQgetvalue(res, row, col));
		printf("\n");
	}
	PQclear(res);
}

// simple program to check if input value is within set bounds
// theory was to reduce if clauses but really not better
int val_check(int min, int max, int in){ 
	return !(in > max || in < min);
}

/*
	Main detailed view of a movie that has all related info
	Accessed from next function display_movie_list
	Creates separate tables from movies, related genres, actors, director

	*c	=	connection to database
	id	=	the ID of the movie that needs to be shown
*/
int main_movie_view(PGconn *c, int id){
	PGresult *detailed_res;
	int new_row_count, new_col_count, row, col;
	char movie_view_command[TEXTLEN];
	printf("selected id is %d\n", id);
	sprintf(movie_view_command, "SELECT movies.name, year, duration AS duration_in_minutes, studio, "		// all relevant movie data + director
								"people.name AS director, nationality, language, age_rating, imdb_score, short_description "
								"FROM movies, characters, people "
								"WHERE movies_id = %d AND movies.id = characters.movies_id "
								"AND characters.people_id = people.id AND profession = 'director'", id);
	detailed_res = PQexec(c, movie_view_command);
	if(PQresultStatus(detailed_res) != PGRES_TUPLES_OK) {
		printf("\nNo result creating detailed movie view\n");
		return 0;
	}

	new_row_count = PQntuples(detailed_res);
	new_col_count = PQnfields(detailed_res);
	printf("Info:\n");
	for(col = 0; col < new_col_count; col++){																// print movie data
		if(col == 4){ 																						// printing director, nationality immediately behind
			printf("%-20s : %s (%s)\n", PQfname(detailed_res, col), PQgetvalue(detailed_res, 0, col), PQgetvalue(detailed_res, 0, col + 1));
			col++;
		}
		else if(col + 1 == new_col_count) 																	// last row aka description, separate row
			printf("%-20s : \n%s\n", PQfname(detailed_res, col), PQgetvalue(detailed_res, 0, col));
		else
			printf("%-20s : %s\n", PQfname(detailed_res, col), PQgetvalue(detailed_res, 0, col));
	}
	PQclear(detailed_res);

	printf("\nGenres: ");																					// get linked genres

	sprintf(movie_view_command, "SELECT genres.name "														// get movies_id and genres_id 
								"FROM movie_genres "														// from movie_genres that match input movie ID
								"LEFT JOIN genres ON movie_genres.genres_id = genres.id "					// match IDs with actual genre names
								"WHERE movies_id = %d",
								id);
	printf("%s\n", movie_view_command);
	detailed_res = PQexec(c, movie_view_command);
	if(PQresultStatus(detailed_res) != PGRES_TUPLES_OK) {
		printf("\nNo result getting genres linked to movie\n");
		return 0;
	}
	new_row_count = PQntuples(detailed_res);
	new_col_count = PQnfields(detailed_res);
	if(new_row_count > 0){																					// won't print if there aren't any linked
		printf("%s", PQgetvalue(detailed_res, 0, 0));														// first row won't have a comma in front
		for(row = 1; row < new_row_count; row++)
			printf(", %s", PQgetvalue(detailed_res, row, 0));
	}
	
	PQclear(detailed_res);

	printf("\nCharacters:\n");																				// get characters linked to movie


	sprintf(movie_view_command, "SELECT characters.name, people.name, nationality "							// get people_id from characters that match movie ID
								"FROM characters "" LEFT JOIN people ON people_id = people.id "				// match IDs with names
								"WHERE movies_id = %d AND profession != 'director'", id);					// type can't be director
	detailed_res = PQexec(c, movie_view_command);
	if (PQresultStatus(detailed_res) != PGRES_TUPLES_OK) {
		printf("\nNo result getting characters linked to movie\n");
		return 0;
	}
	new_row_count = PQntuples(detailed_res);
	new_col_count = PQnfields(detailed_res);

	for(row = 0; row < new_row_count; row++){
		printf("%25s played by %s ", PQgetvalue(detailed_res, row, 0), PQgetvalue(detailed_res, row, 1));
		if(strlen(PQgetvalue(detailed_res, row, 2)) > 0)													// print nationality if there is one added
			printf("(%s)", PQgetvalue(detailed_res, row, 2));
		printf("\n");
	}

	PQclear(detailed_res);
	
	printf("\nReviews:\n");																					// print all reviews linked to movie

	sprintf(movie_view_command, "SELECT reviewer.name, publication, grade, text_review "					// find all from review with matching movie ID
								"FROM review "																// match IDs with reviewer names
								"LEFT JOIN reviewer ON reviewer_id = reviewer.id "					
								"WHERE movies_id = %d "
								"ORDER BY publication DESC NULLS LAST", id);								// critics with a publication will be listed first
	detailed_res = PQexec(c, movie_view_command);
	if(PQresultStatus(detailed_res) != PGRES_TUPLES_OK) {
		printf("\nNo result getting reviews linked to movie\n");
		return 0;
	}
	new_row_count = PQntuples(detailed_res);
	new_col_count = PQnfields(detailed_res);

	for(row = 0; row < new_row_count; row++){
		for(col = 0; col < new_col_count; col++){
			if(strlen(PQgetvalue(detailed_res, row, col)) < 1)												// line will be skipped if value is empty
				continue;																					// some values don't need to contain anything in reviews
			printf("%s\n", PQgetvalue(detailed_res, row, col));
		}
		printf("\n");
	}

	PQclear(detailed_res);
	return 0;
}

/*
	Displays all movies that match query,
	will give movie ID to main_movie_view for a detailed look
	Used in main view with menu option 1 and when searching from database

	*c		=	connection to database
	*query	=	search criteria for list
*/
int display_movie_list(PGconn *c, char *query){
	printf("	Entering function display_movie_list\n");
	PGresult *main_res;
	main_res = PQexec(c, query);
	if(PQresultStatus(main_res) != PGRES_TUPLES_OK){
		printf("No result displaying movies (display_movie_list)\n");
		return 0;
	}
	int row_count = PQntuples(main_res);					// query result rows and columns
	int col_count = PQnfields(main_res);
	if(row_count < 1){
		printf("No results\n");
		return 0;
	}
	int idx_to_id[row_count];								// for matching printed out numbers to actual ids in the database which might not be in a row
	int row, col;
	printf("     "); 										// leaving space for numbers, headings row won't have a number
	for(col = 0; col < col_count - 1; col++)				// print heading
		printf("%-25s | ", PQfname(main_res, col));
	printf("\n");
	for(row = 0; row < row_count; row++){					// print all matching movies numbered
		printf("%3d. ", row + 1);
		for(col = 0; col < col_count - 1; col++)			// the ID is also in the table but won't be shown, need it to match it to the row number
			printf("%-25s | ", PQgetvalue(main_res, row, col));
		idx_to_id[row] = atoi(PQgetvalue(main_res, row, col)); // current row as index, database ID as value
		printf("\n");
	}
	PQclear(main_res);
	int inloop = 1;
	int input;												// Let's let the user select a movie for a closer look
	printf("\nTo see more data about the film select the film number or any other number to return to the main menu\n");
	while(inloop){											// won't leave immediately if user wants to view multiple movies
		printf("Select movie: ");
		scanf("%d", &input);
		input--;
		if(val_check(0, row_count - 1, input)){				// is it an actual number on screen
			main_movie_view(c, idx_to_id[input]);			// open the detailed movie view, send movie ID
		}
		else
			break;											// incorrect value, returning to main menu
	}
	return 0;
}

/*
	*c		=	connection to database
	*type	=	table name where to search
	*query	=	the name that needs to be checked

	Function checks if given value is already present in database
	Used where names need to be unique, return the number of rows the query is present in
*/
int unique_value(PGconn *c, char *type, char *query){
	printf("	Entering function unique_value\n");
	PGresult *res;
	char search[MAX]; 
	sprintf(search, "select * from %s where name = '%s'", type, query);
	res = PQexec(c, search);
	if(PQresultStatus(res) == PGRES_FATAL_ERROR) {
		printf("Failure (%s).\n", PQresultErrorMessage(res));
		printf("Error searching for unique name (%s) from %s\n", query, type);
		return 0;
	}
	return PQntuples(res);		// 0 when the value is unique
}

/*
	Create new movies or update new movies in the database
	Everything is in a switch case for data updating in which case function will return formatted and checked value

	DB				=	struct storing connection and table names
	*given_value	=	give the value that will be updated, function is necessary for updating because it knows what format all the cells need to be
	mode			= 	adding a new movie / update an existing move
	id				=	what parameter starts the loop, if updating only the required field will be asked and checked
*/
int create_movie(db_status_t *DB, char *given_value, int mode, int id){ 		
	printf("	Entering function create_movie\n");
	getchar();
	int i = id;															// messing with values to find out what values are needed
	char **params = malloc(15 * sizeof(char *)); 						// assuming we need 8 params max for movies list, overkill
	int limit = mode + id;
	int infinite_loop = 0;
	
	if(given_value != NULL){
		printf("Expecting return value\n");								// a certain value is wanted from function !!!CHECK HERE IF THERE IS TIME!!!
		infinite_loop = 1;
	}
	
	printf("starting at %d ending at %d\n", i, limit);
	while(i < limit){
		switch(i){
			case 0:														// get movie name
				params[0] = readText("movie name");						
				if(unique_value(DB->conn, "movies", params[0])){ 		// checking if movie is already in the database
					printf("%s is already in the database!\n", params[0]);
					return 0;
				}
				if(strlen(params[0]) < 1){								// checking input length
					printf("Cannot be empty!\n");						// if there are no checks values can be empty
					return 0;
				}
				break;
			case 1:														// get year and check limits
				params[1] = readInt("year");							
				if(!val_check(0, INT_MAX, atoi(params[1]))){
					printf("Not allowed\n");
					return 0;
				}
				break;
			case 2:														// get duration and limits
				params[2] = readNum("duration");						
				if(!val_check(0, INT_MAX, atoi(params[2]))){
					printf("Not allowed\n");
					return 0;
				}
				break;													
			case 3:														// get studio
				params[3] = readText("studio");
				break;
			case 4:														// get language
				params[4] = readText("language");
				break;
			case 5:														// get age rating
				params[5] = readText("age rating");
				break;
			case 6:														// get IMDb score
				params[6] = readText("IMDb score");
				if(!val_check(0, 10, atoi(params[6]))){
					printf("Not allowed\n");
					return 0;
				}
				break;
			case 7:														// get short description
				params[7] = readText("short description");
				break;
		}
		i++;
	}
	
	printf("calc value %d\n", limit - mode);
	if(limit - mode == 2){												// one value was updated
		strcpy(given_value, params[id]);
		printf("returning value %s\n", given_value);
		return 1;														// return only the asked field
	}
	else if(given_value != NULL)
		strcpy(given_value, params[id]);
	for(int j = 3; j < 8; j++){											// empty values will be stored as NULL not enter
		if(strlen(params[j]) < 1){
			params[j] = NULL;											// easier to check if field is empty
		}
	}
																		// else a new movie was written and needs to be sent
	update(DB->conn, "INSERT INTO movies(name, year, duration, studio, language, age_rating, imdb_score, short_description) VALUES($1,$2,$3,$4,$5,$6,$7,$8)", 8, (const char **)params);
	if(infinite_loop == 0){
		printf("Would you like to link something to %s? y/n\n", params[0]);
	}
	free(params);
	return 1;
}

/*
	type	=	table type, movies, people...
	id		= 	the ID of the row the user wants to change
	DB		=	struct storing connection and table names

	Used for updating an existing value in the database
*/
int update_db_value(int type, int id, db_status_t *DB){
	if(id < 0)					// true_id failed
		return 0;	
	printf("	Entering function update_db_value\n");
	getchar();
	PGresult *res;
	char query[TEXTLEN];
	sprintf(query, "SELECT * FROM %s LIMIT 1", DB->tables[type]);
	res = PQexec(DB->conn, query);
	if(PQresultStatus(res) != PGRES_TUPLES_OK) {
		printf("Failed to get %s table cell names (update_db_value)\n", DB->tables[type]);
		return 0;
	}
	//int row_count = PQntuples(res);
	int col_count = PQnfields(res);
	char selected_col[MAX];								// column to be changed
	char new_value[MAX];								// new value to be added
	//int idx_to_id[row_count];							// for matching printed out numbers to actual ids in the database which might not be in a row
	int col, input;
	for(col = 1; col < col_count; col++)				// show all columns except ID to user
		printf("%d. %s\n", col, PQfname(res, col));
	printf("Select column to edit: ");
	scanf("%d", &input);
	if(!val_check(1, col_count, input)){				// checking if selected column is valid
		printf("Value not allowed\n");
		return 0;
	}
	strcpy(selected_col, PQfname(res, input));			// store column value
	printf("\nTrying to update column %s, table %s\n\n", selected_col, DB->tables[type]);
	
	
	PQclear(res);

	// switch case for all types
	switch(type){
		case movie:
			if(!create_movie(DB, new_value, update_existing_value, input - 1)){
					return 0; 										// some kind of error in reading
				}
				sprintf(query, 	"UPDATE %s "						// table name, held in struct, is 'type' input to function
								"SET %s = '%s' "						// user selected column and new value
								"WHERE id = %d"						// searching by the ID provided to the function
								, DB->tables[type], selected_col, new_value, id
				);
			break;
		case person:
			
			break;
		case reviewer:
			break;
		case genre:
			break;
	}
	
	printf("\nUpdate command is: %s\n\n", query);
	res = PQexec(DB->conn, query);
	/*	// faulty check? Always fails but the update works, tested with movie updating
	if(PQresultStatus(res) != PGRES_TUPLES_OK) {
		printf("Failed to send update command (update_db_value)\n");
		return 0;
	}
	*/
	PQclear(res);
	return 0;
}

/*
	DB 				= 	struct storing connection and table names
	*given_value	=	give the value that will be updated
	mode			= 	adding a new person / update an existing person
	id				=	what parameter starts the loop, if updating only the required field will be asked and checked
	table_type		=	shows if we need to create a genre, person or reviewer

	Used for creating a value with a unique single name, includes genres, people and reviewers
	Can make a new value or used for updating existing

	Returns 0 when updating goes wrong, needs to be checked, 1 if successful
*/
int create_with_single_named(db_status_t *DB, char *given_value, int mode, int id, int table_type){
	printf("	Entering function create_with_single_named\n");
	char **params = malloc(5 * sizeof(char*));
	if(params == NULL){
		printf("Error allocating memory (create_with_single_named)\n");
		return 0;
	}
	getchar();
	params[0] = readText("name");							// get name
	params[1] = NULL;
	if(unique_value(DB->conn, DB->tables[table_type], params[0])){ 	// checking if name is already in the database
		printf("%s is already in the database!\n", params[0]);
		return 0;
	}
	if(strlen(params[0]) < 1){
		printf("Name cannot be empty!\n");					// checking insert value length, cannot be empty
		return 0;
	}
	if(table_type == person){								// people table, ask for nationality
		params[1] = readText("nationality");
		if(strlen(params[1]) < 1)
			params[1] = NULL;					
	}
	
	if(mode == update_existing_value){						// updating value not adding
		strcpy(given_value, params[0]);
		//strcpy(given_value[1], params[1]);
		return 1;
	}
	if(given_value != NULL){								// updating value not adding
		strcpy(given_value, params[0]);
	}

															// adding a new value to database
	if(table_type == reviewer){								// inserted a critic, need to ask if 
		int reviewer_type;									// they're a 'professional' and have a publication
		printf("Are they an user (1) or a critic (2)?\n");	
		scanf("%d", &reviewer_type);
		if(reviewer_type == 1) 								// its an user, no publication
			params[1] = NULL;
		else{
			getchar();
			params[1] = readText("publication");			// critic, ask publication
			if(strlen(params[1]) < 1){
				printf("Name cannot be empty!\n");
				return 0;
			}
		}
		update(DB->conn, "INSERT INTO reviewer(name, publication) VALUES($1,$2)", 2, (const char **)params);
	}
	else if(table_type == person){
		char query[70];										
		sprintf(query, "INSERT INTO %s(name, nationality) VALUES($1, $2)", DB->tables[table_type]);
		update(DB->conn, query, 2, (const char **)params);
	}
	else{
		char query[MAX];										// query needs a dynamically changing table type
		sprintf(query, "INSERT INTO %s(name) VALUES($1)", DB->tables[table_type]);
		update(DB->conn, query, 1, (const char **)params);
	}
	
	free(params);
	return 0;
}

/*
	Used for finding element true ID when asking users which one to pick from list
	Returns -1 on failure, needs to be checked

	table_type	=	where to look
	linker_mod	=	used for searching linked data such as reviews, movie_genres or characters, is < 0 when data isn't linked
	DB			=	struct storing connection and table names
	if_ask_new	=	will be 1 when user can be asked if they want to create a new row,
					always 0 on updating and removing info, why ask to create a new row that you immediately want to delete
*/
int true_id(int table_type, int linker_mod, db_status_t *DB, int if_ask_new){
	printf("	Entering function true_id\n");
	PGresult *res;
	char query[TEXTLEN];
	int result;
	if(linker_mod < 0){																// simple universal query for data
		sprintf(query, 	"SELECT id, name FROM %s WHERE name IS NOT NULL", DB->tables[table_type]);	// get all rows from input table
	}
	else{
		switch(table_type){															// linked data needs special commands
			case review:															// because the data is linked between 3 tables
				sprintf(query, 	"SELECT reviewer_id, name, publication, grade FROM review "
								"LEFT JOIN reviewer ON review.reviewer_id = reviewer.id "	// link revies with reviewers
								"WHERE review.movies_id = %d ", linker_mod);
				break;
			case characters:
				sprintf(query, 	"SELECT people_id, characters.name, people.name, profession FROM characters "
								"LEFT JOIN people ON characters.people_id = people.id "		// link characters to people
								"WHERE characters.movies_id = %d", linker_mod);
				break;																
			case movie_genres:														
				sprintf(query, 	"SELECT genres_id, name FROM genres "
								"LEFT JOIN movie_genres ON movie_genres.genres_id = genres.id "
								"WHERE movie_genres.movies_id = %d", linker_mod);			// link movie_genres to genres
				break;
		}
	}
	printf("true_id query: %s\n", query);
	res = PQexec(DB->conn, query);
	if(PQresultStatus(res) != PGRES_TUPLES_OK) {
		printf("\nNo result trying to print all ids and names (true_id)\n\n");
		return -1;
	}
	int row, col, maxrow, selected_row; 
	int row_count = PQntuples(res);
	int col_count = PQnfields(res);
	if(row_count == 0)
		return -1;
	for(row = 0; row < row_count; row++){
		printf("%d.", row + 1);
		for(col = 1; col < col_count; col++)
			if(strlen(PQgetvalue(res, row, col)) > 0)
				printf(" %-25s |", PQgetvalue(res, row, col));
		printf("\n");
	}																				// print all names
	if(if_ask_new){
		printf("%d. ADD NEW\n", row + 1);											// option to automatically add new when wanted row doensn't exist
		maxrow = row_count + 1;
	}
	else
		maxrow = row_count;
	printf("Select row: ");														
	scanf("%d", &selected_row);	
	if(!val_check(1, maxrow, selected_row)){
		printf("Not allowed value\n");
		return -1;
	}
	selected_row--;
	/*
		Magic when it works but hard to fix
		Able to create linked data to data that is not yet 
		in the database.
		
		For example creating a character in a movie linked to a movie
		that doesn't exist yet played by a person that also doesn't exist.

		Will recursively loop deeper until completing queries backwards,
		drawback is that if the first character creation will fail the
		movie and person created will remain.
	*/
	if(selected_row == row_count){													// used like recursion? Function will call traffic_officer with
		PQclear(res);																// required data type, which can even call true_id again in itself
		char reach_around_result[MAX] = {" "};										// infinite recursion loops shouldn't be possible, I think
		traffic_officer(DB, add_data, table_type, reach_around_result);
		printf("reach around result %s\n", reach_around_result);
		sprintf(query, "SELECT id FROM %s WHERE name = '%s'", DB->tables[table_type], reach_around_result);
		printf("query: %s\n", query);
		res = PQexec(DB->conn, query);
		if(PQresultStatus(res) != PGRES_TUPLES_OK) {
			printf("\nNo result trying to print all ids and names (true_id)\n\n");
			return -1;
		}
		result = atoi(PQgetvalue(res, 0, 0));
	}
	else
		result = atoi(PQgetvalue(res, selected_row, 0));
	printf("return id %d\n", result);
	PQclear(res);
	return result;
}

/*
	Used for handling complex queries adding stuff with linked data
	like genres for movies where a separate table (movie_genres) links 
	a genre ID to a movie ID; a pain to make

	DB				=	struct storing connection and table names
	link_source		=	the table where the linked source is (the genre, people or reviewer table)
	link_dest		=	the table where the linked destination is (the movie table, possibility for more)
	link_table		=	the actual table linking the others by ID (movie_genres, characters)
	mode			=	if the user is here from the modify menu or from browing movies (in which case we know the movie ID)
	id				=	if the user got here from browsing menu it is the current movie's ID
	person_type		=	if a character is added it carries an enum for actor/actress/director
*/
int linked_data(db_status_t *DB, int link_source, int link_dest, int link_table, int mode, int id, int person_type){
	printf("	Entering function linked_data\n");
	getchar();
	printf("Select %s:\n", DB->tables[link_source]);
	int from_id, to_id;
	PGresult *res;

	from_id = true_id(link_source, data_not_linked, DB, 1);	// find out what the user wants, origin table
	if(from_id < 0)											// true_id failed, exit
		return 0;
	if(mode == manual)										// destination id already known as function parameter int id 
		to_id = id;
	else{													// ask user for destination, use true_id again
		printf("Select %s:\n", DB->tables[link_dest]);
		to_id = true_id(link_dest, data_not_linked, DB, 1);
		if(to_id < 0)
			return 0;
	}
	char query[TEXTLEN];
	sprintf(query, 	"SELECT * FROM %s WHERE %s_id = %d AND %s_id = %d", // I love modularity, checking if linked value would be unique, IDs cannot match
					DB->tables[link_table], DB->tables[link_dest], to_id, DB->tables[link_source], from_id);
	printf("unique value check query: %s\n", query);					// same genres can't be added to 1 movie, linking same person to movie
	
	res = PQexec(DB->conn, query);
	if(PQresultStatus(res) == PGRES_FATAL_ERROR) {
		printf("Failure (%s).\n", PQresultErrorMessage(res));
		printf("Error searching for unique name (linked_data))\n");
		return 0;
	}
	if(PQntuples(res) > 0){
		printf("Value already linked to table!!\n");					// value is already in table, exit
		return 0;
	}

	char **params = malloc(3 * sizeof(char*));

	switch(link_table){
		case movie_genres:												// linking genre id to movie id
			sprintf(query, "INSERT INTO movie_genres(genres_id, movies_id) VALUES (%d, %d)", from_id, to_id);
			printf("\nlinked data query: %s\n\n", query);
			update(DB->conn, query, 0, NULL);
			break;
		case characters:												// linking person id to movie id
			char person_types[3][10] = { {"actor"}, {"actress"}, {"director"} };
			int input;
			printf("Person type:\n1. Actor\n2. Actress\n3. Director\n");
			scanf("%d", &input);
			if(!val_check(1, 3, input))
				break;
			if(input < 3){
				getchar();
				params[0] = readText("character's name");				// its not a director, ask which character they played
				PGresult *res;
				sprintf(query, 	"SELECT * FROM characters WHERE name = '%s' "
								"AND movies_id = %d", params[0], to_id);
				printf("link_table character check: %s\n", query);
				res = PQexecParams(DB->conn, query, 0, NULL, NULL, NULL, NULL, 0);
				if(PQresultStatus(res) == PGRES_FATAL_ERROR) {
					printf("Failure (%s).\n", PQresultErrorMessage(res));
					printf("Failed to check unique character (linked_data)\n");
					return 0;
				}
				if(strlen(params[0]) < 1 || PQntuples(res) > 0)			// checking if character already exists in given movie
					return 0;
				PQclear(res);
			}
			else
				params[0] = NULL;			
			input--;
			sprintf(query, 	"INSERT INTO characters(name, people_id, movies_id, profession) "
							"VALUES ($1, %d, %d, '%s')", from_id, to_id, person_types[input]);
			printf("\nlinked data query: %s\n\n", query);
			update(DB->conn, query, 1, (const char**) params);
			break;
		case review:													// create a review and link it to reviewer and movie
			params[0] = readText("short review");
			params[1] = readText("grade 0.0 - 10");
			if(!val_check(0, 10, atoi(params[1]))){
				printf("Value not allowed\n");
				return 0;
			}
			sprintf(query, 	"INSERT INTO review(text_review, grade, movies_id, reviewer_id) "
							"VALUES ('%s','%s', %d, %d)", params[0], params[1], to_id, from_id);
			update(DB->conn, query, 0, NULL);

			break;
	}
	free(params);

	return 0;
}

/*
	Function used in deleting data
	if a person or character is being deleted I need to check if the person
	is a director in some movie or the character is a director

	IF ITS A PERSON ALL MOVIES LINKED TO THEM AS DIRECTOR WILL BE DELETED (including reviews and characters)
	IF ITS A CHARACTER SET AS DIRECTOR THE MOVIE IN THE TABLE AS movies_is WILL BE DELETED (including reviews and other characters, the director themself will remain in people table)

	ideally I would not let the user delete directors, I would ask them to update them, but that
	would make the update function a lot more complex and I don't have time

	mode				=	table where to delete data
	for_deletion		= 	the ID of the object needed to delete in 'mode' table	
	for_deletion_linker	=	if linked data is deleted I need 2 IDs
*/
int is_director(int mode, int for_deletion, int for_deletion_linker, db_status_t *DB){
	enum delete_mode{text_search = 1, list_search};
	PGresult *res;
	char query[TEXTLEN];
	switch(mode){
		case person:					// deleting person
			sprintf(query, 	"SELECT id FROM characters WHERE "
									"people_id = %d AND profession = 'director'", for_deletion);
			res = PQexec(DB->conn, query);
			if(PQresultStatus(res) == PGRES_FATAL_ERROR) {
				printf("Failure (%s).\n", PQresultErrorMessage(res));
				return -1;				// something went really wrong, return -1
			}
			if(PQntuples(res) > 0){		// Link up for deletion is a director link, movie and reviews for it will be deleted!! 
				sprintf(query, 		"DELETE FROM movies WHERE id IN ("				// nuking all movies with that person as director
									"SELECT DISTINCT movies_id FROM characters " 	// linked characters and reviews will be removed by database
									"WHERE profession = 'director' AND people_id = %d)", for_deletion);
				update(DB->conn, query, 0, NULL);
				PQclear(res);
				return 1;				// linked data deleted, return 1
			}		
		case characters:
			sprintf(query, 			"SELECT id FROM characters WHERE movies_id = %d AND "
									"people_id = %d AND profession = 'director'", for_deletion, for_deletion_linker);
			res = PQexec(DB->conn, query);
			if(PQresultStatus(res) == PGRES_FATAL_ERROR) {
				printf("Failure (%s).\n", PQresultErrorMessage(res));
				return -1;
			}
			if(PQntuples(res) > 0){		// Link up for deletion is a director link, movie and reviews for it will be deleted!! 
				sprintf(query, 		"DELETE FROM movies WHERE id = %d", for_deletion);
				update(DB->conn, query, 0, NULL);
				PQclear(res);
				return 1;
			}
	}
	PQclear(res);
	return 0;							// if input character or person is not a director returning 0 
}

/*
	DB 				= 	struct storing connection and table names
	table_type		=	shows what kind of table we need to look from

	Used for deleting rows from the database, user can either type in the name
	or have a list printed out where he will select the row number (depends on deletable data)
			____________________________________________________________________
	NOTE: 	|	In cases where there is linked data like characters and genres	|
			|	are linked to a movie the database itself will handle deleting	|
			|	the rest of it with CASCADES type in foreign keys				|
			|___________________________________________________________________|
*/
int database_delete(int table_type, db_status_t *DB){
	printf("	Entering function database_delete\n\n");
	enum delete_mode{text_search = 1, list_search};									// search modes, text_search means user knows the name, list_search will list all possible options
	char query[TEXTLEN];
	int mode, for_deletion, for_deletion_linker = 0;								// for_deletion_linker is for linked data that needs 2 IDs to remove from separate table

	if(table_type == review || table_type == characters || table_type == movie_genres || table_type == person){
		// Warn the user that deleting a person linked as director will wipe all movies linked to them
		if(table_type == characters || table_type == person)						// these options to not have the choice to type in what to remove
				printf("\nWARNING: Deleting a director will delete the movie and characters linked to it (actors remain)!!\n\n");
		for_deletion = true_id(movie, data_not_linked, DB, 0);						// same for all linked data, I need the movie ID first
		if(for_deletion < 0){ 														// true_id will return -1 if value not present
			printf("No results!\n");
			return 0;
		}
	}
	switch(table_type){																// all data that is linked to other data needs to be handled differently
		case review:																// deleting a review
			for_deletion_linker = true_id(review, for_deletion, DB, 0);
			sprintf(query, 	"DELETE FROM review WHERE movies_id = %d AND reviewer_id = %d", for_deletion, for_deletion_linker);
			break;
		case characters:															// deleting a character
			for_deletion_linker = true_id(characters, for_deletion, DB, 0);
			if(for_deletion_linker < 0){
				printf("No results!\n");
				return 0;
			}
			int result = is_director(review, for_deletion, for_deletion_linker, DB);// is it a director? in which case the whole movie gets wiped
			if(result)																
				return 0; 															// it is a director, movie delete, CASCADING foreign key will automatically delete characters
			else if(!result)														// it is not a director, just delete the character, movie intact
				sprintf(query, "DELETE FROM characters WHERE movies_id = %d AND people_id = %d", for_deletion, for_deletion_linker);
			else
				return 0;															// failure determining director
			break;
		case movie_genres:															// deleting a genre linked to a movie
			for_deletion_linker = true_id(movie_genres, for_deletion, DB, 0);
			sprintf(query, "DELETE FROM movie_genres WHERE movies_id = %d AND genres_id = %d", for_deletion, for_deletion_linker);
			break;
		case person:																// deleting a person
			for_deletion = true_id(table_type, data_not_linked, DB, 0);
			if(for_deletion < 0){ 													// true_id will return -1 if value not present
				printf("No results\n");
				return 0;
			}
			if(is_director(person, for_deletion, for_deletion_linker, DB) < 0)		// if its a director all movies will be deleted
				return 0;
			sprintf(query, "DELETE FROM %s WHERE id = %d", DB->tables[table_type], for_deletion);
			break;
		default:																	// its not linked_data, see traffic_officer for data creation and classes
			printf("Mode:\n1. I know the exact name\n2. Show me the list\n");		// ask user
			scanf("%d", &mode);
			
			if(mode == text_search){												// text search, will check first if name is present
				char **params = malloc(3 * sizeof(char*));
				if(params == NULL){
					printf("Error allocating memory (database_delete)\n");
					return 0;
				}
				getchar();
				params[0] = readText("name to remove");
				if(!unique_value(DB->conn, DB->tables[table_type], params[0])){	
					printf("There is no %s in the database!\n", params[0]);
					return 0;
				}
				sprintf(query, "DELETE FROM %s WHERE name = '%s'", DB->tables[table_type], params[0]);
				free(params);
			}
			else if(mode == list_search){											// list search, true_id() will handle it giving back the element ID
				for_deletion = true_id(table_type, data_not_linked, DB, 0);
				if(for_deletion < 0){ 												// true_id will return -1 if value not present or fails otherwise
					printf("No results\n");
					return 0;
				}				
				sprintf(query, "DELETE FROM %s WHERE id = %d", DB->tables[table_type], for_deletion);
			}
			else
				return 0;
			break;
	}
	if(for_deletion_linker < 0){
		printf("No results!\n");
		return 0;
	} 
	
	update(DB->conn, query, 0, NULL);
	return 0;
}

#define MSG(S) printf("\n\n%s:\n", S)

/*
	Literal traffic officer, handles access to all functions managing database data
	Separated to own function for ease of calling and recursion in true_id()

	Function parameters will determine what will be done with data and what table the user wants to access

	mode			=	add / remove / update
	type			=	movie / person / genre ...
	return_value	=	return is expected in function that called it, true_id recursion
*/
int traffic_officer(db_status_t *DB, int mode, int type, char *return_value){
	enum menu_selection{add_, remove_, update_};
	if(mode == remove_)
		database_delete(type, DB);
	else{
		switch(mode){
			case add_:
				switch(type){
					case movie:
						create_movie(DB, return_value, write_new_movie, 0);
						break;
					case person:
						create_with_single_named(DB, return_value, add_new_value, 0, type);
						break;
					case reviewer:
						create_with_single_named(DB, return_value, add_new_value, 0, type);
						break;
					case review:
						linked_data(DB, reviewer, movie, review, ask_user, 0, 0);
						break;
					case genre:
						create_with_single_named(DB, return_value, add_new_value, 0, type);
						break;
					case characters:
						linked_data(DB, person, movie, characters, ask_user, 0, 0);
						break;
					case movie_genres:
						linked_data(DB, genre, movie, movie_genres, ask_user, 0, 0);
						break;
				}
				break;
			case update_:
					update_db_value(type, true_id(type, data_not_linked, DB, 0), DB);
				break;
		}
	}
	return 0;
}

/*
	Function that determines user needs managing data,
	talks to traffic_officer
*/
int modify_data(db_status_t *DB){
	int rw_mode, type, max_val = 5;
	printf(	" 1. Add\n"
			" 2. Remove\n"
			" 3. Update\n"
	);
	scanf("%d", &rw_mode);					// determine read / write / update
	if(!val_check(1, 3, rw_mode)){
		printf("Invalid input\n");
		return 0;
	}
	rw_mode--;								
	printf(	"  1. Movie\n"
			"  2. Actor(ess) / Director\n"
			"  3. Reviewer\n"
			"  4. Review\n"	
			"  5. Genre in list\n"	
			
	);
	if(rw_mode != update_data){
		printf(
			"  6. Actor(ess) / Director link to movie\n"
			"  7. Genre link to movie\n"
		);
		max_val = 7;						// these options will not be available for updating, will have to delete
	}
	scanf("%d", &type);						// determine what table is needed
	if(!val_check(1, max_val, type)){ 
		printf("Invalid input\n");
		return 0;
	}
	type--;

	traffic_officer(DB, rw_mode, type, NULL);	
	return 0;
}

// make top 5 according to critics or users, requirement
int top_five(db_status_t *DB){
	int top_type;
	char is_or_isnt[2][6] = { {"IS"}, {"IS NOT"} };		// lazy but easy
	char query[TEXTLEN];
	printf("According to:\n1. Critics\n2. Users");
	scanf("%d", &top_type);
	if(!val_check(1, 2, top_type))
		return 0;
	sprintf(query, 	"SELECT movies.name, year, ROUND(AVG(grade), 2) "			// round average
					"AS avg_rating, movies.id FROM movies "
					"LEFT JOIN review ON movies.id = review.movies_id "			// link reviews table for movie grades and reviewer IDs
					"LEFT JOIN reviewer ON review.reviewer_id = reviewer.id "	// link reviewers table to find out if reviewer is an user or critic
					"WHERE reviewer.publication %s NULL "						// use is_or_isnt to add if publication is NULL or not
					"GROUP BY movies.id, movies.name, year "					// NULL publication if for users
					"ORDER BY avg_rating DESC NULLS LAST "						// order by grade, movies with no reviews last
					"LIMIT 5", is_or_isnt[top_type - 1]);						// LIMIT to 5 top results

	display_movie_list(DB->conn, query);										// make an interactive movie list
	return 0;
}

//used in both search functions, shows is search is by text or ID
enum db_search_mode{text_query = 1, direct_id};

/*
	All differet queries for added search types;
	just testing out SQL queries
	called in next function
*/
char* db_search_query_list(int table_type, int mode, char *category, char *equals){
	char movie_base[TEXTLEN] = { 	"SELECT name, year, id "							// regular movie search by name
									"FROM movies "
									"WHERE "
								};
	
	char person_base[TEXTLEN] = { 	"SELECT movies.name, year, " 						// Took a while to figure this one out.
									"CASE "												// so in the database when a person is a director
									"WHEN characters.name IS NULL THEN 'director' "		// linked to a movie the role is set as NULL,
									"ELSE characters.name "								// so this query uses a if clause to change it to director
									"END AS role, "										// and just shows the character name otherwise
									"people.name, movies.id "
									"FROM movies "
									"LEFT JOIN characters "
									"ON movies.id = characters.movies_id "				// joining together 3 tables to get the movie name
									"LEFT JOIN people "									// characters linked to the movie
									"ON characters.people_id = people.id "				// and the person's name
									"WHERE  "
								};
	
	char reviewer_base[TEXTLEN] = { "SELECT movies.name, year, reviewer.name, " 		// Same idea but with publication
									"CASE "												
									"WHEN reviewer.publication IS NULL THEN 'none' "		
									"ELSE reviewer.publication "								
									"END AS publication, "										
									"review.grade AS grading, movies.id "
									"FROM movies "
									"LEFT JOIN review "
									"ON movies.id = review.movies_id "				
									"LEFT JOIN reviewer "									
									"ON review.reviewer_id = reviewer.id "				
									"WHERE "
								};
	
	char genre_base[TEXTLEN] = { 	"SELECT movies.name, year, movies.id " 				// search movies by genre
									"FROM movies "
									"LEFT JOIN movie_genres "
									"ON movies.id = movie_genres.movies_id "
									"LEFT JOIN genres "
									"ON movie_genres.genres_id = genres.id "
									"WHERE "
								};

	char query_tail[MAX];

	if(mode == direct_id)
		sprintf(query_tail, "%s.id = %s", category, equals);							// endings of the queries on top, this case by id
	else
		sprintf(query_tail, "%s.name ILIKE '%%%s%%'", category, equals);				// search by name
	printf("Query end is %s\n", query_tail);	
	switch(table_type){
		case movie:
			return strcat(movie_base, query_tail);
		case reviewer:
			return strcat(reviewer_base, query_tail);									// mix and match correct combo
		case genre:
			return strcat(genre_base, query_tail);					
		default:			// person and character types have same query with different search type, characters.name or people.name
			return strcat(person_base, query_tail);
	}
}

/*
	Searching the database
	Will use movie list function for interactive results
*/
int db_search(db_status_t *DB){
	int search_criteria, search_mode;
	printf(			"Search by:\n"
					"1. Movie name\n"
					"2. Actor / Director\n"									// what are we searching
					"3. Reviewer\n"
					"4. Movie genre\n"
					"5. Character\n"
					"6. Year\n"
	);
	scanf("%d", &search_criteria);
	char query[TEXTLEN];
	int looking_for_id;
	if(search_criteria == 6){												// year search kind of bolted on as a last thing
		int year;
		printf("Enter year: ");
		scanf("%d", &year);
		sprintf(query, 	"SELECT name, year, ROUND(AVG(grade), 1) "				
						"AS avg_grade, movies.id FROM movies "
						"LEFT JOIN review ON movies.id = review.movies_id "	// link review table to movies to get average rating
						"WHERE year = %d "									// year we're looking for
						"GROUP BY movies.id, movies.name, year "		
						"ORDER by avg_grade DESC NULLS LAST", year);		// order by rating
		display_movie_list(DB->conn, query);
		return 0;
	}
	if(val_check(2, 4, search_criteria)){
		printf("  1. I know the name\n  2. Show me the list\n");			// ask for name or show list
		scanf("%d", &search_mode);
	}
	else if(search_criteria == 1 || search_criteria == 5)	// blocking off search with list with movies and characters
		search_mode = 1;									// characters can be the same between movies and a list would 
	else													// show all duplicates and the result would only be 1 movie.
		return 0;											// with movies you would see every movie, why search at all then?
	if(search_criteria < genre)								
			search_criteria--;	// converting it to the same order as db_data_type enum, can't search by review so the nr must be skipped

	switch(search_mode){
		case 1:												// searching by name
			printf("NOTE: Searching is case insensitive and should capture incomplete names\n"); // query is using ILIKE and '% %' so its possible
			getchar();
			char **buf = malloc(15 * sizeof(char *));
			buf[0] = readText("name to look for");
			if(strlen(buf[0]) < 1)
				return 0;
			strcpy(query, db_search_query_list(search_criteria, text_query, DB->tables[search_criteria], buf[0]));
			break;
		case 2:
			char num[15];
			looking_for_id = true_id(search_criteria, data_not_linked, DB, 0);
			if(looking_for_id < 0)
				return 0;
			sprintf(num,"%d", looking_for_id);
			strcpy(query, db_search_query_list(search_criteria, direct_id, DB->tables[search_criteria], num));
			break; 
	}
	display_movie_list(DB->conn, query);
	return 0;
}

// displaying publication average grades and reviewed movie count as a bonus, requirement for kodutöö
void publication_average(db_status_t *DB){
	char query[TEXTLEN] = {	"SELECT DISTINCT CASE "						// every publication once
							"WHEN publication IS NULL THEN 'users' "	// users have publication NULL, changing the name for visual purposes
							"ELSE publication "							// else show the publication
							"END AS publication, "						// cell heading is publication
							"ROUND(AVG(grade), 2) "						// round result
							"AS avg_rating, "
							"COUNT(DISTINCT review.movies_id) AS movies_reviewed " // count the unique movie count the publishing in question has reviewed
							"FROM reviewer "
							"LEFT JOIN review ON reviewer.id = review.reviewer_id "	// link reviews to reviewers to get average grades
							"GROUP BY publication "
							"ORDER by avg_rating DESC NULLS LAST"
							};
	display(DB->conn, query);
}

// Main menu legend
void helper_print(){
	printf(	"1: Browse database\n"
        	"2: Modify data (and add)\n"
        	"3: Leave a review\n"
        	"4: Search database\n"
        	"5: Top 5\n"
			"6: Publications\n"
        	"H: Help\n"
        	"X: Exit\n"
    );
}

int main(void){
	db_status_t DB;
	DB.conn = PQconnectdb("dbname=postgres host=localhost port=5432 user=postgres password=1146732");	// connection to database
	if (PQstatus(DB.conn) == CONNECTION_BAD) {
		printf("No connection.\n");
		return 0;
	}
	char table_types[7][15] = { {"movies"}, {"people"}, {"reviewer"}, {"review"}, {"genres"}, {"characters"}, {"movie_genres"} };
	// SQL query for list with all movies
	char master_list[TEXTLEN] = {	"SELECT name, year, ROUND(AVG(grade), 1) "				// making an average of all reviews, critics and users
									"AS avg_rating, movies.id FROM movies "
									"LEFT JOIN review ON movies.id = review.movies_id "		// using LEFT JOIN because a movie might not have reviews
									"GROUP BY movies.id, name, year "
									"ORDER BY avg_rating DESC NULLS LAST"					// top reviewed first, without reviews on the bottom
								};
	for(int i = 0; i < 7; i++)
		strcpy(DB.tables[i], table_types[i]);
	char input;
	int inloop = 1, loop = 0;
	helper_print();
	while(inloop){							// main menu
		if(inloop && loop){
			printf("back in main menu, press H for help\n");
		}
		loop = 1;
		scanf("%c", &input);
		switch(input){
			case '1':
				display_movie_list(DB.conn, master_list);
				break;
			case '2':
				modify_data(&DB);
				break;
			case '3':
				traffic_officer(&DB, 0, review, NULL);
				break;
			case '4':
				db_search(&DB);
				break;
			case '5':
				top_five(&DB);
				break;
			case '6':
				publication_average(&DB);
				break;
			case 'H':
				helper_print();
				break;
			case 'X':
				inloop = 0;
				break;
		}
	}
	PQfinish(DB.conn);
	return 0;
}