function echo_cabal_original_url () {
	local cabal_version
	expect_args cabal_version -- "$@"

	case "${cabal_version}" in
	'1.20.0.3')
		echo 'http://www.haskell.org/cabal/release/cabal-install-1.20.0.3/cabal-install-1.20.0.3.tar.gz';;
	'1.20.0.2')
		echo 'http://www.haskell.org/cabal/release/cabal-install-1.20.0.2/cabal-install-1.20.0.2.tar.gz';;
	'1.20.0.1')
		echo 'http://www.haskell.org/cabal/release/cabal-install-1.20.0.1/cabal-install-1.20.0.1.tar.gz';;
	'1.20.0.0')
		echo 'http://www.haskell.org/cabal/release/cabal-install-1.20.0.0/cabal-install-1.20.0.0.tar.gz';;
	'1.18.0.3')
		echo 'http://www.haskell.org/cabal/release/cabal-install-1.18.0.3/cabal-install-1.18.0.3.tar.gz';;
	'1.18.0.2')
		echo 'http://www.haskell.org/cabal/release/cabal-install-1.18.0.2/cabal-install-1.18.0.2.tar.gz';;
	'1.18.0.1')
		echo 'http://www.haskell.org/cabal/release/cabal-install-1.18.0.1/cabal-install-1.18.0.1.tar.gz';;
	*)
		die "Unexpected Cabal version: ${cabal_version}"
	esac
}


function echo_cabal_default_version () {
	echo '1.20.0.3'
}


function echo_cabal_config () {
	expect_vars HALCYON_DIR

	cat <<-EOF
		remote-repo:                    hackage.haskell.org:http://hackage.haskell.org/packages/archive
		remote-repo-cache:              ${HALCYON_DIR}/cabal/packages
		avoid-reinstalls:               True
		reorder-goals:                  True
		require-sandbox:                True
		jobs:                           \$ncpus
EOF
}


function derive_cabal_tag () {
	expect_vars HALCYON_DIR

	local ghc_tag cabal_version cabal_hook
	expect_args ghc_tag cabal_version cabal_hook -- "$@"

	local os
	os=$( detect_os ) || die

	local ghc_os ghc_halcyon_dir
	ghc_os=$( echo_ghc_tag_os "${ghc_tag}" ) || die
	ghc_halcyon_dir=$( echo_ghc_tag_halcyon_dir "${ghc_tag}" ) || die

	if [ "${os}" != "${ghc_os}" ]; then
		die "Unexpected OS in GHC tag: ${ghc_os}"
	fi
	if [ "${HALCYON_DIR}" != "${ghc_halcyon_dir}" ]; then
		die "Unexpected HALCYON_DIR in GHC tag: ${ghc_halcyon_dir}"
	fi

	echo -e "${os}\t${HALCYON_DIR}\tcabal-${cabal_version}\t${cabal_hook}\t"
}


function derive_updated_cabal_tag () {
	expect_vars HALCYON_DIR

	local cabal_tag cabal_timestamp
	expect_args cabal_tag cabal_timestamp -- "$@"

	local os
	os=$( detect_os ) || die

	local cabal_os cabal_halcyon_dir cabal_version cabal_hook
	cabal_os=$( echo_cabal_tag_os "${cabal_tag}" ) || die
	cabal_halcyon_dir=$( echo_cabal_tag_halcyon_dir "${cabal_tag}" ) || die
	cabal_version=$( echo_cabal_tag_version "${cabal_tag}" ) || die
	cabal_hook=$( echo_cabal_tag_hook "${cabal_tag}" ) || die

	if [ "${os}" != "${cabal_os}" ]; then
		die "Unexpected OS in Cabal tag: ${cabal_os}"
	fi
	if [ "${HALCYON_DIR}" != "${cabal_halcyon_dir}" ]; then
		die "Unexpected HALCYON_DIR in Cabal tag: ${cabal_halcyon_dir}"
	fi

	echo -e "${os}\t${HALCYON_DIR}\tcabal-${cabal_version}\t${cabal_hook}\t${cabal_timestamp}"
}


function echo_cabal_tag_os () {
	local cabal_tag
	expect_args cabal_tag -- "$@"

	awk '{ print $1 }' <<<"${cabal_tag}"
}


