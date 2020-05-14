
import csv
import os

try:
    os.mkdir("sales_update")
except:
    print("directory already exists")
# row = #your data

path="salesdb/Employees2.csv"
path2="salesdb/Customers2.csv"
write="sales_update/Employees2/Employees2.csv"
write_2="sales_update/Customers2/Customers2.csv"

reader = list(csv.reader(open(path, "rU"), delimiter=','))
writer = csv.writer(open(write, 'w'), delimiter='|')
writer.writerows(row for row in reader)


with open(path2, 'rw') as csvfile:
    reader_new = csv.reader(csvfile, delimiter='|')
    rows = []
    for row in reader_new:
        for i in range(len(row)):
            if row[i] == '':
                row[i] = None
        rows.append(row)

reader = list(csv.reader(open(path2, "rU"), delimiter='|'))
writer_new = csv.writer(open(write_2, 'w'), delimiter='|')
for row in reader:
    for i in range(len(row)):
        if row[i] == '' or row[i] == "":
            row[i] = None
    writer_new.writerow(row)
