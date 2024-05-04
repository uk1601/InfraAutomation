# webapp
## Build & Deploy Locally
1. `npm install` to in install all node modules
2. Make sure MySql is installed locally and running
3. Add an env file in the root folder and add DATABASE_URL
4. `npx prisma generate` to generate prisma client
5. `npm prisma db push` to push databse schema and any tables to mysql
## Build & Deploy Web application
1. `scp -r /path/to/your/project/folder username@your_droplet_ip:/path/on/your/droplet` copy your project to digital ocean droplet
2. `ssh root@<droplet ip address>` to ssh to your droplet
3. Add an env file in the root folder and add DATABASE_URL
4. `sudo apt update`
5. `sudo apt upgrade`
6. `sudo apt install mysql-server` to install sql
7. `sudo mysql_secure_installation` to add root user to sql
8. `sudo mysql` to test if sql working
9. `curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -`
10. `sudo apt-get install -y nodejs` to install node
11. `node -v` to test if node working
12. `sudo ufw allow 3000/tcp` to expose this port on the droplet
13. `npx prisma generate` to generate prisma client
14. `npm prisma db push` to push databse schema and any tables to mysql
15. `node build && node start` to get the project started 