function echo_cabal_tag_halcyon_dir () {
	local cabal_tag
	expect_args cabal_tag -- "$@"

	awk '{ print $2 }' <<<"${cabal_tag}"
}


function echo_cabal_tag_version () {
	local cabal_tag
	expect_args cabal_tag -- "$@"

	awk '{ print $3 }' <<<"${cabal_tag}" | sed 's/^cabal-//'
}


function echo_cabal_tag_hook () {
	local cabal_tag
	expect_args cabal_tag -- "$@"

	awk '{ print $4 }' <<<"${cabal_tag}"
}


function echo_cabal_tag_timestamp () {
	local cabal_tag
	expect_args cabal_tag -- "$@"

	awk '{ print $5 }' <<<"${cabal_tag}"
}


function echo_cabal_description () {
	local cabal_tag
	expect_args cabal_tag -- "$@"

	local cabal_version cabal_hook cabal_timestamp
	cabal_version=$( echo_cabal_tag_version "${cabal_tag}" ) || die
	cabal_hook=$( echo_cabal_tag_hook "${cabal_tag}" ) || die
	cabal_timestamp=$( echo_cabal_tag_timestamp "${cabal_tag}" ) || die

	if [ -z "${cabal_timestamp}" ]; then
		echo "Cabal ${cabal_version}${cabal_hook:+~${cabal_hook:0:7}}"
	else
		local timestamp_date timestamp_time
		timestamp_date="${cabal_timestamp:0:4}-${cabal_timestamp:4:2}-${cabal_timestamp:6:2}"
		timestamp_time="${cabal_timestamp:8:2}:${cabal_timestamp:10:2}:${cabal_timestamp:12:2}"

		echo "updated Cabal ${cabal_version}${cabal_hook:+~${cabal_hook:0:7}} (${timestamp_date} ${timestamp_time} UTC)"
	fi
}


function echo_cabal_archive () {
	local cabal_tag
	expect_args cabal_tag -- "$@"

	local cabal_version cabal_hook cabal_timestamp
	cabal_version=$( echo_cabal_tag_version "${cabal_tag}" ) || die
	cabal_hook=$( echo_cabal_tag_hook "${cabal_tag}" ) || die
	cabal_timestamp=$( echo_cabal_tag_timestamp "${cabal_tag}" ) || die

	echo "halcyon-cabal-${cabal_version}${cabal_hook:+~${cabal_hook:0:7}}${cabal_timestamp:+-${cabal_timestamp}}.tar.xz"
}


function echo_updated_cabal_archive_prefix () {
	local cabal_tag
	expect_args cabal_tag -- "$@"

	local cabal_version cabal_hook
	cabal_version=$( echo_cabal_tag_version "${cabal_tag}" ) || die
	cabal_hook=$( echo_cabal_tag_hook "${cabal_tag}" ) || die

	echo "halcyon-cabal-${cabal_version}${cabal_hook:+~${cabal_hook:0:7}}-"
}


function echo_updated_cabal_archive_pattern () {
	local cabal_tag
	expect_args cabal_tag -- "$@"

	local cabal_version cabal_hook
	cabal_version=$( echo_cabal_tag_version "${cabal_tag}" ) || die
	cabal_hook=$( echo_cabal_tag_hook "${cabal_tag}" ) || die

	echo "halcyon-cabal-${cabal_version//./\.}${cabal_hook:+~${cabal_hook:0:7}}-.*\.tar\.xz"
}


function echo_updated_cabal_archive_timestamp () {
	local cabal_archive
	expect_args cabal_archive -- "$@"

	local timestamp_etc
	timestamp_etc="${cabal_archive##*-}"

	echo "${timestamp_etc%.tar.xz}"
}


function echo_tmp_cabal_dir () {
	mktemp -du '/tmp/halcyon-cabal.XXXXXXXXXX'
}


function validate_cabal_tag () {
	local cabal_tag
	expect_args cabal_tag -- "$@"

	local candidate_tag
	candidate_tag=$( match_exactly_one ) || die

	if [ "${candidate_tag}" != "${cabal_tag}" ]; then
		return 1
	fi
}


function validate_cabal_hook () {
	local cabal_hook hooks_dir
	expect_args cabal_hook hooks_dir -- "$@"

	# TODO
	return 0
}


