CREATE TABLE CONTRIBUTOR (
	ID			INT UNSIGNED NOT NULL AUTO_INCREMENT,
	ACRONYM		VARCHAR(255) NOT NULL UNIQUE,
	SHORT_NAME	VARCHAR(255) NOT NULL UNIQUE,
	FULL_NAME	VARCHAR(255) NOT NULL UNIQUE,
	PRIMARY KEY (ID)
);

CREATE TABLE COMPOUND (
	ID								INT	UNSIGNED NOT NULL AUTO_INCREMENT,
	CH_FORMULA						VARCHAR(600) NOT NULL,
	CH_EXACT_MASS					DOUBLE NOT NULL,
	CH_EXACT_MASS_SIGNIFICANT		INTEGER NOT NULL,
	CH_SMILES						VARCHAR(1200) NOT NULL,
	CH_IUPAC						VARCHAR(1200) NOT NULL,
	CH_CDK_DEPICT_SMILES 			VARCHAR(600),
	CH_CDK_DEPICT_GENERIC_SMILES	VARCHAR(600),
	CH_CDK_DEPICT_STRUCTURE_SMILES	VARCHAR(600),
	PRIMARY KEY (ID)
);

CREATE TABLE COMPOUND_CLASS (
	ID					INT	UNSIGNED NOT NULL AUTO_INCREMENT,
	DATABASE_NAME		VARCHAR(600),
	DATABASE_ID			VARCHAR(600),
	CH_COMPOUND_CLASS 	VARCHAR(600) NOT NULL,
	PRIMARY KEY (ID),
	UNIQUE (DATABASE_NAME(255), DATABASE_ID(255), CH_COMPOUND_CLASS(255))
);

CREATE TABLE COMPOUND_COMPOUND_CLASS (
	COMPOUND 	INT UNSIGNED NOT NULL,
	CLASS 		INT UNSIGNED NOT NULL,
	PRIMARY KEY (COMPOUND, CLASS),
	FOREIGN KEY (COMPOUND)
		REFERENCES COMPOUND(ID)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY (CLASS)
		REFERENCES COMPOUND_CLASS(ID)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
);

CREATE TABLE NAME (
	ID 			INT UNSIGNED NOT NULL AUTO_INCREMENT,
	CH_NAME		VARCHAR(600) NOT NULL,
	PRIMARY KEY (ID)
);

CREATE TABLE COMPOUND_NAME (
	COMPOUND	INT	UNSIGNED NOT NULL,
	NAME		INT UNSIGNED NOT NULL,
	PRIMARY KEY (COMPOUND, NAME),
	FOREIGN KEY (COMPOUND)
		REFERENCES COMPOUND(ID)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY (NAME)
		REFERENCES NAME(ID)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
);






