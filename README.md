# Petfinder API Example

Petfinder's API responses are rather arcane, especially when using JSON. Instead, this script uses the default XML responses and parses them into classes (using Nokogiri) that can generate links to the public pages for each pet/shelter on Petfinder. 

It runs in the terminal, but can easily be adapted for use in Rails. 
