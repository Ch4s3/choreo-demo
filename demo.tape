# vhs demo.tape -> demo-raw.mp4; then `python3 captions.py` burns in the
# narration (the `# CAPTION:` lines below) and writes demo.mp4 and demo.gif.
#
# Before recording: `forge topology check` and one `forge run --processes
# --hot-reload` (Ctrl-C it) so the build is cached and nothing on camera
# waits on a compile.

Output demo-raw.mp4

Require march
Require forge

Set Shell "bash"
Set FontSize 20
Set Width 1440
Set Height 820
Set Padding 24
Set Theme "Catppuccin Mocha"
Set TypingSpeed 35ms
Set CursorBlink false

Hide
Type "export PS1='$ ' && cd ~/code/choreo-demo && git checkout -q -- src && rm -f run.log build.log && clear"
Enter
Type "sed -n '17,32p' src/choreo_demo.march"
Enter
Show

# CAPTION: One protocol describes the whole conversation between three roles.
Sleep 7s

Hide
Type "clear && sed -n '50,62p' src/choreo_demo.march"
Enter
Show

# CAPTION: The compiler projects it to a typed API per role. This is Stock's side.
Sleep 7s

Hide
Type "clear && sed -n '158,168p' src/choreo_demo.march"
Enter
Show

# CAPTION: And Shop's: send `want`, then handle whichever branch Stock picks.
Sleep 7s

Hide
Type "clear && sed -i '' 's/Order_Stock.close(s, Order_Stock.send_Skip(s, st2, item))/Order_Stock.close(s, st2)/' src/choreo_demo.march && git -c color.ui=always diff -U0 src | tail -n +5"
Enter
Show

# CAPTION: Now a one-line mistake: Stock ends the session without telling Ledger.
Sleep 4s
Type "march --check --topology .forge/topology.json src/choreo_demo.march 2>&1 | head -6"
Sleep 300ms
Enter
Sleep 2500ms

# CAPTION: It no longer compiles: Stock still owes Ledger the `skip` message.
Sleep 5s

Hide
Type "git checkout -q -- src && clear"
Enter
Show

# CAPTION: Fixed, it runs as three OS processes, one per role, over real sockets.
Type "DEMO_TRAFFIC_SECONDS=40 forge run --processes --hot-reload > run.log 2> build.log &"
Sleep 300ms
Enter
Sleep 500ms
Type "tail -f run.log"
Sleep 300ms
Enter
Sleep 7s

# CAPTION: Alongside the narrated session, 8 workers drive background traffic.
Sleep 6s
Ctrl+C
Sleep 300ms
Hide
Type "clear"
Enter
Show

# CAPTION: forge observe: a live view inside one running node, mid-traffic.
Type "forge observe --socket .forge/run/books-1.sock.observe"
Sleep 300ms
Enter
Sleep 7s

# CAPTION: March 0.5.0  ·  march-lang.org  ·  github.com/Ch4s3/choreo-demo
Type "2"
Sleep 5s
Type "q"
Sleep 300ms

Hide
Type "sleep 30; kill -INT %1; wait; rm -f run.log build.log; clear"
Enter
Sleep 40s
