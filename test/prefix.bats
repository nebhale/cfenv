#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${CFENV_TEST_DIR}/myproject"
  cd "${CFENV_TEST_DIR}/myproject"
  echo "1.2.3" > .cf-environment
  mkdir -p "${CFENV_ROOT}/environments/1.2.3"
  run cfenv-prefix
  assert_success "${CFENV_ROOT}/environments/1.2.3"
}

@test "prefix for invalid environment" {
  CFENV_ENVIRONMENT="1.2.3" run cfenv-prefix
  assert_failure "cfenv: environment \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${CFENV_TEST_DIR}/bin"
  touch "${CFENV_TEST_DIR}/bin/cf"
  chmod +x "${CFENV_TEST_DIR}/bin/cf"
  CFENV_ENVIRONMENT="system" run cfenv-prefix
  assert_success "$CFENV_TEST_DIR"
}

@test "prefix for invalid system" {
  PATH="$(path_without cf)" run cfenv-prefix system
  assert_failure "cfenv: system environment not found in PATH"
}
