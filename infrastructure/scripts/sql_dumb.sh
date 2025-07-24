sudo yum install -y git python3 python3-pip

sudo amazon-linux-extras enable postgresql13

sudo yum clean metadata

sudo yum install postgresql postgresql-devel -y

git clone https://github.com/jdedios-de/AWS_grocery.git

cd AWS_grocery

psql -h dev-db.chqwcogw4gyw.eu-central-1.rds.amazonaws.com -U grocery_user -d grocerymate_db -f backend/app/sqlite_dump_clean.sql

psql -h dev-db.chqwcogw4gyw.eu-central-1.rds.amazonaws.com -U grocery_user -d grocerymate_db -c "\dt"

