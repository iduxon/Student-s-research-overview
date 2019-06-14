
create db sem2014;
connect to sem2014;

CREATE BUFFERPOOL sembuffer SIZE 135536 PAGESIZE 32 K;
CREATE REGULAR TABLESPACE semspace PAGESIZE 32 K BUFFERPOOL sembuffer; 

drop table dosije; 
CREATE TABLE DOSIJE
       (INDEKS   SMALLINT    NOT NULL ,
        GOD   SMALLINT NOT NULL ,
        IME    CHARACTER (15)  NOT NULL ,
        PREZIME  CHARACTER (20)  NOT NULL ,
        EADRESA  CHARACTER (40)  NOT NULL ,
		USERID   CHARACTER (15)  NOT NULL ,
        SLIKA    BLOB   (200 K)  NOT  LOGGED  NOT  COMPACT ,            
        formatslike varchar(10)           ,
        PRIMARY KEY (INDEKS, GOD) ,
		FOREIGN KEY (USERID) REFERENCES AUTORIZACIJA,
        CONSTRAINT INDEKSGRANICA CHECK (indeks between 1 and 3000) ,
        CONSTRAINT GODGRANICA    CHECK ((god between 1980 and 2020) OR (GOD=0)))
        DATA CAPTURE NONE IN semspace;

drop table nastavnik; 
CREATE TABLE NASTAVNIK
       (ID_NASTAVNIKA   SMALLINT    NOT NULL ,
        IME    CHARACTER (15)  NOT NULL ,
        PREZIME  CHARACTER (20)  NOT NULL ,
        EADRESA  CHARACTER (40)  NOT NULL ,
		USERID   CHARACTER (15)  NOT NULL ,
        SLIKA    BLOB   (200 K)  NOT  LOGGED  NOT  COMPACT ,            
        formatslike varchar(10)           ,
        PRIMARY KEY (ID_NASTAVNIKA),
		FOREIGN KEY (USERID) REFERENCES AUTORIZACIJA)
        DATA CAPTURE NONE IN semspace;

drop table autorizacija;        
CREATE TABLE  AUTORIZACIJA
       (USERID   CHARACTER (15)  NOT NULL ,
        PASSWORD CHARACTER (20)  NOT NULL ,
        PRAVA    SMALLINT        NOT NULL ,  -- 0 for admins, 1 for teachers, 2 for students
        PRIMARY KEY (USERID))
        DATA CAPTURE NONE   IN semspace;

drop table predmet;
CREATE TABLE PREDMET (
       id_predmeta      integer      not null,
       sifra            varchar(20)  not null,
       naziv            varchar(200) not null,
       primary          key(id_predmeta)     ,
             constraint uk_sifra unique(sifra)       
                     )
        DATA CAPTURE NONE   IN semspace;

drop table upisan_kurs;
create table upisan_kurs (
       indeks           integer      not null,
       id_predmeta      integer      not null,
       id_nastavnika    smallint      not null,
       godina           smallint     not null,
       primary          key(indeks,id_predmeta,godina)
                         )        
	DATA CAPTURE NONE   IN semspace;
        
drop table domaci;
CREATE TABLE domaci
       (
        RBR        SMALLINT         NOT NULL,
		ID_NASTAVNIKA SMALLINT      NOT NULL,
		ID_PREDMETA SMALLINT        NOT NULL,
        NAZIV      CHARACTER (15)   NOT NULL,
        OBAVEZAN   CHAR(1)          NOT NULL,
        BROJSTUD   SMALLINT         NOT NULL,
        NAJMANJE   SMALLINT         NOT NULL,    -- min num of students who can solve a task
        NAJVISE    SMALLINT         NOT NULL,    -- max num of students who can solve a task     
        ROKPRIJAVE TIMESTAMP        NOT NULL,
        ROKPREDAJE TIMESTAMP        NOT NULL,    -- end date
        PUNNAZIV  VARCHAR(200)      NOT NULL,
        OPIS      VARCHAR(1000)     NOT NULL,
        PRIMARY KEY (RBR) 
       ) 
        DATA CAPTURE NONE   IN semspace;
        
