NAME="playwright-local-server-for-gitpod"
CODENAME="gitpod-autopwf"
AUTHORS=("AXON <axonasif@gmail.com>")
VERSION="1.0"
DEPENDENCIES=()
REPOSITORY=""
BASHBOX_COMPAT="0.4.1~"

bashbox::build::after() {
	cp "$_target_workfile" "$_arg_path/$CODENAME"
	chmod +x "$_arg_path/$CODENAME"
}
