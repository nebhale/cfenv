#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin
  if [[ $1 == */* ]]; then bin="$1"
  else bin="${CFENV_ROOT}/environments/${1}/bin"
  fi
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "outputs path to executable" {
  create_executable "1.8" "ruby"
  create_executable "2.0" "rspec"

  CFENV_ENVIRONMENT=1.8 run cfenv-which ruby
  assert_success "${CFENV_ROOT}/environments/1.8/bin/ruby"

  CFENV_ENVIRONMENT=2.0 run cfenv-which rspec
  assert_success "${CFENV_ROOT}/environments/2.0/bin/rspec"
}

@test "searches PATH for system environment" {
  create_executable "${CFENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${CFENV_ROOT}/shims" "kill-all-humans"

  CFENV_ENVIRONMENT=system run cfenv-which kill-all-humans
  assert_success "${CFENV_TEST_DIR}/bin/kill-all-humans"
}

@test "environment not installed" {
  create_executable "2.0" "rspec"
  CFENV_ENVIRONMENT=1.9 run cfenv-which rspec
  assert_failure "cfenv: environment \`1.9' is not installed"
}

@test "no executable found" {
  create_executable "1.8" "rspec"
  CFENV_ENVIRONMENT=1.8 run cfenv-which rake
  assert_failure "cfenv: rake: command not found"
}

@test "executable found in other environments" {
  create_executable "1.8" "ruby"
  create_executable "1.9" "rspec"
  create_executable "2.0" "rspec"

  CFENV_ENVIRONMENT=1.8 run cfenv-which rspec
  assert_failure
  assert_output <<OUT
cfenv: rspec: command not found

The \`rspec' command exists in these Cloud Foundry environments:
  1.9
  2.0
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${CFENV_TEST_DIR}/cfenv.d"
  mkdir -p "${hook_path}/which"
  cat > "${hook_path}/which/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  CFENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run cfenv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}
