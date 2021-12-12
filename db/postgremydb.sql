CREATE TABLE articles (id INTEGER, magazines_id INTEGER, article_type_id INTEGER, author_id INTEGER, PRIMARY KEY (id));
CREATE TABLE magazines (id INTEGER, name CHARACTER VARYING(30), PRIMARY KEY (id));
CREATE TABLE article_types (id INTEGER, type CHARACTER VARYING(30), PRIMARY KEY (id));
CREATE TABLE author (id INTEGER, author CHARACTER VARYING(30), PRIMARY KEY (id));


INSERT INTO articles(id, magazines_id, article_type_id, author_id) VALUES (1, 1, 2, 3),   (2, 3, 3, 2),   (3, 2, 2, 4), (4, 1, 2, 3);
INSERT INTO article_types (id, type) VALUES (1, 'news'),   (2, 'tech'),   (3, 'entertainment');
INSERT INTO author (id, author) VALUES (1, 'Chappie'),   (2, 'Wall-e'),   (3, 'Atom'), (4, 'T1000');



\COPY magazines FROM '/home/vagrant/postgremagazines.csv' with CSV HEADER;