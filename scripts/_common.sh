#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

export #REMOVEME? nodejs_version="18"

#=================================================
# PERSONAL HELPERS
#=================================================

function build_backend
{
	# The cargo version packaged with debian (currently 11) is too old and results in errors..
	# Thus the latest version is manually installed alongside the application for the moment
	pushd $install_dir/api
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
		ynh_exec_warn_less ynh_exec_as "$app" \
			RUSTUP_HOME=$install_dir/api/.rustup \
			CARGO_HOME=$install_dir/api/.cargo \
			sh rustup.sh -y -q --no-modify-path --default-toolchain=stable
		export PATH="$PATH:$install_dir/.cargo/bin"
		ynh_exec_warn_less ynh_exec_as "$app" \
			RUSTUP_HOME=$install_dir/api/.rustup \
			CARGO_HOME=$install_dir/api/.cargo \
			$install_dir/api/.cargo/bin/cargo update
		ynh_exec_warn_less ynh_exec_as "$app" \
			RUSTUP_HOME=$install_dir/api/.rustup \
			CARGO_HOME=$install_dir/api/.cargo \
			$install_dir/api/.cargo/bin/cargo build --release --features sql-adaptor

		# Remove build files and rustup
		ynh_secure_remove --file="$install_dir/api/.cargo"
		ynh_secure_remove --file="$install_dir/api/.rustup"
		mv target/release/crabfit-api ..
		ynh_secure_remove --file="$install_dir/api/target"
	popd
}

function build_frontend
{
	pushd $install_dir/frontend
		ynh_exec_warn_less ynh_exec_as "$app" env "$ynh_node_load_PATH" $ynh_npm install next
		ynh_exec_warn_less ynh_exec_as "$app" env "$ynh_node_load_PATH" $ynh_npm run build
	popd

	ynh_secure_remove --file="$install_dir/.cache"
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
