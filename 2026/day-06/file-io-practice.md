##### **Task:**

1. Creating a file
2. Writing text to a file
3. Appending new lines
4. Reading the file back



Output from my Environment:

```

aishuser@aish-ubuntu-tws:\~$ touch notes.txt

aishuser@aish-ubuntu-tws:\~$ ls

file.txt  notes.txt

aishuser@aish-ubuntu-tws:\~$ echo "step 1 - create file using touch command" > notes.txt

aishuser@aish-ubuntu-tws:\~$ cat notes.txt

step 1 - create file using touch command

aishuser@aish-ubuntu-tws:\~$ echo "step 2 - add lines to file using > and >> symbol" >

> notes.txt

aishuser@aish-ubuntu-tws:\~$ cat notes.txt

step 1 - create file using touch command

step 2 - add lines to file using > and >> symbol

```



Tried tee command - reads input and writes it to BOTH a file and the terminal

```

aishuser@aish-ubuntu-tws:\~$ echo "step 3 - try tee command" | tee -a notes.txt

step 3 - try tee command

aishuser@aish-ubuntu-tws:\~$ cat notes.txt

step 1 - create file using touch command

step 2 - add lines to file using > and >> symbol





step 3 - try tee command

```



Added few more lines to the file using vi editor

and Tried head and tail command to read few lines from top and bottom respectively.



```

aishuser@aish-ubuntu-tws:\~$ head -n 4 notes.txt

step 1 - create file using touch command

step 2 - add lines to file using > and >> symbol

step 3 - try tee command

step 4 - try head command

aishuser@aish-ubuntu-tws:\~$ tail -n 3 notes.txt

step 6 - make notes

step 7 - push to github repo

step 8 - complete day 05 task

```

