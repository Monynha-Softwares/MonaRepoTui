#!/usr/bin/env bats

setup() { cd "$BATS_TEST_DIRNAME/.."; }

@test "run_base does not overwrite sshd_config backup" {
  sshd_dir="$BATS_TEST_TMPDIR/etc/ssh"
  mkdir -p "$sshd_dir"
  sshd_config="$sshd_dir/sshd_config"
  echo 'PasswordAuthentication yes' >"$sshd_config"
  rm -f "$sshd_dir"/sshd_config.bak.mona.*

  for cmd in timedatectl systemctl ufw; do
    printf '#!/usr/bin/env bash\nexit 0\n' >"$BATS_TEST_TMPDIR/$cmd"
    chmod +x "$BATS_TEST_TMPDIR/$cmd"
  done

  run bash -lc "export PATH='$BATS_TEST_TMPDIR':\$PATH; export MONA_DIR=$(pwd); export SSHD_CONFIG=$sshd_config; . modules/base/base.sh; run_base"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[mona] backup:"* ]]
  first_backup=$(ls "$sshd_dir"/sshd_config.bak.mona.*)

  sleep 1

  run bash -lc "export PATH='$BATS_TEST_TMPDIR':\$PATH; export MONA_DIR=$(pwd); export SSHD_CONFIG=$sshd_config; . modules/base/base.sh; run_base"
  [ "$status" -eq 0 ]
  backups=("$sshd_dir"/sshd_config.bak.mona.*)
  [ -f "$first_backup" ]
  [ "${#backups[@]}" -eq 2 ]
}
