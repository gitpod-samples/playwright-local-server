function selfinstall() {
	local id=com.gitpodsupport.autopwf
	local startup_plist="$HOME/Library/LaunchAgents/${id}.plist"
	local script_path="$HOME/.gitpod-autopwf"

	printf '%s\n' '#!/opt/homebrew/bin/bash' \
		"$(declare -f "${___MAIN_FUNCNAME}")" \
		"${___MAIN_FUNCNAME}"' "$@";' >"${script_path}"
	chmod +x "${script_path}"

	cat >"${startup_plist}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${id}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${script_path}</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>${PATH}</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/${id}.out.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/${id}.err.log</string>
</dict>
</plist>


EOF

	launchctl unload "${startup_plist}" 2>/dev/null || :
	launchctl load "${startup_plist}"
	echo "INFO: installed background script to ${script_path}, service ID: ${id}"
}

function main() {

	if test "${1:-}" == "selfinstall"; then {
		selfinstall
		return 0
	}; fi

	local lockfile=/tmp/.gp_auto_forward

	# Ensure no more than one instance is running
	if ! mkdir ${lockfile} 2>/dev/null; then {
		echo "ERROR: another instance is already locked"
		return 1
	}; fi
	local trap_str="rmdir ${lockfile}"
	trap "${trap_str}" EXIT SIGINT

	if ! command -v gitpod 1>/dev/null; then {
		echo "ERROR: gitpod CLI is not installed. Please install it via something like brew"
		return 1
	}; fi

	# Ensure we're logged in
	if ! gitpod whoami >/dev/null 2>&1; then {
		# gitpod login
		echo "ERROR: not logged into Gitpod"
		return 1
	}; fi

	local pw_port=9999
	local ssh_daemons=()
	local workspaces_store=()
	npx playwright run-server --port ${pw_port} --host 0.0.0.0 &
	trap_str+="; for p in $! \${ssh_daemons[@]}; do kill -9 \$p; done"
	trap "${trap_str}" EXIT SIGINT

	while sleep 2; do
		while read -r workspace; do {
			if [[ ! "${workspaces_store[*]}" =~ (^| )${workspace}($| ) ]]; then {
				workspaces_store+=("$workspace")
				echo $workspace
				$(gitpod workspace ssh ${workspace} --dry-run) -R ${pw_port}:localhost:${pw_port} -N &
				ssh_daemons+=($!)
			}; fi
		}; done < <(
			gitpod workspace list -r -f id
		)
	done

}
