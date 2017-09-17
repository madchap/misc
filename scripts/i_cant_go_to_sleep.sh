pmset -g assertions |awk '/^.*pid.*PreventSystemSleep.*/ {print "pid",$2,$7,"is preventing the system to go to sleep"}' | xargs -I{} osascript -e 'display notification "{}" with title "Sleep warning"
