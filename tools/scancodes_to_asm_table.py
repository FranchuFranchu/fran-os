import csv
with open("scancodes.csv") as f:
    l = list(csv.reader(f))[1:]

lowercase = {}
uppercase = {}
for row in l:
    for i in [0, 3, 6]:
        if "," in row[i]:
            continue
        if not row[i]:
            continue
        lowercase[int(row[i].split(' ')[0], 16)] = row[i + 1]

print(lowercase)
s = "scancode_to_lowercase:\n"
for i in range(256):
    g = lowercase.get(i)
    if g:
        if len(g) > 1:
            g = None
    s += "\t.c{}: db {}\n".format(hex(i), '"' + g + '"' if g != None else 0)

with open("scancodes.asm", "w") as f:
    f.write(s)