function validate_updated_cabal_timestamp () {
	local candidate_timestamp
	expect_args candidate_timestamp -- "$@"

	local yesterday_timestamp
	yesterday_timestamp=$( echo_timestamp -d yesterday ) || die

	if [[ "${candidate_timestamp}" < "${yesterday_timestamp}" ]]; then
		return 1
	fi
}


function validate_updated_cabal_tag () {
	local cabal_tag
	expect_args cabal_tag -- "$@"

	local candidate_tag
	candidate_tag=$( match_exactly_one ) || die

	local cabal_os cabal_halcyon_dir cabal_version cabal_hook
	cabal_os=$( echo_cabal_tag_os "${cabal_tag}" ) || die
	cabal_halcyon_dir=$( echo_cabal_tag_halcyon_dir "${cabal_tag}" ) || die
	cabal_version=$( echo_cabal_tag_version "${cabal_tag}" ) || die
	cabal_hook=$( echo_cabal_tag_hook "${cabal_tag}" ) || die

	local candidate_os candidate_halcyon_dir candidate_cabal_version candidate_cabal_hook candidate_timestamp
	candidate_os=$( echo_cabal_tag_os "${candidate_tag}" ) || die
	candidate_halcyon_dir=$( echo_cabal_tag_halcyon_dir "${candidate_tag}" ) || die
	candidate_version=$( echo_cabal_tag_version "${candidate_tag}" ) || die
	candidate_hook=$( echo_cabal_tag_hook "${candidate_tag}" ) || die

	if [ "${candidate_os}" != "${cabal_os}" ] ||
		[ "${candidate_halcyon_dir}" != "${cabal_halcyon_dir}" ] ||
		[ "${candidate_version}" != "${cabal_version}" ] ||
		[ "${candidate_hook}" != "${cabal_hook}" ]
	then
		return 1
	fi

	local candidate_timestamp
	candidate_timestamp=$( echo_cabal_tag_timestamp "${candidate_tag}" ) || die

	validate_updated_cabal_timestamp "${candidate_timestamp}"
}


function validate_updated_cabal_archive () {
	local cabal_tag
	expect_args cabal_tag -- "$@"

	local updated_pattern
	updated_pattern=$( echo_updated_cabal_archive_pattern "${cabal_tag}" ) || die

	local candidate_archive
	if ! candidate_archive=$(
		filter_matching "^${updated_pattern}$" |
		match_exactly_one
	); then
		return 1
	fi

	local candidate_timestamp
	candidate_timestamp=$( echo_updated_cabal_archive_timestamp "${candidate_archive}" ) || die

	validate_updated_cabal_timestamp "${candidate_timestamp}"
}


function match_updated_cabal_archive () {
	local cabal_tag
	expect_args cabal_tag -- "$@"

	local updated_pattern
	updated_pattern=$( echo_updated_cabal_archive_pattern "${cabal_tag}" ) || die

	local updated_archive
	if ! updated_archive=$(
		filter_matching "^${updated_pattern}$" |
		sort_naturally |
		filter_last |
		match_exactly_one
	); then
		return 1
	fi

	if ! validate_updated_cabal_archive "${cabal_tag}" <<<"${updated_archive}"; then
		return 1
	fi

	echo "${updated_archive}"
}


function cabal_do () {
	expect_vars HALCYON_DIR
	expect_existing "${HALCYON_DIR}/cabal/.halcyon-tag"

	local work_dir
	expect_args work_dir -- "$@"
	shift
	expect_existing "${work_dir}"

	if ! (
		cd "${work_dir}" &&
		cabal --config-file="${HALCYON_DIR}/cabal/.halcyon-cabal.config" "$@"
	); then
		die 'Using Cabal failed'
	fi
}


