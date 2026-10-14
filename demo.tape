# vhs demo.tape  ->  demo.mp4, demo.gif
#
# Before recording: `forge topology check` and one `forge run --processes
# --hot-reload` (Ctrl-C it) so the build is cached and nothing on camera
# waits on a compile.

Output demo.mp4
Output demo.gif

Require march
Require forge

Set Shell "bash"
Set FontSize 20
Set Width 1280
Set Height 820
Set Padding 24
Set Theme "Catppuccin Mocha"
Set TypingSpeed 35ms
Set CursorBlink false

Hide
Type "export PS1='$ ' && cd ~/code/choreo-demo && git checkout -q -- src && rm -f run.log build.log && clear"
Enter
Show

# 1. The protocol: the whole conversation, written once.
Type "sed -n '17,32p' src/choreo_demo.march"
Sleep 400ms
Enter
Sleep 6s

# 2. A one-line mistake: Stock ends the session without telling Ledger.
Hide
Type "sed -i '' 's/Order_Stock.close(s, Order_Stock.send_Skip(s, st2, item))/Order_Stock.close(s, st2)/' src/choreo_demo.march && clear"
Enter
Show
Type "git -c color.ui=always diff -U0 src | tail -n +5"
Sleep 300ms
Enter
Sleep 3s
Type "march --check --topology .forge/topology.json src/choreo_demo.march 2>&1 | head -6"
Sleep 300ms
Enter
Sleep 7s

Hide
Type "git checkout -q -- src && clear"
Enter
Show

# 3. The fixed program, one OS process per role.
Type "forge run --processes --hot-reload > run.log 2> build.log &"
Sleep 300ms
Enter
Sleep 500ms
Type "tail -f run.log"
Sleep 300ms
Enter
Sleep 11s
Ctrl+C
Sleep 300ms
Hide
Type "clear"
Enter
Show

# 4. Look inside a running node while the sessions keep going.
Type "forge observe --socket .forge/run/books-1.sock.observe"
Sleep 300ms
Enter
Sleep 8s
Type "q"
Sleep 500ms

Hide
Type "kill -INT %1; wait; rm -f run.log build.log; clear"
Enter
Sleep 3s
