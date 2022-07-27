# Drop the student Database, if One Exists
DROP SCHEMA IF EXISTS airline;

# Create the Database
CREATE DATABASE airline;

# Specify to Use the airline Database
USE airline;

# Create the Relations
# Passenger Information Relation
CREATE TABLE passenger_info (
	passengerID INT NOT NULL AUTO_INCREMENT,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    age INT NOT NULL,
    UNIQUE KEY (firstName, lastName, address, age),
    PRIMARY KEY (passengerID)
    );

# Seat Relation
CREATE TABLE seats (
	class VARCHAR(100) NOT NULL,
    seatNumber VARCHAR(10) NOT NULL,
    PRIMARY KEY (seatNumber)
    );

# Airports Relation
CREATE TABLE airports (
	airportID CHAR(3) NOT NULL,
    PRIMARY KEY (airportID)
	);

# Flights Relation
CREATE TABLE flights (
	flightID INT NOT NULL AUTO_INCREMENT,
	departureTime DATETIME NOT NULL,
    originAirport CHAR(3) NOT NULL,
    destinationAirport CHAR(3) NOT NULL,
    PRIMARY KEY (flightID),
    UNIQUE KEY (departureTime, originAirport, destinationAirport),
    FOREIGN KEY (originAirport) REFERENCES airports(airportID),
    FOREIGN KEY (destinationAirport) REFERENCES airports(airportID)
    );

# Reservation Relation
CREATE TABLE reservations (
	reservationID  INT NOT NULL AUTO_INCREMENT,
	passengerID INT NOT NULL,
    flightID INT NOT NULL,
	originAirport CHAR(3) NOT NULL,
    destinationAirport CHAR(3) NOT NULL,
    departure DATETIME NOT NULL,
    class VARCHAR(100) NOT NULL,
    bookingTime TIME NOT NULL,
    npass INT NOT NULL,
    PRIMARY KEY (reservationID),
    FOREIGN KEY (passengerID) REFERENCES passenger_info(passengerID),
    FOREIGN KEY (flightID) REFERENCES flights(flightID),
	FOREIGN KEY (originAirport) REFERENCES airports(airportID),
    FOREIGN KEY (destinationAirport) REFERENCES airports(airportID)
	);

# Seats on Flights Relation
## Created within the Python Code

# Check-In Relation
## Created within the Python Code
##### Demonstrate checkIn_passenger Function Works
SELECT * FROM checkIn WHERE checkedIn = 1;

#--------------------------------------------------------------------------
# SQL QUERIES
##(1) Show the flight schedule between two airports between two dates
##### Between Maynard H Jackson Jr International Terminal (Atlanta) and Los Angeles International Airport on Jan. 1, 2100 and Jan. 2, 2100
SELECT originAirport, destinationAirport, departureTime 
	FROM flights 
	WHERE ( (originAirport = 'ATL') OR (originAirport = 'LAX') ) 
	AND ( (destinationAirport = 'ATL') OR (destinationAirport = 'LAX') )
	AND ( (departureTime LIKE '2100-01-01%') OR (departureTime LIKE '2100-01-02%') );

    
##(2) Rank top 3 {source, destination} airports based on the booking requests for a week.
SELECT originAirport, destinationAirport, COUNT(seatNumber) AS numRequests
FROM checkIn
WHERE (departureTime LIKE '2100-01-01%') OR (departureTime LIKE '2100-01-02%') OR (departureTime LIKE '2100-01-03%')
		OR (departureTime LIKE '2100-01-04%') OR (departureTime LIKE '2100-01-05%') OR (departureTime LIKE '2100-01-06%')
			OR (departureTime LIKE '2100-01-07%')
GROUP BY originAirport, destinationAirport
ORDER BY numRequests DESC
LIMIT 3;


##(3) Next available (has seats) flight between given airports.
##### From Fort Lauderdale/Hollywood International Airport to Kaniel K. Inouye International Airport (Honolulu)
SELECT seats_on_flights.flightID, flights.originAirport, flights.destinationAirport, 
			flights.departureTime, COUNT(seats_on_flights.flightID) AS remainingSeats
FROM seats_on_flights
JOIN flights ON seats_on_flights.flightID = flights.flightID
WHERE originAirport = 'FLL'
AND destinationAirport = 'HNL'
AND passenger = 0
GROUP BY flightID
ORDER BY departureTime
LIMIT 1;


##(4) Average occupancy rate (%full) for all flights between two cities.
##### Between Newark Liberty International Airport and San Francisco International Airport
SELECT originAirport, destinationAirport, (COUNT(seatNumber)/(COUNT(DISTINCT flightID)*300))*100 AS '%full' 
FROM checkIn 
WHERE ( (originAirport = 'EWR') OR (originAirport = 'SFO') ) AND ( (destinationAirport = 'EWR') OR (destinationAirport = 'SFO') )
GROUP BY originAirport;