function sandboxed_cabal_do () {
	local sandbox_dir work_dir
	expect_args sandbox_dir work_dir -- "$@"
	shift 2
	expect_existing "${sandbox_dir}"

	# NOTE: Specifying a sandbox config file should not change where Cabal looks
	# for a config file.
	# https://github.com/haskell/cabal/issues/1915

	local saved_config
	saved_config=''
	if [ -f "${sandbox_dir}/cabal.config" ]; then
		saved_config=$( echo_tmp_sandbox_config ) || die
		mv "${sandbox_dir}/cabal.config" "${saved_config}" || die
	fi
	if [ -f "${work_dir}/cabal.config" ]; then
		cp "${work_dir}/cabal.config" "${sandbox_dir}/cabal.config" || die
	fi

	local status
	status=0
	if ! cabal_do "${work_dir}"                                         \
		--sandbox-config-file="${sandbox_dir}/cabal.sandbox.config" \
		"$@"
	then
		status=1
	fi

	rm -f "${sandbox_dir}/cabal.config" || die
	if [ -n "${saved_config}" ]; then
		mv "${saved_config}" "${sandbox_dir}/cabal.config" || die
	fi

	return "${status}"
}


function cabal_update () {
	expect_vars HALCYON_QUIET

	quote_quietly "${HALCYON_QUIET}" cabal_do '.' update || die
}


function cabal_list_latest_package_version () {
	local package_name
	expect_args package_name -- "$@"

	cabal_do '.' --no-require-sandbox list --simple-output "${package_name}" |
		filter_matching "^${package_name} " |
		sort_naturally |
		filter_last |
		match_exactly_one |
		sed 's/^.* //'
}


function cabal_create_sandbox () {
	expect_vars HALCYON_QUIET

	local sandbox_dir
	expect_args sandbox_dir -- "$@"
	expect_no_existing "${sandbox_dir}"

	mkdir -p "${sandbox_dir}" || die
	quote_quietly "${HALCYON_QUIET}" cabal_do "${sandbox_dir}" sandbox init --sandbox '.' || die
}


function cabal_install () {
	expect_vars HALCYON_QUIET

	local sandbox_dir app_dir
	expect_args sandbox_dir app_dir -- "$@"

	quote_quietly "${HALCYON_QUIET}" sandboxed_cabal_do "${sandbox_dir}" "${app_dir}" install "$@" || die
}


# NOTE: Listing executable-only packages in build-tools causes Cabal to
# expect the executables to be installed, but not to install the packages.
# https://github.com/haskell/cabal/issues/220

# NOTE: Listing executable-only packages in build-depends causes Cabal to
# install the packages, and to fail to recognise the packages have been
# installed.
# https://github.com/haskell/cabal/issues/779

function cabal_install_deps () {
	expect_vars HALCYON_QUIET

	local sandbox_dir app_dir
	expect_args sandbox_dir app_dir -- "$@"

	quote_quietly "${HALCYON_QUIET}" sandboxed_cabal_do "${sandbox_dir}" "${app_dir}" install --dependencies-only || die
}


function cabal_configure_app () {
	expect_vars HALCYON_DIR HALCYON_QUIET

	local sandbox_dir app_dir
	expect_args sandbox_dir app_dir -- "$@"

	quote_quietly "${HALCYON_QUIET}" sandboxed_cabal_do "${sandbox_dir}" "${app_dir}" configure --prefix="${HALCYON_DIR}/app" || die
}


function cabal_build_app () {
	expect_vars HALCYON_QUIET

	local sandbox_dir app_dir
	expect_args sandbox_dir app_dir -- "$@"

	quote_quietly "${HALCYON_QUIET}" sandboxed_cabal_do "${sandbox_dir}" "${app_dir}" build || die
	quote_quietly "${HALCYON_QUIET}" sandboxed_cabal_do "${sandbox_dir}" "${app_dir}" copy || die
}


