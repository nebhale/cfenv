#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${CFENV_TEST_DIR}/myproject"
  cd "${CFENV_TEST_DIR}/myproject"
}

@test "no environment" {
  assert [ ! -e "${PWD}/.cf-environment" ]
  run cfenv-local
  assert_failure "cfenv: no local environment configured for this directory"
}

@test "local environment" {
  echo "1.2.3" > .cf-environment
  run cfenv-local
  assert_success "1.2.3"
}

@test "supports legacy .cfenv-environment file" {
  echo "1.2.3" > .cfenv-environment
  run cfenv-local
  assert_success "1.2.3"
}

@test "local .cf-environment has precedence over .cfenv-environment" {
  echo "1.8" > .cfenv-environment
  echo "2.0" > .cf-environment
  run cfenv-local
  assert_success "2.0"
}

@test "ignores environment in parent directory" {
  echo "1.2.3" > .cf-environment
  mkdir -p "subdir" && cd "subdir"
  run cfenv-local
  assert_failure
}

@test "ignores CFENV_DIR" {
  echo "1.2.3" > .cf-environment
  mkdir -p "$HOME"
  echo "2.0-home" > "${HOME}/.cf-environment"
  CFENV_DIR="$HOME" run cfenv-local
  assert_success "1.2.3"
}

@test "sets local environment" {
  mkdir -p "${CFENV_ROOT}/environments/1.2.3"
  run cfenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .cf-environment)" = "1.2.3" ]
}

@test "changes local environment" {
  echo "1.0-pre" > .cf-environment
  mkdir -p "${CFENV_ROOT}/environments/1.2.3"
  run cfenv-local
  assert_success "1.0-pre"
  run cfenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .cf-environment)" = "1.2.3" ]
}

@test "renames .cfenv-environment to .cf-environment" {
  echo "1.8.7" > .cfenv-environment
  mkdir -p "${CFENV_ROOT}/environments/1.9.3"
  run cfenv-local
  assert_success "1.8.7"
  run cfenv-local "1.9.3"
  assert_success
  assert_output <<OUT
cfenv: removed existing \`.cfenv-environment' file and migrated
       local environment specification to \`.cf-environment' file
OUT
  assert [ ! -e .cfenv-environment ]
  assert [ "$(cat .cf-environment)" = "1.9.3" ]
}

@test "doesn't rename .cfenv-environment if changing the environment failed" {
  echo "1.8.7" > .cfenv-environment
  assert [ ! -e "${CFENV_ROOT}/environments/1.9.3" ]
  run cfenv-local "1.9.3"
  assert_failure "cfenv: environment \`1.9.3' not installed"
  assert [ ! -e .cf-environment ]
  assert [ "$(cat .cfenv-environment)" = "1.8.7" ]
}

@test "unsets local environment" {
  touch .cf-environment
  run cfenv-local --unset
  assert_success ""
  assert [ ! -e .cfenv-environment ]
}

@test "unsets alternate environment file" {
  touch .cfenv-environment
  run cfenv-local --unset
  assert_success ""
  assert [ ! -e .cfenv-environment ]
}
