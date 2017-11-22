# interpolates times vehicle passes Jarvis and Bathurst streets

import csv
import ast
from scipy.spatial import distance

# print and save header of table for reference
header = []
with open("o12.csv") as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        header = row
        break
print header


# loop over table, fixing up the data to do stuff
out_table = []
out_table.append(['trip_id','t1','t2'])
q = 0
p = 0
r = 0
with open("o12.csv") as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:

        # recoding the times to a python list
        times = row["times"]
        times = times.replace("{","[")
        times = times.replace("}","]")
        times = ast.literal_eval(times)
        #print len(times)

        # line string to a list of coords
        allgeom = row["allgeom"]
        allgeom = allgeom.replace("LINESTRING","")
        allgeom = allgeom.replace("(","['[")
        allgeom = allgeom.replace(")","]']")
        allgeom = allgeom.replace(",","]','[")
        allgeom = allgeom.replace(" ",",")
        allgeom = ast.literal_eval(allgeom)
        #print len(allgeom)

        if len(times) != len(allgeom):
            print row["trip_id"]
            print "times and coords do not match :("
            break

        # get the time stamp for the first point

        int1pt = row['int1pt']
        int1pt = int1pt.replace("POINT","")
        int1pt = int1pt.replace("(","[")
        int1pt = int1pt.replace(")","]")
        int1pt = int1pt.replace(" ",",")
        int1pt = ast.literal_eval(int1pt)

        mind = []
        m = 0
        for pts in allgeom:
            pts = ast.literal_eval(pts)
            e = distance.euclidean(pts,int1pt)
            if e < 150:
                mindo = pts + [m, e]
                mind.append(mindo)
            m += 1

        t1 = 0

        if len(mind) < 1:
            q += 1



        else:
            a_n = 0
            a_d = 0
            for pts in mind:
                #print pts
                #print allgeom[pts[2]]
                #print times[pts[2]]
                a_n = a_n + float(times[pts[2]]) * (100 - float(pts[3]))
                a_d = a_d + (100 - float(pts[3]))
            t1 = a_n / a_d




        # get the time stamp for the second point

        int2pt = row['int2pt']
        int2pt = int2pt.replace("POINT","")
        int2pt = int2pt.replace("(","[")
        int2pt = int2pt.replace(")","]")
        int2pt = int2pt.replace(" ",",")
        int2pt = ast.literal_eval(int2pt)

        mind2 = []
        m = 0
        for pts in allgeom:
            pts = ast.literal_eval(pts)
            e = distance.euclidean(pts,int2pt)
            if e < 150:
                mindo = pts + [m, e]
                mind2.append(mindo)
            m += 1

        t2 = 0

        if len(mind2) < 1:
            p += 1



        else:
            a_n = 0
            a_d = 0
            for pts in mind2:
                #print pts
                #print allgeom[pts[2]]
                #print times[pts[2]]
                a_n = a_n + float(times[pts[2]]) * (100 - float(pts[3]))
                a_d = a_d + (100 - float(pts[3]))
            t2 = a_n / a_d


        if t1 > 0 and t2 > 0:
            outrow = [row["trip_id"],t1,t2]
            out_table.append(outrow)


        else:
            r += 1

print q, p, r
print len(out_table) - 1

with open("times12.csv", 'w') as csvfile:
    writer = csv.writer(csvfile)
    for row in out_table:
        writer.writerow(row)
