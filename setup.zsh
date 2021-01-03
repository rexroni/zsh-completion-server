# Get the absolute path to this file (assume we are being sourced).
dir="$(dirname "$(readlink -f $0)")"
# Include ./fn in fpath and autoload the files
fpath=("$dir"/fn $fpath)
autoload -U "$dir"/fn/*(:t)
unset dir

zmodload zsh/net/socket

# Define how we respond to data on the socket
_completion_request () {
    # We get the fd of the socket and the content of the request line:
    local fd="$1"
    local line="$2"

    # Call the modified zsh4humans code.
    local -a REPLY
    z4h-fzf-complete

    if [ -n "$REPLY" ] ; then
      ratpoison -c "echo $(
        for word in $REPLY[1,20]; do
          echo $word
        done
      )"
    else
      ratpoison -c "echo no completions"
    fi
}

## For testing with a keybinding rather than socket input.
# zle -N _completion_request
# bindkey '^T' _completion_request

# Handle data coming on a socket.  Note that this will only ever trigger while
# zle is awaiting input on the tty (that is, at the zsh prompt).  Requests sent
# at any other time may block for as long as the active command takes to run.
_data_handler () {
    local line
    if ! read -r line <&$1; then
        # Error handling.
        # I have no clue what this line is for, it's in man zshzle
        zle -F $1
        return 1
    fi
    _completion_request $1 "$line"
}

# Handle an incoming socket connection.
_conn_handler () {
    # Accept a connection from the listener fd.
    zsocket -a $1
    # Connect the connection fd to the _data_handler.
    zle -F $REPLY _data_handler
}

# Create the unix socket for the connection.
# You will need a tmpfiles.d entry for this to succeed, like this:
#     # /etc/tmpfiles.d/zsh-completion-server.conf
#     d /run/zsh-completion-server 0777 root root -
sockfile="/run/zsh-completion-server/$$.sock"
rm -f "$sockfile"

# Create a unix socket listener.
zsocket -l "$sockfile"

# Connect the listner fd to the _conn_handler.
zle -F $REPLY _conn_handler

unset REPLY sockfile

# vim: syntax=zsh
