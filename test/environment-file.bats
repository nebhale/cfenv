#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$CFENV_TEST_DIR"
  cd "$CFENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  touch "$1"
}

@test "prints global file if no environment files exist" {
  assert [ ! -e "${CFENV_ROOT}/environment" ]
  assert [ ! -e ".cf-environment" ]
  run cfenv-environment-file
  assert_success "${CFENV_ROOT}/environment"
}

@test "detects 'global' file" {
  create_file "${CFENV_ROOT}/global"
  run cfenv-environment-file
  assert_success "${CFENV_ROOT}/global"
}

@test "detects 'default' file" {
  create_file "${CFENV_ROOT}/default"
  run cfenv-environment-file
  assert_success "${CFENV_ROOT}/default"
}

@test "'environment' has precedence over 'global' and 'default'" {
  create_file "${CFENV_ROOT}/environment"
  create_file "${CFENV_ROOT}/global"
  create_file "${CFENV_ROOT}/default"
  run cfenv-environment-file
  assert_success "${CFENV_ROOT}/environment"
}

@test "in current directory" {
  create_file ".cf-environment"
  run cfenv-environment-file
  assert_success "${CFENV_TEST_DIR}/.cf-environment"
}

@test "legacy file in current directory" {
  create_file ".cfenv-environment"
  run cfenv-environment-file
  assert_success "${CFENV_TEST_DIR}/.cfenv-environment"
}

@test ".cf-environment has precedence over legacy file" {
  create_file ".cf-environment"
  create_file ".cfenv-environment"
  run cfenv-environment-file
  assert_success "${CFENV_TEST_DIR}/.cf-environment"
}

@test "in parent directory" {
  create_file ".cf-environment"
  mkdir -p project
  cd project
  run cfenv-environment-file
  assert_success "${CFENV_TEST_DIR}/.cf-environment"
}

@test "topmost file has precedence" {
  create_file ".cf-environment"
  create_file "project/.cf-environment"
  cd project
  run cfenv-environment-file
  assert_success "${CFENV_TEST_DIR}/project/.cf-environment"
}

@test "legacy file has precedence if higher" {
  create_file ".cf-environment"
  create_file "project/.cfenv-environment"
  cd project
  run cfenv-environment-file
  assert_success "${CFENV_TEST_DIR}/project/.cfenv-environment"
}

@test "CFENV_DIR has precedence over PWD" {
  create_file "widget/.cf-environment"
  create_file "project/.cf-environment"
  cd project
  CFENV_DIR="${CFENV_TEST_DIR}/widget" run cfenv-environment-file
  assert_success "${CFENV_TEST_DIR}/widget/.cf-environment"
}

@test "PWD is searched if CFENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.cf-environment"
  cd project
  CFENV_DIR="${CFENV_TEST_DIR}/widget/blank" run cfenv-environment-file
  assert_success "${CFENV_TEST_DIR}/project/.cf-environment"
}