drop table seminarski;
CREATE TABLE seminarski
       (
        RBR        SMALLINT         NOT NULL,
		ID_NASTAVNIKA SMALLINT      NOT NULL,
		ID_PREDMETA SMALLINT        NOT NULL,
        NAZIV      CHARACTER (15)   NOT NULL,
        OBAVEZAN   CHAR(1)          NOT NULL,
        BROJSTUD   SMALLINT         NOT NULL,
        NAJMANJE   SMALLINT         NOT NULL,    -- min num of students who can solve a task
        NAJVISE    SMALLINT         NOT NULL,    -- max num of students who can solve a task
        ROKPRIJAVE TIMESTAMP        NOT NULL,
        ROKPREDAJE TIMESTAMP        NOT NULL,    -- end date
        PUNNAZIV  VARCHAR(200)      NOT NULL,
        OPIS      VARCHAR(1000)     NOT NULL,
        PRIMARY KEY (RBR) 
       ) 
        DATA CAPTURE NONE   IN semspace;        

drop table odabranidomaci;
CREATE TABLE   odabranidomaci
       (
        RBR        SMALLINT         NOT NULL,
        USERID     CHARACTER (15)   NOT NULL,
        LOZINKA    CHARACTER(15)    NOT NULL,
        SPISAKDOSIJEA varchar(3000) NOT NULL,
        DATUMPRIJAVE TIMESTAMP      NOT NULL,
        PRIMARY KEY (RBR) 
       ) 
        DATA CAPTURE NONE   IN semspace;        

drop table odabraniseminarski;
CREATE TABLE   odabraniseminarski
       (
        RBR        SMALLINT         NOT NULL,
        USERID     CHARACTER (15)   NOT NULL,
        LOZINKA    CHARACTER(15)    NOT NULL,
        SPISAKDOSIJEA varchar(3000) NOT NULL,
        DATUMPRIJAVE TIMESTAMP      NOT NULL,
        PRIMARY KEY (RBR) 
       ) 
        DATA CAPTURE NONE   IN semspace;        

drop table predatdomaci;
CREATE TABLE   predatdomaci
       (
        RBR        SMALLINT         NOT NULL,
        VREME      TIMESTAMP        NOT NULL,
        IZVESTAJ   VARCHAR(6000)    NOT NULL,  -- student report
        KOMENTARN  VARCHAR(4000)    NOT NULL,  -- teacher comment
        BROJBODOVA SMALLINT         NOT NULL,
        OCENA      smallint         not null,
        RESENJE    BLOB   (1 M)  NOT  LOGGED  NOT  COMPACT ,            
        PRIMARY KEY (RBR,vreme) ,
        CONSTRAINT OCENAGRANICA CHECK (ocena between 5 and 10) ,
        CONSTRAINT bodoviGRANICA    CHECK (brojbodova between 0 and 30)
       )  
        DATA CAPTURE NONE   IN semspace;        

drop table predatseminarski;
CREATE TABLE   predatseminarski
       (
        RBR        SMALLINT         NOT NULL,
        VREME      TIMESTAMP        NOT NULL,
        IZVESTAJ   VARCHAR(6000)    NOT NULL,  -- student report
        KOMENTARN  VARCHAR(4000)    NOT NULL,  -- teacher comment
        BROJBODOVA SMALLINT         NOT NULL,
        OCENA      smallint         not null,
        RESENJE    BLOB   (1 M)  NOT  LOGGED  NOT  COMPACT ,            
        PRIMARY KEY (RBR,vreme) ,
        CONSTRAINT OCENAGRANICA CHECK (ocena between 5 and 10) ,
        CONSTRAINT bodoviGRANICA    CHECK (brojbodova between 0 and 50)
       )
        DATA CAPTURE NONE   IN semspace;      
        
