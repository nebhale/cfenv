#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$CFENV_TEST_DIR"
  cd "$CFENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run cfenv-environment-file-write
  assert_failure "Usage: cfenv environment-file-write <file> <environment>"
  run cfenv-environment-file-write "one" ""
  assert_failure
}

@test "setting nonexistent environment fails" {
  assert [ ! -e ".cf-environment" ]
  run cfenv-environment-file-write ".cf-environment" "1.8.7"
  assert_failure "cfenv: environment \`1.8.7' not installed"
  assert [ ! -e ".cf-environment" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${CFENV_ROOT}/environments/1.8.7"
  assert [ ! -e "my-environment" ]
  run cfenv-environment-file-write "${PWD}/my-environment" "1.8.7"
  assert_success ""
  assert [ "$(cat my-environment)" = "1.8.7" ]
}
