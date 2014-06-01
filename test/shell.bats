#!/usr/bin/env bats

load test_helper

@test "no shell environment" {
  mkdir -p "${CFENV_TEST_DIR}/myproject"
  cd "${CFENV_TEST_DIR}/myproject"
  echo "1.2.3" > .cf-environment
  CFENV_ENVIRONMENT="" run cfenv-sh-shell
  assert_failure "cfenv: no shell-specific environment configured"
}

@test "shell environment" {
  CFENV_SHELL=bash CFENV_ENVIRONMENT="1.2.3" run cfenv-sh-shell
  assert_success 'echo "$CFENV_ENVIRONMENT"'
}

@test "shell environment (fish)" {
  CFENV_SHELL=fish CFENV_ENVIRONMENT="1.2.3" run cfenv-sh-shell
  assert_success 'echo "$CFENV_ENVIRONMENT"'
}

@test "shell unset" {
  CFENV_SHELL=bash run cfenv-sh-shell --unset
  assert_success "unset CFENV_ENVIRONMENT"
}

@test "shell unset (fish)" {
  CFENV_SHELL=fish run cfenv-sh-shell --unset
  assert_success "set -e CFENV_ENVIRONMENT"
}

@test "shell change invalid environment" {
  run cfenv-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
cfenv: environment \`1.2.3' not installed
false
SH
}

@test "shell change environment" {
  mkdir -p "${CFENV_ROOT}/environments/1.2.3"
  CFENV_SHELL=bash run cfenv-sh-shell 1.2.3
  assert_success 'export CFENV_ENVIRONMENT="1.2.3"'
}

@test "shell change environment (fish)" {
  mkdir -p "${CFENV_ROOT}/environments/1.2.3"
  CFENV_SHELL=fish run cfenv-sh-shell 1.2.3
  assert_success 'setenv CFENV_ENVIRONMENT "1.2.3"'
}
