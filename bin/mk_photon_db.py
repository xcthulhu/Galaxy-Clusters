#!/usr/bin/env python
import sqlite3
import sys

def add_photons(c, obsid, ra, dec, band, fg_bg_type, fn):
    "Adds photons from file fn to a database controlled by cursor c,
     with specified obsid, ra, dec, band, and foreground/background type"
    # Coerce types
    obsid,ra,dec,band = int(obsid),float(ra),float(dec),float(band),

    if fg_bg_type == "foreground" : fg_bg_type = 1
    elif fg_bg_type == "background" : fg_bg_type = 0
    else :
        print >> sys.stderr, "Invalid foreground/background type"
        sys.exit(1)

    with open(fn) as f:
        c.executemany('INSERT INTO photons VALUES (?,?,?,?,?,?)',
                      [(obsid, ra, dec, band, fg_bg_type, flux) 
                       for flux in map(float,f)])

if __name__ == "__main__":
    conn = sqlite3.connect(sys.argv[1])
    c = conn.cursor()
    # Create the Photon Table
    c.execute("""
            create table if not exists photons (
                id INTEGER AUTOINCREMENT NOT NULL UNIQUE PRIMARY KEY,
                OBSID INTEGER,
                RA REAL, 
                DEC REAL,
                band REAL,
                fg_bg_type INTEGER,
                flux REAL )
            """)

    # Create file table
    c.execute("""
            create table if not exists files (
                filename TEXT PRIMARY KEY UNIQUE )
            """)

    for arg in sys.argv[2:]:
        #obsid, ra, dec, band, fg_bg_type, fn = arg.split(' ')
	fn = arg
        #add_photons(c, obsid, ra, dec, band, fg_bg_type, fn)
        c.execute('INSERT INTO files VALUES (?)', (fn,))

    c.execute('SELECT * FROM mytable')
    allentries=cursor.fetchall()
    for x in allentries:
	print x
    c.close()
    conn.close()