function build_cabal () {
	expect_vars HOME HALCYON_DIR HALCYON_CACHE_DIR HALCYON_QUIET
	expect_existing "${HOME}" "${HALCYON_DIR}/ghc/.halcyon-tag"
	expect_no_existing "${HOME}/.cabal" "${HOME}/.ghc" "${HALCYON_DIR}/cabal"

	local cabal_tag app_dir
	expect_args cabal_tag app_dir -- "$@"

	local cabal_version cabal_description
	cabal_version=$( echo_cabal_tag_version "${cabal_tag}" ) || die
	cabal_description=$( echo_cabal_description "${cabal_tag}" ) || die

	log "Building ${cabal_description}"

	local original_url original_archive tmp_dir
	original_url=$( echo_cabal_original_url "${cabal_version}" ) || die
	original_archive=$( basename "${original_url}" ) || die
	tmp_dir=$( echo_tmp_cabal_dir ) || die

	if ! [ -f "${HALCYON_CACHE_DIR}/${original_archive}" ] ||
		! tar_extract "${HALCYON_CACHE_DIR}/${original_archive}" "${tmp_dir}"
	then
		rm -rf "${HALCYON_CACHE_DIR}/${original_archive}" "${tmp_dir}" || die

		if ! prepare_original "${original_archive}" "${original_url}" "${HALCYON_CACHE_DIR}"; then
			die "Downloading ${original_archive} failed"
		fi

		if ! tar_extract "${HALCYON_CACHE_DIR}/${original_archive}" "${tmp_dir}"; then
			rm -rf "${HALCYON_CACHE_DIR}/${original_archive}" "${tmp_dir}" || die
			die "Restoring ${original_archive} failed"
		fi
	fi

	local ghc_tag ghc_version
	ghc_tag=$( <"${HALCYON_DIR}/ghc/.halcyon-tag" ) || die
	ghc_version=$( echo_ghc_tag_version "${ghc_tag}" ) || die

	if [ -f "${app_dir}/.halcyon-hooks/cabal-pre-build" ]; then
		log "Running Cabal pre-build hook"
		"${app_dir}/.halcyon-hooks/cabal-pre-build" "${ghc_tag}" "${cabal_tag}" "${tmp_dir}/cabal-install-${cabal_version}" "${app_dir}" || die

		mkdir -p "${HALCYON_DIR}/cabal/.halcyon-hooks"
		cp "${app_dir}/.halcyon-hooks/cabal-pre-build" "${HALCYON_DIR}/cabal/.halcyon-hooks"
	fi

	log "Bootstrapping ${cabal_description}"

	case "${ghc_version}-${cabal_version}" in
	'7.8.'*'-1.20.0.'*)
		(
			cd "${tmp_dir}/cabal-install-${cabal_version}" || die
			patch -s <<-EOF
				--- a/bootstrap.sh
				+++ b/bootstrap.sh
				@@ -217,3 +217,3 @@ install_pkg () {

				-  \${GHC} --make Setup -o Setup ||
				+  \${GHC} -L"${HALCYON_DIR}/ghc/lib" --make Setup -o Setup ||
				      die "Compiling the Setup script failed."
EOF
		) || die
		;;
	*)
		rm -rf "${tmp_dir}" || die
		die "Bootstrapping Cabal ${cabal_version} with GHC ${ghc_version} is not implemented yet"
	esac

	# NOTE: Bootstrapping cabal-install with GHC 7.8.[23] may fail unless --no-doc is specified.
	# https://ghc.haskell.org/trac/ghc/ticket/9174

	if ! (
		export EXTRA_CONFIGURE_OPTS="--extra-lib-dirs=${HALCYON_DIR}/ghc/lib" &&
		cd "${tmp_dir}/cabal-install-${cabal_version}" &&
		quote_quietly "${HALCYON_QUIET}" ./bootstrap.sh --no-doc
	); then
		rm -rf "${tmp_dir}" || die
		die "Bootstrapping Cabal ${cabal_version} failed"
	fi

	mkdir -p "${HALCYON_DIR}/cabal/bin" || die
	mv "${HOME}/.cabal/bin/cabal" "${HALCYON_DIR}/cabal/bin/cabal" || die

	echo_cabal_config >"${HALCYON_DIR}/cabal/.halcyon-cabal.config" || die

	if [ -f "${app_dir}/.halcyon-hooks/cabal-post-build" ]; then
		log "Running Cabal post-build hook"
		"${app_dir}/.halcyon-hooks/cabal-post-build" "${ghc_tag}" "${cabal_tag}" "${tmp_dir}/cabal-install-${cabal_version}" "${app_dir}" || die

		mkdir -p "${HALCYON_DIR}/cabal/.halcyon-hooks"
		cp "${app_dir}/.halcyon-hooks/cabal-post-build" "${HALCYON_DIR}/cabal/.halcyon-hooks"
	fi

	echo "${cabal_tag}" >"${HALCYON_DIR}/cabal/.halcyon-tag" || die

	rm -rf "${HOME}/.cabal" "${HOME}/.ghc" "${tmp_dir}" || die

	local cabal_size
	cabal_size=$( measure_recursively "${HALCYON_DIR}/cabal" ) || die
	log "Bootstrapped ${cabal_description}, ${cabal_size}"
}


