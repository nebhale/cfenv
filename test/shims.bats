#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run cfenv-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${CFENV_ROOT}/shims"
  touch "${CFENV_ROOT}/shims/cf"
  touch "${CFENV_ROOT}/shims/icf"
  run cfenv-shims
  assert_success
  assert_line "${CFENV_ROOT}/shims/cf"
  assert_line "${CFENV_ROOT}/shims/icf"
}

@test "shims --short" {
  mkdir -p "${CFENV_ROOT}/shims"
  touch "${CFENV_ROOT}/shims/cf"
  touch "${CFENV_ROOT}/shims/icf"
  run cfenv-shims --short
  assert_success
  assert_line "icf"
  assert_line "cf"
}