CREATE TABLE CH_LINK (
	ID              INT	UNSIGNED NOT NULL AUTO_INCREMENT,
	COMPOUND 		INT	UNSIGNED NOT NULL,
	DATABASE_NAME	VARCHAR(600) NOT NULL,
	DATABASE_ID		VARCHAR(600) NOT NULL,
	PRIMARY KEY (ID, COMPOUND, DATABASE_NAME(255), DATABASE_ID(255)),
	FOREIGN KEY (COMPOUND)
		REFERENCES COMPOUND(ID)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE SAMPLE (
	ID					INT UNSIGNED NOT NULL AUTO_INCREMENT,
	SP_SCIENTIFIC_NAME	VARCHAR(600),
	SP_LINEAGE			VARCHAR(600),
	PRIMARY KEY (ID)
);

delimiter //
CREATE TRIGGER upd_check BEFORE INSERT ON SAMPLE
       FOR EACH ROW
       BEGIN
           IF ((NEW.SP_SCIENTIFIC_NAME IS NULL) AND (NEW.SP_LINEAGE IS NULL)) THEN
               SET NEW.ID = -1;
           END IF;
       END;//
delimiter ;

CREATE TABLE INSTRUMENT (
	ID					INT UNSIGNED 	NOT NULL	AUTO_INCREMENT,
	AC_INSTRUMENT 		VARCHAR(600)	NOT NULL,
	AC_INSTRUMENT_TYPE	VARCHAR(600)	NOT NULL,
	PRIMARY KEY (ID)
);



CREATE TABLE RECORD (
	ACCESSION										VARCHAR(255)	NOT NULL,
	RECORD_TITLE									VARCHAR(600)	NOT NULL,
	DATE											VARCHAR(600)	NOT NULL,
	AUTHORS											VARCHAR(600)	NOT NULL,
	LICENSE											VARCHAR(600)	NOT NULL,
	COPYRIGHT										VARCHAR(600),
	PUBLICATION										VARCHAR(600),
	CH												INT	UNSIGNED	NOT NULL,
	SP												INT UNSIGNED,
	AC_INSTRUMENT 									INT UNSIGNED	NOT NULL,
	AC_MASS_SPECTROMETRY_MS_TYPE					VARCHAR(600)	NOT NULL,
	AC_MASS_SPECTROMETRY_ION_MODE					VARCHAR(600)	NOT NULL,
	PK_SPLASH										VARCHAR(600)	NOT NULL,
	CONTRIBUTOR										INT UNSIGNED	NOT NULL,
	PRIMARY KEY (ACCESSION),
	FOREIGN KEY (CH)
		REFERENCES COMPOUND(ID)
		ON UPDATE CASCADE
		ON DELETE NO ACTION,
	FOREIGN KEY (SP)
		REFERENCES SAMPLE(ID)
		ON UPDATE CASCADE
		ON DELETE NO ACTION,
	FOREIGN KEY (AC_INSTRUMENT)
		REFERENCES INSTRUMENT(ID)
		ON UPDATE CASCADE
		ON DELETE NO ACTION,
	FOREIGN KEY (CONTRIBUTOR)
		REFERENCES CONTRIBUTOR(ID)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
);

CREATE TABLE DEPRECATED_RECORD (
	ACCESSION 										VARCHAR(255)	NOT NULL,
	CONTRIBUTOR										INT UNSIGNED	NOT NULL,
	CONTENT											MEDIUMTEXT
);

CREATE TABLE COMMENT (
	ID			INT UNSIGNED NOT NULL AUTO_INCREMENT,
	RECORD 		VARCHAR(255)		NOT NULL,
	COMMENT		VARCHAR(600)		NOT NULL,
	PRIMARY KEY (ID, RECORD, COMMENT(255)),
	FOREIGN KEY (RECORD)
		REFERENCES RECORD(ACCESSION)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);


CREATE TABLE SP_SAMPLE (
	ID          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
	RECORD 			VARCHAR(255)		NOT NULL,
	SP_SAMPLE		VARCHAR(600)		NOT NULL,
	PRIMARY KEY (ID, RECORD, SP_SAMPLE(255)),
	FOREIGN KEY (RECORD)
		REFERENCES RECORD(ACCESSION)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);
CREATE TABLE SP_LINK (
	RECORD 			VARCHAR(255)		NOT NULL,
	SP_LINK			VARCHAR(600),
	PRIMARY KEY (RECORD, SP_LINK(255)),
	FOREIGN KEY (RECORD)
		REFERENCES RECORD(ACCESSION)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE AC_MASS_SPECTROMETRY (
	ID          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
	RECORD 		VARCHAR(255)	NOT NULL,
	SUBTAG		VARCHAR(600)	NOT NULL,
	VALUE		VARCHAR(600)	NOT NULL,
	-- PRIMARY KEY (RECORD, SUBTAG),
	PRIMARY KEY (ID, RECORD, SUBTAG(255), VALUE(255)),
	FOREIGN KEY (RECORD)
		REFERENCES RECORD(ACCESSION)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE AC_CHROMATOGRAPHY (
    ID          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
	RECORD 		VARCHAR(255)	NOT NULL,
	SUBTAG		VARCHAR(600)	NOT NULL,
	VALUE		VARCHAR(600)	NOT NULL,
	-- PRIMARY KEY (RECORD, SUBTAG),
	PRIMARY KEY (ID, RECORD, SUBTAG(255), VALUE(255)),
	FOREIGN KEY (RECORD)
		REFERENCES RECORD(ACCESSION)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE MS_FOCUSED_ION (
	ID          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
	RECORD 		VARCHAR(255)	NOT NULL,
	SUBTAG		VARCHAR(600)	NOT NULL,
	VALUE		VARCHAR(600)	NOT NULL,
	PRIMARY KEY (ID, RECORD, SUBTAG(255), VALUE(255)),
	FOREIGN KEY (RECORD)
		REFERENCES RECORD(ACCESSION)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE MS_DATA_PROCESSING (
	ID          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
	RECORD 		VARCHAR(255)	NOT NULL,
	SUBTAG		VARCHAR(600)	NOT NULL,
	VALUE		VARCHAR(600)	NOT NULL,
	-- PRIMARY KEY (RECORD, SUBTAG),
	PRIMARY KEY (ID, RECORD, SUBTAG(255), VALUE(255)),
	FOREIGN KEY (RECORD)
		REFERENCES RECORD(ACCESSION)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE PEAK (
	RECORD 								VARCHAR(255)		NOT NULL,
	PK_PEAK_MZ 							DOUBLE 				NOT NULL,
	PK_PEAK_MZ_SIGNIFICANT				INTEGER 			NOT NULL,
	PK_PEAK_INTENSITY 					DOUBLE 				NOT NULL,
	PK_PEAK_INTENSITY_SIGNIFICANT		INTEGER 			NOT NULL,
	PK_PEAK_RELATIVE 					INTEGER 			NOT NULL,
	PRIMARY KEY (RECORD,PK_PEAK_MZ),
	FOREIGN KEY (RECORD)
		REFERENCES RECORD(ACCESSION)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE ANNOTATION_HEADER (
	RECORD VARCHAR(255) NOT NULL,
	HEADER VARCHAR(600) NOT NULL,
	PRIMARY KEY (RECORD),
	FOREIGN KEY (RECORD)
		REFERENCES PEAK(RECORD)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE ANNOTATION (
	RECORD 								VARCHAR(255)		NOT NULL,
	PK_PEAK_MZ 							DOUBLE 				NOT NULL,
	PK_PEAK_MZ_SIGNIFICANT				INTEGER 			NOT NULL,
	PK_ANNOTATION 						VARCHAR(600),
	PRIMARY KEY (RECORD, PK_PEAK_MZ, PK_ANNOTATION),
	FOREIGN KEY (RECORD)
		REFERENCES RECORD(ACCESSION)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE LAST_UPDATE (
	TIME TIMESTAMP,
	VERSION VARCHAR(100)
);

CREATE VIEW PK_NUM_PEAK AS 
	SELECT RECORD, COUNT(RECORD) AS PK_NUM_PEAK
	FROM PEAK
	GROUP BY RECORD;