function update_cabal () {
	expect_vars HALCYON_DIR
	expect_existing "${HALCYON_DIR}/cabal/.halcyon-tag"

	local cabal_tag cabal_description
	cabal_tag=$( <"${HALCYON_DIR}/cabal/.halcyon-tag" ) || die
	cabal_description=$( echo_cabal_description "${cabal_tag}" ) || die

	log "Updating ${cabal_description}"

	cabal_update || die

	local cabal_timestamp updated_cabal_tag updated_cabal_description
	cabal_timestamp=$( echo_timestamp ) || die
	updated_cabal_tag=$( derive_updated_cabal_tag "${cabal_tag}" "${cabal_timestamp}" ) || die
	updated_cabal_description=$( echo_cabal_description "${updated_cabal_tag}" ) || die
	echo "${updated_cabal_tag}" >"${HALCYON_DIR}/cabal/.halcyon-tag" || die

	local cabal_size
	cabal_size=$( measure_recursively "${HALCYON_DIR}/cabal" ) || die
	log "Updated ${updated_cabal_description}, ${cabal_size}"
}


function archive_cabal () {
	expect_vars HALCYON_DIR HALCYON_CACHE_DIR HALCYON_NO_ARCHIVE
	expect_existing "${HALCYON_DIR}/cabal/.halcyon-tag"

	if (( ${HALCYON_NO_ARCHIVE} )); then
		return 0
	fi

	local cabal_tag os cabal_archive cabal_description
	cabal_tag=$( <"${HALCYON_DIR}/cabal/.halcyon-tag" ) || die
	os=$( echo_cabal_tag_os "${cabal_tag}" ) || die
	cabal_archive=$( echo_cabal_archive "${cabal_tag}" ) || die
	cabal_description=$( echo_cabal_description "${cabal_tag}" ) || die

	log "Archiving ${cabal_description}"

	rm -f "${HALCYON_CACHE_DIR}/${cabal_archive}" || die
	tar_archive "${HALCYON_DIR}/cabal" "${HALCYON_CACHE_DIR}/${cabal_archive}" || die
	upload_layer "${HALCYON_CACHE_DIR}/${cabal_archive}" "${os}" || die
}


function restore_cabal () {
	expect_vars HALCYON_DIR HALCYON_CACHE_DIR

	local cabal_tag
	expect_args cabal_tag -- "$@"

	local os cabal_hook cabal_archive cabal_description
	os=$( echo_cabal_tag_os "${cabal_tag}" ) || die
	cabal_hook=$( echo_cabal_tag_hook "${cabal_tag}" ) || die
	cabal_archive=$( echo_cabal_archive "${cabal_tag}" ) || die
	cabal_description=$( echo_cabal_description "${cabal_tag}" ) || die

	log "Restoring ${cabal_description}"

	if [ -f "${HALCYON_DIR}/cabal/.halcyon-tag" ] &&
		validate_cabal_tag "${cabal_tag}" <"${HALCYON_DIR}/cabal/.halcyon-tag" &&
		validate_cabal_hook "${cabal_hook}" "${HALCYON_DIR}/cabal/.halcyon-hooks"
	then
		return 0
	fi
	rm -rf "${HALCYON_DIR}/cabal" || die

	if ! [ -f "${HALCYON_CACHE_DIR}/${cabal_archive}" ] ||
		! tar_extract "${HALCYON_CACHE_DIR}/${cabal_archive}" "${HALCYON_DIR}/cabal" ||
		! [ -f "${HALCYON_DIR}/cabal/.halcyon-tag" ] ||
		! validate_cabal_tag "${cabal_tag}" <"${HALCYON_DIR}/cabal/.halcyon-tag" ||
		! validate_cabal_hook "${cabal_hook}" "${HALCYON_DIR}/cabal/.halcyon-hooks"
	then
		rm -rf "${HALCYON_CACHE_DIR}/${cabal_archive}" "${HALCYON_DIR}/cabal" || die

		if ! download_layer "${os}" "${cabal_archive}" "${HALCYON_CACHE_DIR}"; then
			log "Downloading ${cabal_archive} failed"
			return 1
		fi

		if ! tar_extract "${HALCYON_CACHE_DIR}/${cabal_archive}" "${HALCYON_DIR}/cabal" ||
			! [ -f "${HALCYON_DIR}/cabal/.halcyon-tag" ] ||
			! validate_cabal_tag "${cabal_tag}" <"${HALCYON_DIR}/cabal/.halcyon-tag" ||
			! validate_cabal_hook "${cabal_hook}" "${HALCYON_DIR}/cabal/.halcyon-hooks"
		then
			rm -rf "${HALCYON_CACHE_DIR}/${cabal_archive}" "${HALCYON_DIR}/cabal" || die
			log_warning "Restoring ${cabal_archive} failed"
			return 1
		fi
	fi
}


