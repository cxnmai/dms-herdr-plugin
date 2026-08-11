Docs - look at https://danklinux.com/docs/dankmaterialshell/plugin-development as a starting point

Make a plugin for herdr that works into the dank material shell bar.

Bar look -
if custom icons can be used - take the herdr icon and pipe it in
if only nerd font - used nf-md-robot_happy

Then, the UI tree is based on if herdr server is on or off and how many/what agents are runnign

If no herdr server - just the icon
If yes herdr server - say X agents running

When clicked open up a widget for it. If server not running, give an option to start it.
If server is running:
1. display what agents are available, and their herdr statuses (not sure exactly what these are, but i think it hsa ready, idle, complete, running etc)
Show what worktrees/directories/branches associated with each
2. Give an option to stop herdr server as well
