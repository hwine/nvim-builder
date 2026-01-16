I wanted a current neovim for my system, but none of the pre-built offerings worked:
- the dpk was too old
- the snap version caused issues

So, I decided to build it myself, but didn't want to much with my machines basic
setup. Docker to the rescue! I got some ideas from the nvim Dockerfile, but also
made changes to work with my system. E.g. use the same base image as I run
(bookworm).

It's crude, but it works -- lots of room to improve. Maybe a justfile. Maybe a
compose file. We'll see.
