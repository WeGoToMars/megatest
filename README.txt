Input file format documentation

Line 1: Question title
Line 2: Question bitmap picture filename. Has to be placed into 'images' folder
Line 3: Number of answers {N} (max: 5)
Line 4 - (N+3): Each answer string on a new line
Line N+4: Number of correct answers {C} (max: 5)
Line (N+5) - (N+C+5): Each correct answer string on a new line
Line (N+C+6) - Mandatory separator. Any text entered would be ignored.

Example usage
What's the capital of Germany
berlin.bmp
4
Istanbul
Madrid
Berlin
Rome
1
Berlin
----------
Choose all cities that are in Europe
europe.bmp
5
New York
Beijing
Rome
Warsaw
Copenhagen
3
Rome
Warsaw
Copenhagen
----------

After formating your source text file, encrypt it using "Create" - "New" menu in the main window. Encryption key cannot be recovered! Only encrypted files can be used!