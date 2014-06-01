#!/usr/bin/env bats

load test_helper

@test "default" {
  run cfenv global
  assert_success
  assert_output "system"
}

@test "read CFENV_ROOT/environment" {
  mkdir -p "$CFENV_ROOT"
  echo "1.2.3" > "$CFENV_ROOT/environment"
  run cfenv-global
  assert_success
  assert_output "1.2.3"
}

@test "set CFENV_ROOT/environment" {
  mkdir -p "$CFENV_ROOT/environments/1.2.3"
  run cfenv-global "1.2.3"
  assert_success
  run cfenv global
  assert_success "1.2.3"
}

@test "fail setting invalid CFENV_ROOT/environment" {
  mkdir -p "$CFENV_ROOT"
  run cfenv-global "1.2.3"
  assert_failure "cfenv: environment \`1.2.3' not installed"
}