function restore_archived_updated_cabal () {
	expect_vars HALCYON_DIR HALCYON_CACHE_DIR

	local cabal_tag
	expect_args cabal_tag -- "$@"

	local cabal_hook
	cabal_hook=$( echo_cabal_tag_hook "${cabal_tag}" ) || die

	if [ -f "${HALCYON_DIR}/cabal/.halcyon-tag" ] &&
		validate_updated_cabal_tag "${cabal_tag}" <"${HALCYON_DIR}/cabal/.halcyon-tag" &&
		validate_cabal_hook "${cabal_hook}" "${HALCYON_DIR}/cabal/.halcyon-hooks"
	then
		return 0
	fi
	rm -rf "${HALCYON_DIR}/cabal" || die

	local cabal_archive
	if ! cabal_archive=$(
		find_spaceless_recursively "${HALCYON_CACHE_DIR}" |
		match_updated_cabal_archive "${cabal_tag}"
	); then
		return 1
	fi

	if ! tar_extract "${HALCYON_CACHE_DIR}/${cabal_archive}" "${HALCYON_DIR}/cabal" ||
		! [ -f "${HALCYON_DIR}/cabal/.halcyon-tag" ] ||
		! validate_updated_cabal_tag "${cabal_tag}" <"${HALCYON_DIR}/cabal/.halcyon-tag" ||
		! validate_cabal_hook "${cabal_hook}" "${HALCYON_DIR}/cabal/.halcyon-hooks"
	then
		rm -rf "${HALCYON_CACHE_DIR}/${cabal_archive}" "${HALCYON_DIR}/cabal" || die
		return 1
	fi
}


function restore_updated_cabal () {
	expect_vars HALCYON_DIR HALCYON_CACHE_DIR

	local cabal_tag
	expect_args cabal_tag -- "$@"

	local os cabal_hook archive_prefix cabal_description
	os=$( echo_cabal_tag_os "${cabal_tag}" ) || die
	cabal_hook=$( echo_cabal_tag_hook "${cabal_tag}" ) || die
	archive_prefix=$( echo_updated_cabal_archive_prefix "${cabal_tag}" ) || die
	cabal_description=$( echo_cabal_description "${cabal_tag}" ) || die

	log "Restoring updated ${cabal_description}"

	if restore_archived_updated_cabal "${cabal_tag}"; then
		return 0
	fi

	log "Locating updated ${cabal_description}"

	local cabal_archive
	if ! cabal_archive=$(
		list_layers "${os}/${archive_prefix}" |
		sed "s:${os}/::" |
		match_updated_cabal_archive "${cabal_tag}"
	); then
		log "Locating updated ${cabal_description} failed"
		return 1
	fi

	expect_no_existing "${HALCYON_CACHE_DIR}/${cabal_archive}"
	if ! download_layer "${os}" "${cabal_archive}" "${HALCYON_CACHE_DIR}"; then
		log_warning "Downloading ${cabal_archive} failed"
		return 1
	fi

	if ! tar_extract "${HALCYON_CACHE_DIR}/${cabal_archive}" "${HALCYON_DIR}/cabal" ||
		! [ -f "${HALCYON_DIR}/cabal/.halcyon-tag" ] ||
		! validate_updated_cabal_tag "${cabal_tag}" <"${HALCYON_DIR}/cabal/.halcyon-tag" ||
		! validate_cabal_hook "${cabal_hook}" "${HALCYON_DIR}/cabal/.halcyon-hooks"
	then
		rm -rf "${HALCYON_CACHE_DIR}/${cabal_archive}" "${HALCYON_DIR}/cabal" || die
		log_warning "Restoring ${cabal_archive} failed"
		return 1
	fi
}