drop table prisutnost;
CREATE TABLE  PRISUTNOST
       (INDEKS   SMALLINT        NOT NULL ,
        GOD      SMALLINT        NOT NULL ,
	ID_NASTAVNIKA SMALLINT   NOT NULL,
	ID_PREDMETA SMALLINT     NOT NULL,
        datum    DATE            NOT NULL ,
        VREME    TIME            NOT NULL ,    -- class duration
        prisutan char(2)         NOT NULL ,
        OPRAVDANJE VARCHAR(300)  NOT NULL ,
        PRIMARY KEY (INDEKS, GOD, ID_PREDMETA, ID_NASTAVNIKA, DATUM, VREME),
	FOREIGN KEY (ID_NASTAVNIKA) REFERENCES NASTAVNIK,
	FOREIGN KEY (INDEKS, GOD) REFERENCES DOSIJE,
	FOREIGN KEY (ID_PREDMETA) REFERENCES PREDMET,
        CONSTRAINT INDEKSGRANICA CHECK (indeks between 1 and 3000) ,
        CONSTRAINT GODGRANICA    CHECK ((god between 1980 and 2020) OR (GOD=0)))
        DATA CAPTURE NONE IN semspace;

drop table aktivnosti;
CREATE TABLE  aktivnosti
       (INDEKS   SMALLINT        NOT NULL ,
        GOD      SMALLINT        NOT NULL ,
		ID_NASTAVNIKA SMALLINT   NOT NULL,
		ID_PREDMETA SMALLINT     NOT NULL,
        datum    TIMESTAMP       NOT NULL ,
        opis     varchar(4000)   NOT NULL ,
        BROJBODOVA SMALLINT         NOT NULL,
        OCENA      smallint         not null,
        REZULTAT BLOB   (1 M)  NOT  LOGGED  NOT  COMPACT ,                    
        PRIMARY KEY (INDEKS, GOD, ID_PREDMETA, ID_NASTAVNIKA, DATUM) ,
		FOREIGN KEY (ID_NASTAVNIKA) REFERENCES NASTAVNIK,
		FOREIGN KEY (INDEKS, GOD) REFERENCES DOSIJE,
		FOREIGN KEY (ID_PREDMETA) REFERENCES PREDMET,
        CONSTRAINT INDEKSGRANICA CHECK (indeks between 1 and 3000) ,
        CONSTRAINT GODGRANICA    CHECK ((god between 1980 and 2020) OR (GOD=0)),
        CONSTRAINT OCENAGRANICA CHECK (ocena between 5 and 10) ,
        CONSTRAINT bodoviGRANICA    CHECK (brojbodova between 0 and 40))
        DATA CAPTURE NONE IN semspace;
		
drop table istrazivackirad;
CREATE TABLE  istrazivackirad
       (
		ID_RADA SMALLINT 		NOT NULL,
		NAZIVRADA varchar(200) NOT NULL,
		SPISAKDOSIJEA varchar(3000) NOT NULL,
		ID_NASTAVNIKA SMALLINT ,
		ID_PREDMETA SMALLINT ,
        datum    TIMESTAMP       NOT NULL ,
        opis     varchar(4000)   NOT NULL ,
        BROJBODOVA SMALLINT,
        OCENA      smallint,
        RAD BLOB   (1 M)  NOT  LOGGED  NOT  COMPACT ,                    
        PRIMARY KEY (ID_RADA))
        DATA CAPTURE NONE IN semspace;
  
drop table izlaganjerada;
CREATE TABLE  izlaganjerada
       (ID_RADA SMALLINT 		NOT NULL,
		SPISAKDOSIJEA varchar(3000) NOT NULL,
		NAZIVKONF varchar(3000) NOT NULL,
		ID_NASTAVNIKA SMALLINT ,
		ID_PREDMETA SMALLINT ,
        DATUMKONF    TIMESTAMP       NOT NULL ,
        opis     varchar(4000)   NOT NULL ,                  
        PRIMARY KEY (ID_RADA, NAZIVKONF))
        DATA CAPTURE NONE IN semspace;