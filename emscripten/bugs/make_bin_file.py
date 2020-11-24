#make_bin_file.py
newFile = open("file.bin", "wb")
byty = [0, 1, 2, 234, 4, 5, 6, 7, 8, 9]
nba = bytearray(byty)
newFile.write(nba)
