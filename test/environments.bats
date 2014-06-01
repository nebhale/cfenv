#!/usr/bin/env bats

load test_helper

create_environment() {
  mkdir -p "${CFENV_ROOT}/environments/$1"
}

setup() {
  mkdir -p "$CFENV_TEST_DIR"
  cd "$CFENV_TEST_DIR"
}

stub_system_ruby() {
  local stub="${CFENV_TEST_DIR}/bin/ruby"
  mkdir -p "$(dirname "$stub")"
  touch "$stub" && chmod +x "$stub"
}

@test "no environments installed" {
  stub_system_ruby
  assert [ ! -d "${CFENV_ROOT}/environments" ]
  run cfenv-environments
  assert_success "* system (set by ${CFENV_ROOT}/environment)"
}

@test "bare output no environments installed" {
  assert [ ! -d "${CFENV_ROOT}/environments" ]
  run cfenv-environments --bare
  assert_success ""
}

@test "single environment installed" {
  stub_system_ruby
  create_environment "1.9"
  run cfenv-environments
  assert_success
  assert_output <<OUT
* system (set by ${CFENV_ROOT}/environment)
  1.9
OUT
}

@test "single environment bare" {
  create_environment "1.9"
  run cfenv-environments --bare
  assert_success "1.9"
}

@test "multiple environments" {
  stub_system_ruby
  create_environment "1.8.7"
  create_environment "1.9.3"
  create_environment "2.0.0"
  run cfenv-environments
  assert_success
  assert_output <<OUT
* system (set by ${CFENV_ROOT}/environment)
  1.8.7
  1.9.3
  2.0.0
OUT
}

@test "indicates current environment" {
  stub_system_ruby
  create_environment "1.9.3"
  create_environment "2.0.0"
  CFENV_ENVIRONMENT=1.9.3 run cfenv-environments
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by CFENV_ENVIRONMENT environment variable)
  2.0.0
OUT
}

@test "bare doesn't indicate current environment" {
  create_environment "1.9.3"
  create_environment "2.0.0"
  CFENV_ENVIRONMENT=1.9.3 run cfenv-environments --bare
  assert_success
  assert_output <<OUT
1.9.3
2.0.0
OUT
}

@test "globally selected environment" {
  stub_system_ruby
  create_environment "1.9.3"
  create_environment "2.0.0"
  cat > "${CFENV_ROOT}/environment" <<<"1.9.3"
  run cfenv-environments
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by ${CFENV_ROOT}/environment)
  2.0.0
OUT
}

@test "per-project environment" {
  stub_system_ruby
  create_environment "1.9.3"
  create_environment "2.0.0"
  cat > ".cf-environment" <<<"1.9.3"
  run cfenv-environments
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by ${CFENV_TEST_DIR}/.cf-environment)
  2.0.0
OUT
}
