CREATE TABLE IF NOT EXISTS recommendationTable (
   user_email VARCHAR ( 255 ) UNIQUE NOT NULL,
   service_id VARCHAR ( 255 ) UNIQUE NOT NULL,
   visits INT NOT NULL,

   PRIMARY KEY (user_email, service_id)
);