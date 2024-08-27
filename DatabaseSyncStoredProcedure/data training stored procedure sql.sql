create database sqlstoredproceduresdemo

use sqlstoredproceduresdemo

CREATE TABLE user_src (
    id INT NOT NULL IDENTITY(1,1),
    name VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE user_dest (
    id INT NOT NULL,
    name varchar(255) NOT NULL,
    timestamp datetime NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (id, timestamp)
);

insert into user_src (name) values ('Rahul'), ('Eren');

select * from user_src
select * from user_dest

CREATE or ALTER PROCEDURE SyncUserTables
AS
BEGIN
    -- Insert new rows
    INSERT INTO user_dest (id, name, timestamp)
    SELECT s.id, s.name, GETDATE()
    FROM user_src s
    LEFT JOIN (
        SELECT id, MAX(timestamp) as latest_timestamp
        FROM user_dest
        GROUP BY id
    ) d ON s.id = d.id
    WHERE d.id IS NULL;


	-- Insert updated rows
    INSERT INTO user_dest (id, name, timestamp)
    SELECT s.id, s.name, GETDATE()
    FROM user_src s
    INNER JOIN (
        SELECT id, name, timestamp
        FROM user_dest
        WHERE timestamp = (
            SELECT MAX(timestamp)
            FROM user_dest d2
            WHERE d2.id = user_dest.id
        )
    ) d ON s.id = d.id
    WHERE s.name != d.name;



END;

update user_src set name='Sena' where id = 1;


Exec SyncUserTables


---retrieve latest record
SELECT id, name, timestamp
FROM user_dest
WHERE timestamp IN (
    SELECT MAX(timestamp)
    FROM user_dest
    GROUP BY id
);