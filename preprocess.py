import re
import urllib2
import zlib

# ifile = urllib2.urlopen("http://data.giss.nasa.gov/gistemp/station_data/station_list.txt")
ifile = open("data/station_list.txt")
ofile = open("data/station_list_cleaned.txt", 'w')
print >>ofile, "sid;name;lat;lon"
for line in ifile:
    g = re.match("^([0-9]+) (.*) lat,lon \(\.1deg\) +([0-9-]+) +([0-9-]+) .*$", line)
    if g:
        sid, name, slat, slon = g.groups()
        name = name.strip()
        lat, lon = float(slat)/10, float(slon)/10
        print >>ofile, ";".join((sid, '"%s"'%name, '%s'%lat, '%s'%lon))

# Compression would need to be handled.        
# ifile = urllib2.urlopen("http://data.giss.nasa.gov/gistemp/station_data/v3.mean_GISS_homogenized.txt.gz")
ifile = open("data/v3.mean_GISS_homogenized.txt")
ofile = open("data/v3.mean_GISS_homogenized_cleaned.txt", 'w')
print >>ofile, "sid;year;Jan;Feb;Mar;Apr;May;Jun;Jul;Aug;Sep;Oct;Nov;Dec"
for line in ifile:
    print >>ofile, ";".join([line[4:12]]+[line[11+5*i:16+5*i].strip() for i in xrange(13)])
