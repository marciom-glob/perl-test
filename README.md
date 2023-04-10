# perl-test

## Requiriments

- DBI
- DBD::SQLite
- Text::CSV
- Perl-Tk

## Description

This set of programs provides a way to search a List of restaurants of a area (in this case, Food Trucks in San Francisco). 
The programs are:

- The Loader (loader.pl): This program takes the CSV file on the data directory and import to a SQLite database located at db directory. The funcionality is very crude with minimal function
  - Todo:
    * more options for customizing
    * better error messages
    * provide a scheduling possibility

- The Interface (interface.pl): This program is a Tk interface for search and see the results for the database created from the Loader. Again, it's very simple and minimal with a good potential for became more functional
  - Todo:
    * New possibilities for search the database
    * show more fields in results

## Using the system

- Download the CSV file (https://data.sfgov.org/Economy-and-Community/Mobile-Food-Facility-Permit/rqzj-sfat/data)
- Put the file in data directory
- run loader.pl
'''
perl loader.pl
'''                
- After the charge
- Run interface.pl
'''
perl interface.pl
'''


