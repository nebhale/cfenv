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
  run cfenv-environment
  assert_success "system (set by ${CFENV_ROOT}/environment)"
}

@test "set by CFENV_ENVIRONMENT" {
  create_environment "1.9.3"
  CFENV_ENVIRONMENT=1.9.3 run cfenv-environment
  assert_success "1.9.3 (set by CFENV_ENVIRONMENT environment variable)"
}

@test "set by local file" {
  create_environment "1.9.3"
  cat > ".cf-environment" <<<"1.9.3"
  run cfenv-environment
  assert_success "1.9.3 (set by ${PWD}/.cf-environment)"
}

@test "set by global file" {
  create_environment "1.9.3"
  cat > "${CFENV_ROOT}/environment" <<<"1.9.3"
  run cfenv-environment
  assert_success "1.9.3 (set by ${CFENV_ROOT}/environment)"
}
