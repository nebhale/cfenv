#!/usr/bin/env bats

load test_helper

create_environment() {
  mkdir -p "${CFENV_ROOT}/environments/$1"
}

setup() {
  mkdir -p "$CFENV_TEST_DIR"
  cd "$CFENV_TEST_DIR"
}

@test "no environment selected" {
  assert [ ! -d "${CFENV_ROOT}/environments" ]
  run cfenv-environment-name
  assert_success "system"
}

@test "system environment is not checked for existance" {
  CFENV_ENVIRONMENT=system run cfenv-environment-name
  assert_success "system"
}

@test "CFENV_ENVIRONMENT has precedence over local" {
  create_environment "1.8.7"
  create_environment "1.9.3"

  cat > ".cf-environment" <<<"1.8.7"
  run cfenv-environment-name
  assert_success "1.8.7"

  CFENV_ENVIRONMENT=1.9.3 run cfenv-environment-name
  assert_success "1.9.3"
}

@test "local file has precedence over global" {
  create_environment "1.8.7"
  create_environment "1.9.3"

  cat > "${CFENV_ROOT}/environment" <<<"1.8.7"
  run cfenv-environment-name
  assert_success "1.8.7"

  cat > ".cf-environment" <<<"1.9.3"
  run cfenv-environment-name
  assert_success "1.9.3"
}

@test "missing environment" {
  CFENV_ENVIRONMENT=1.2 run cfenv-environment-name
  assert_failure "cfenv: environment \`1.2' is not installed"
}

@test "environment with prefix in name" {
  create_environment "1.8.7"
  cat > ".cf-environment" <<<"cf-1.8.7"
  run cfenv-environment-name
  assert_success
  assert_output <<OUT
warning: ignoring extraneous \`cf-' prefix in environment \`cf-1.8.7'
         (set by ${PWD}/.cf-environment)
1.8.7
OUT
}
