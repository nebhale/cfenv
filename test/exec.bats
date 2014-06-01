#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${CFENV_ROOT}/environments/${CFENV_ENVIRONMENT}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "fails with invalid environment" {
  export CFENV_ENVIRONMENT="2.0"
  run cfenv-exec cf -v
  assert_failure "cfenv: environment \`2.0' is not installed"
}

@test "completes with names of executables" {
  export CFENV_ENVIRONMENT="2.0"
  create_executable "cf" "#!/bin/sh"
  create_executable "rake" "#!/bin/sh"

  cfenv-rehash
  run cfenv-completions exec
  assert_success
  assert_output <<OUT
cf
rake
OUT
}

@test "supports hook path with spaces" {
  hook_path="${CFENV_TEST_DIR}/custom stuff/cfenv hooks"
  mkdir -p "${hook_path}/exec"
  echo "export HELLO='from hook'" > "${hook_path}/exec/hello.bash"

  export CFENV_ENVIRONMENT=system
  CFENV_HOOK_PATH="$hook_path" run cfenv-exec env
  assert_success
  assert_line "HELLO=from hook"
}

@test "carries original IFS within hooks" {
  hook_path="${CFENV_TEST_DIR}/cfenv.d"
  mkdir -p "${hook_path}/exec"
  cat > "${hook_path}/exec/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export CFENV_ENVIRONMENT=system
  CFENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run cfenv-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export CFENV_ENVIRONMENT="2.0"
  create_executable "cf" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run cfenv-exec cf -w "/path to/cf script.cf" -- extra args
  assert_success
  assert_output <<OUT
${CFENV_ROOT}/environments/2.0/bin/cf
  -w
  /path to/cf script.cf
  --
  extra
  args
OUT
}

@test "supports cf -S <cmd>" {
  export CFENV_ENVIRONMENT="2.0"

  # emulate `cf -S' behavior
  create_executable "cf" <<SH
#!$BASH
if [[ \$1 == "-S"* ]]; then
  found="\$(PATH="\${CFPATH:-\$PATH}" which \$2)"
  # assert that the found executable has cf for shebang
  if head -1 "\$found" | grep cf >/dev/null; then
    \$BASH "\$found"
  else
    echo "cf: no Cf script found in input (LoadError)" >&2
    exit 1
  fi
else
  echo 'cf 2.0 (cfenv test)'
fi
SH

  create_executable "rake" <<SH
#!/usr/bin/env cf
echo hello rake
SH

  cfenv-rehash
  run cf -S rake
  assert_success "hello rake"
}
