#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$CFENV_TEST_DIR"
  cd "$CFENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${CFENV_ROOT}/environment" ]
  run cfenv-environment-origin
  assert_success "${CFENV_ROOT}/environment"
}

@test "detects global file" {
  mkdir -p "$CFENV_ROOT"
  touch "${CFENV_ROOT}/environment"
  run cfenv-environment-origin
  assert_success "${CFENV_ROOT}/environment"
}

@test "detects CFENV_ENVIRONMENT" {
  CFENV_ENVIRONMENT=1 run cfenv-environment-origin
  assert_success "CFENV_ENVIRONMENT environment variable"
}

@test "detects local file" {
  touch .cf-environment
  run cfenv-environment-origin
  assert_success "${PWD}/.cf-environment"
}

@test "detects alternate environment file" {
  touch .cfenv-environment
  run cfenv-environment-origin
  assert_success "${PWD}/.cfenv-environment"
}
