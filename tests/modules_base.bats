#!/usr/bin/env bats

setup() { cd "$BATS_TEST_DIRNAME/.."; }

teardown() {
  rm -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.mona.*
}

@test "run_base does not overwrite sshd_config backup" {
  echo 'PasswordAuthentication yes' >/etc/ssh/sshd_config
  rm -f /etc/ssh/sshd_config.bak.mona.*

  for cmd in timedatectl systemctl ufw; do
    printf '#!/usr/bin/env bash\nexit 0\n' >"$BATS_TEST_TMPDIR/$cmd"
    chmod +x "$BATS_TEST_TMPDIR/$cmd"
  done

  run bash -lc "export PATH='$BATS_TEST_TMPDIR':\$PATH; export MONA_DIR=$(pwd); . modules/base/base.sh; run_base"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[mona] backup:"* ]]
  first_backup=$(ls /etc/ssh/sshd_config.bak.mona.*)

  sleep 1

  run bash -lc "export PATH='$BATS_TEST_TMPDIR':\$PATH; export MONA_DIR=$(pwd); . modules/base/base.sh; run_base"
  [ "$status" -eq 0 ]
  backups=(/etc/ssh/sshd_config.bak.mona.*)
  [ -f "$first_backup" ]
  [ "${#backups[@]}" -eq 2 ]
}
