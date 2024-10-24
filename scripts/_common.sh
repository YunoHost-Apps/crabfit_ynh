#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

export nodejs_version="18"

function build_backend
{
	# The cargo version packaged with debian (currently 11) is too old and results in errors..
	# Thus the latest version is manually installed alongside the application for the moment
	pushd $install_dir/api
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
		ynh_hide_warnings ynh_exec_as_app \
			RUSTUP_HOME=$install_dir/api/.rustup \
			CARGO_HOME=$install_dir/api/.cargo \
			sh rustup.sh -y -q --no-modify-path --default-toolchain=stable
		export PATH="$PATH:$install_dir/.cargo/bin"
		ynh_hide_warnings ynh_exec_as_app \
			RUSTUP_HOME=$install_dir/api/.rustup \
			CARGO_HOME=$install_dir/api/.cargo \
			$install_dir/api/.cargo/bin/cargo build --release --features sql-adaptor

		# Remove build files and rustup
		ynh_safe_rm "$install_dir/api/.cargo"
		ynh_safe_rm "$install_dir/api/.rustup"
		mv target/release/crabfit-api ..
		ynh_safe_rm "$install_dir/api/target"
	popd
}

function build_frontend
{
	pushd $install_dir/frontend
		ynh_hide_warnings ynh_exec_as_app node_load_PATH" npm install next
		ynh_hide_warnings ynh_exec_as_app node_load_PATH" npm run build
	popd

	ynh_safe_rm "$install_dir/.cache"
}
