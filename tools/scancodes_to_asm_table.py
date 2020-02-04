import csv
rown = 2
with open("scancodes.csv") as f:
    l = list(csv.reader(f))[1:]

lowercase = {}
uppercase = {}
for row in l:
    if "-" in row[rown]:
        continue
    if not row[rown]:
        continue
    lowercase[int(row[rown].split(' ')[0], 16)] = row[8].split(' ')[0].lower()
    uppercase[int(row[rown].split(' ')[0], 16)] = row[8].split(' ')[-1].upper()

print(lowercase)
s = "scancode_to_lowercase:\n"
for i in range(256):
    g = lowercase.get(i)
    s += "\t.c{:0>2}: db {:<4}".format(hex(i)[2:], '"' + g + '"' if len(str(g)) == 1 else 0) + "\t; " + str(g) + "\n"

with open("scancodes.asm", "w") as f:
    f.write(s)

