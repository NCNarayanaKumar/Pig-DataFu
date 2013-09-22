Pig-DataFu
==========

Toy examples of Pig udf

- DataBagEx.rb
 -- pigudf using ruby gem public_suffix for domain name parsing

HOW TO AUTO SHIP RUBY GEMS 
----------
(e.g., I had "require public_suffic" in DataBagEx.rb) 
Check out this awesome project:
https://github.com/jruby/warbler

Step 1: Create a directory called "bun", containing an empty, but executable (chmod +x) file 
(You can put code here if you need to share code between different projects, but if not, an empty file is fine. You just need at least one file to make Warbler happy.) 

Step 2: Create a Gemfile file. Containing the list of gems you need. Something like:
```
source 'https://rubygems.org'
gem 'awesome_print'
gem 'json'
gem 'public_suffix'
```

Step 3: type 
```
warbler jar
```
And you get a jar file with the code for all the gems you need.

Step 4: in the pig script, add:
```
REGISTER 'bun.jar';
```