function detect_cabal_version () {
	log_begin 'Detecting Cabal version...'

	local cabal_version
	if has_vars HALCYON_FORCE_CABAL_VERSION; then
		cabal_version="${HALCYON_FORCE_CABAL_VERSION}"

		log_end "${cabal_version}, forced"
	else
		cabal_version=$( echo_cabal_default_version ) || die

		log_end "done, ${cabal_version}"
	fi

	echo "${cabal_version}"
}


function detect_cabal_hook () {
	local app_dir
	expect_args app_dir -- "$@"

	echo_digest "${app_dir}/.halcyon-hooks/"*'-cabal-'*
}


function activate_cabal () {
	expect_vars HOME HALCYON_DIR
	expect_existing "${HOME}" "${HALCYON_DIR}/cabal/.halcyon-tag"

	local cabal_tag cabal_description
	cabal_tag=$( <"${HALCYON_DIR}/cabal/.halcyon-tag" ) || die
	cabal_description=$( echo_cabal_description "${cabal_tag}" ) || die

	log_begin "Activating ${cabal_description}..."

	if [ -e "${HOME}/.cabal/config" ] && ! [ -h "${HOME}/.cabal/config" ]; then
		die "Expected no actual ${HOME}/.cabal/config"
	fi

	mkdir -p "${HOME}/.cabal" || die
	rm -f "${HOME}/.cabal/config" || die
	ln -s "${HALCYON_DIR}/cabal/.halcyon-cabal.config" "${HOME}/.cabal/config" || die

	log_end 'done'
}


function deactivate_cabal () {
	expect_vars HOME HALCYON_DIR
	expect_existing "${HOME}" "${HALCYON_DIR}/cabal/.halcyon-tag"

	local cabal_tag cabal_description
	cabal_tag=$( <"${HALCYON_DIR}/cabal/.halcyon-tag" ) || die
	cabal_description=$( echo_cabal_description "${cabal_tag}" ) || die

	log_begin "Deactivating ${cabal_description}..."

	if [ -e "${HOME}/.cabal/config" ] && ! [ -h "${HOME}/.cabal/config" ]; then
		die "Expected no actual ${HOME}/.cabal/config"
	fi

	rm -f "${HOME}/.cabal/config" || die

	log_end 'done'
}


function install_cabal () {
	expect_vars HALCYON_FORCE_BUILD_ALL HALCYON_FORCE_BUILD_CABAL HALCYON_FORCE_UPDATE_CABAL HALCYON_NO_BUILD
	expect_existing "${HALCYON_DIR}/ghc/.halcyon-tag"

	local app_dir
	expect_args app_dir -- "$@"

	local ghc_tag cabal_version cabal_hook cabal_tag
	ghc_tag=$( <"${HALCYON_DIR}/ghc/.halcyon-tag" ) || die
	cabal_version=$( detect_cabal_version ) || die
	cabal_hook=$( detect_cabal_hook "${app_dir}" ) || die
	cabal_tag=$( derive_cabal_tag "${ghc_tag}" "${cabal_version}" "${cabal_hook}" ) || die

	if ! (( ${HALCYON_FORCE_BUILD_ALL} )) &&
		! (( ${HALCYON_FORCE_BUILD_CABAL} )) &&
		! (( ${HALCYON_FORCE_UPDATE_CABAL} )) &&
		restore_updated_cabal "${cabal_tag}"
	then
		activate_cabal || die
		return 0
	fi

	if ! (( ${HALCYON_FORCE_BUILD_ALL} )) &&
		! (( ${HALCYON_FORCE_BUILD_CABAL} )) &&
		restore_cabal "${cabal_tag}"
	then
		update_cabal || die
		archive_cabal || die
		activate_cabal || die
		return 0
	fi

	! (( ${HALCYON_NO_BUILD} )) || return 1

	build_cabal "${cabal_tag}" "${app_dir}" || die
	archive_cabal || die
	update_cabal || die
	archive_cabal || die
	activate_cabal || die
}
